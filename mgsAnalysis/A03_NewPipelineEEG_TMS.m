function A03_NewPipelineEEG_TMS(subjID, day)
% Created by Mrugank:
% For Working Memory Memory-Guided Saccade EEG analysis
% The script performs preprocessing of EEG data for with and without TMS
% datasets for each subject and each session. The "step" argument lets you
% pass in which steps of preprocessing you would like to run. The current
% order is:
% Step 1: Concatenate data: if multiple sessions
% Step 2: Preprocess and epoch data to stimulus onset
% Step 3: Remove pulse artifact and interpolate (for TMS only)
% Step 4: Bandpass filter the data [0.5 100] Hz and remove line noise at
% 60Hz
% Artifact rejection (needs to be done manually and any flagged channels
% and trials should be added to flagged_trls_chans.m file
% Step 5: Reepoch data: reference to CAR and reepoch after removing bad
% trials
% Step 6: Event-related potential (ERP) for epoched data
% Step 7: Time-frequency analysis using wavelet method: ERSP, ITC and phase
% are computed
clearvars -except subjID day steps; close all;

%% Intialization
left_occ_elecs = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_occ_elecs = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

p.subjID = num2str(subjID,'%02d');
p.day = day;

[p, taskMap] = initialization(p, 'eeg', 0);
meta_data = readtable([p.analysis '/EEG_TMS_meta_Summary.csv']);
load([p.analysis '/calib/sub' num2str(subjID, '%02d') '/flagged_trls.mat'])
% Load flagged trials based on timing errors
block_flag = flg.block(flg.day == p.day);
trl_flag = flg.trls(flg.day == p.day);
trls_to_remove = (block_flag - 1) * 40 + trl_flag;

HemiStimulated = table2cell(meta_data(:, ["HemisphereStimulated"]));
NoTMSDays = table2array(meta_data(:, ["NoTMSDay"]));
steps = {'concat', 'raweeg', 'ica', 'ica_correct', 'epoch', 'reepoch', 'erp', 'tfr_evoked', 'tfr_induced', 'erp_trialwise'};

cond_list = ["pin", "pout", "ain", "aout"];
% List of files to be saved
% Step 1: Loading data 'subXX_dayXX_raweeg.mat'
% Step 2: Remove low frequency drifts 'subXX_dayXX_highpass.mat'
% Step 3: Epoch data 'subXX_dayXX_epoched.mat'

% File names
fName.folder                    = [p.saveEEG '/sub' p.subjID '/day' num2str(p.day,'%02d')];
if ~exist(fName.folder, 'dir')
    mkdir(fName.folder)
end
fName.general                   = [fName.folder '/sub' p.subjID '_day' num2str(p.day,'%02d')];
fName.concat                    = [fName.general '.vhdr'];
fName.flag_data                 = [fName.general '_flagdata.mat'];
fName.load                      = [fName.general '_raweeg.mat'];
fName.ica                       = [fName.general '_ica.mat'];
fName.raw_cleaned               = [fName.general '_raw_cleaned.mat'];
fName.trl_idx                   = [fName.general '_trl_idx.mat'];
fName.epoc_all                  = [fName.general '_epoc_all.mat'];
fName.epoc                      = [fName.general '_epoc.mat'];
fName.erp                       = [fName.general '_erp.mat'];
fName.erp_trialwise             = [fName.general '_erp_trialwise.mat'];
fName.TFR_evoked                = [fName.general '_TFR_evoked.mat'];
fName.TFR_induced               = [fName.general '_TFR_induced.mat'];
fName.TFR_evoked_basecorr       = [fName.general '_TFR_evoked_basecorr.mat'];
fName.TFR_induced_basecorr      = [fName.general '_TFR_induced_basecorr.mat'];
%% Concatenate EEG data
if any(strcmp(steps, 'concat'))
    if ~exist(fName.concat, 'file')
        disp('Concatenated file does not exist. Concatenating EEG data.')
        ConcatEEG(p, fName);
    else
        disp('Concatenated file exists. Skipping this step.')
    end
end

%% Load data and do basic cleaning (removing channels)
if any(strcmp(steps, 'raweeg'))
    if ~exist(fName.epoc_all, 'file')
        % Load up raw data
        if day == NoTMSDays(subjID)
            cfg                           = [];
            cfg.dataset                   = fName.concat;
            cfg.continuous                = 'yes';
            cfg.bpfilter                  = 'yes';
            cfg.bpfreq                    = [0.5 50];
            cfg.bpfilttype                = 'but';
            cfg.bpfiltord                 = 4; 
            cfg.bpfiltdir                 = 'twopass'; 
            cfg.channel                   = {'all', '-LM', '-RM', '-TP9', '-TP10'};
            raw_data                      = ft_preprocessing(cfg);
        else
            [raw_data, trls_to_remove]    = remove_tms_pulse(fName, trls_to_remove);
        end
        % Epoch data to trial start
        cfg                           = [];
        cfg.dataset                   = fName.concat;
        cfg.continuous                = 'yes';
        cfg.trialdef.prestim          = 1.5;
        cfg.trialdef.poststim         = 4.5;
        cfg.trialdef.eventtype        = 'Stimulus';
        cfg.trialdef.eventvalue       = {'S 11', 'S 12', 'S 13', 'S 14'};
        cfg                           = ft_definetrial(cfg);
        cfg_new                       = [];
        cfg_new.trl                   = cfg.trl;
        raw_epoc                      = ft_redefinetrial(cfg_new, raw_data);
        cfg                           = [];
        % Remove trials that have bad timing
        if ~isempty(trls_to_remove)
            cfg.trials                = setdiff(1:length(raw_epoc.trialinfo), trls_to_remove);
            %trl_info                  = trl_info(cfg.trials, :);
        end
        raw_epoc                      = ft_selectdata(cfg, raw_epoc);
        
        % Detect bad channels
        [bad_ch, ~, raw_data]         = auto_reject(raw_data, raw_epoc);        
        
        % Average reference
        cfg                           = [];
        cfg.implicitref               = 'Cz';
        cfg.reref                     = 'yes';
        cfg.refchannel                = 'all';
        cfg.refmethod                 = 'avg';
        raw_data                      = ft_preprocessing(cfg, raw_data);
        clearvars raw_epoc;
        save(fName.flag_data, 'bad_ch', 'trls_to_remove')
        %save(fName.load, 'raw_data', '-v7.3')
%     else
%         if ~exist(fName.raw_cleaned, 'file')
%             disp('Raw data exists. Loading existing file.')
%             load(fName.load)
%         else
%             disp('Raw data exists, but not loading it.')
%         end
%         load(fName.flag_data)
    end
end

%% Run ICA
if any(strcmp(steps, 'ica'))
    if ~exist(fName.epoc_all, 'file')
        cfg = []; cfg.method = 'fastica';
        cfg.randomseed = 42;
        ica_comp = ft_componentanalysis(cfg, raw_data);
        %save(fName.ica, 'ica_comp', '-v7.3')
%     else
%         if ~exist(fName.raw_cleaned, 'file')
%             disp('ICA already ran. Loading existing ICA.')
%             load(fName.ica)
%         else
%             disp('ICA already ran, but loading it.')
%         end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code for ICA visualization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cfg = [];  cfg.component = 1:length(ica_comp.label); cfg.layout = 'acticap-64_md.mat'; cfg.comment = 'no'; ft_topoplotIC(cfg, ica_comp)
% cfg = []; cfg.layout = 'acticap-64_md.mat'; cfg.viewmode = 'component'; cfg.ylim = [-200, 200]; ft_databrowser(cfg, ica_comp)
%
if any(strcmp(steps, 'ica_correct'))
    if ~exist(fName.epoc_all, 'file')
        % Reject bad components
        cfg = []; 
        cfg.component = bad_component_list(subjID, day);
        cfg.demean     = 'no';
        raw_cleaned = ft_rejectcomponent(cfg, ica_comp, raw_data);
        
        % Interpolate bad channels
        load('helper/neighbors.mat');
        % Interpolate bad channels
        cfg                     = [];
        cfg.badchannel          = bad_ch;
        cfg.method              = 'weighted';
        cfg.neighbours          = neighbors;
        cfg.layout              = 'acticap-64_md.mat';
        cfg.senstype            = 'eeg';
        raw_cleaned             = ft_channelrepair(cfg, raw_cleaned);
        clearvars ica_comp raw_data;
%         save(fName.raw_cleaned, 'raw_cleaned', '-v7.3')
%         delete(fName.load)
%         delete(fName.ica)
%     else
%         disp('Cleaned data already exists. Loading existing data.')
%         load(fName.raw_cleaned)
    end
end

%% Epoch data
if any(strcmp(steps, 'epoch'))
    if ~exist(fName.epoc_all, 'file') 
        cfg                           = [];
        cfg.dataset                   = fName.concat;
        cfg.continuous                = 'yes';
        cfg.trialdef.prestim          = 1.5;
        cfg.trialdef.poststim         = 6;
        cfg.trialdef.eventtype        = 'Stimulus';
        cfg.trialdef.eventvalue       = {'S 11', 'S 12', 'S 13', 'S 14'};
        cfg                           = ft_definetrial(cfg);
        trl_info                      = cfg.trl;
        cfg_new                       = [];
        cfg_new.trl                   = trl_info;
        epoc_cleaned                  = ft_redefinetrial(cfg_new, raw_cleaned);
        cfg                           = [];
        cfg.resamplefs                = 200;
        cfg.method                    = 'downsample';
        epoc_cleaned                  = ft_resampledata(cfg, epoc_cleaned);
        
        save(fName.epoc_all, 'epoc_cleaned', '-v7.3')
        % Do trial-rejection if needed here.
        % cfg = []; cfg.method = 'summary'; cfg.ylim = [-1e-12 1e-12]; dummy = ft_rejectvisual(cfg, epoc_cleaned);
        [flg_trls, ~] = flagged_trls_chans(subjID, day);
        if ~isempty(flg_trls)
            orig_len = length(trls_to_remove);
            trls_to_remove = unique([trls_to_remove flg_trls]);
            if length(trls_to_remove) > length(orig_len)
                disp('here')
                save(fName.flag_data, 'bad_ch', 'trls_to_remove')
            end
        end
    else
        disp('Epoched all trials already exist. Loading extisting data.')
        load(fName.epoc_all)
        load(fName.flag_data)
    end
end

%% Repoch by condition
if any(strcmp(steps, 'reepoch'))
    if ~exist(fName.epoc, 'file') 
        disp('Re-epoching and eliminating bad trials')
        % Select good trials for each epoched data type
        cfg                            = [];
        cfg.channel                    = 'all';
        
        % epoch data by trial types and remove bad trials
        for ii = 1:length(cond_list)
            cc = cond_list(ii);
            [trl_idx.(cc), epoc.(cc)]        = create_epochs(epoc_cleaned, 10+ii, trls_to_remove);
        end
    
        save(fName.epoc, 'epoc', '-v7.3')
        save(fName.trl_idx, 'trl_idx')
    else
        load(fName.epoc)
    end
end

%% Compute ERPs
if any(strcmp(steps, 'erp'))
    if ~exist(fName.erp, 'file')
        [ERP.pin, ERP.pout]                     = compute_ERPs(epoc.pin, epoc.pout);
        [ERP.ain, ERP.aout]                     = compute_ERPs(epoc.ain, epoc.aout);
        save(fName.erp, 'ERP', '-v7.3');
    else
        load(fName.erp)
    end
end

%% Compute evoked TFR
if any(strcmp(steps, 'tfr_evoked'))
    if ~exist(fName.TFR_evoked, 'file')
        for cc = cond_list
            [POW.(cc), ITC.(cc), PHASE.(cc)]    = compute_TFRs(epoc.(cc), 0);
        end
        save(fName.TFR_evoked, 'POW', 'ITC', 'PHASE', '-v7.3');
        clearvars POW ITC PHASE;
    end
    if ~exist(fName.TFR_evoked_basecorr, 'file')
        for cc = cond_list
            [POW.(cc), ITC.(cc), PHASE.(cc)]    = compute_TFRs(epoc.(cc), 1);
        end
        save(fName.TFR_evoked_basecorr, 'POW', 'ITC', 'PHASE', '-v7.3');
        clearvars POW ITC PHASE;
    end
end

%% Compute induced TFR
if any(strcmp(steps, 'tfr_induced'))
    if ~exist(fName.TFR_induced, 'file')
        for cc = cond_list
            epoc_minus_erp                       = epoc.(cc);
            for k = 1:numel(epoc.(cc).trial)
                epoc_minus_erp.trial{k}          = epoc.(cc).trial{k} - ERP.(cc).avg;
            end
            [POW.(cc), ITC.(cc), PHASE.(cc)]     = compute_TFRs(epoc_minus_erp, 0);
        end
        save(fName.TFR_induced, 'POW', 'ITC', 'PHASE', '-v7.3');
        clearvars POW ITC PHASE;
    end
    if ~exist(fName.TFR_induced_basecorr, 'file')
        for cc = cond_list
            epoc_minus_erp                       = epoc.(cc);
            for k = 1:numel(epoc.(cc).trial)
                epoc_minus_erp.trial{k}          = epoc.(cc).trial{k} - ERP.(cc).avg;
            end
            [POW.(cc), ITC.(cc), PHASE.(cc)]     = compute_TFRs(epoc_minus_erp, 1);
        end
        save(fName.TFR_induced_basecorr, 'POW', 'ITC', 'PHASE', '-v7.3');
        clearvars POW ITC PHASE;
    end
end

if any(strcmp(steps, 'erp_trialwise'))
    if ~exist(fName.erp_trialwise, 'file')
        [ERP.pin, ERP.pout]                     = compute_ERPs(epoc.pin, epoc.pout, 1);
        [ERP.ain, ERP.aout]                     = compute_ERPs(epoc.ain, epoc.aout, 1);
        save(fName.erp_trialwise, 'ERP', '-v7.3');
    else
        load(fName.erp_trialwise)
    end
end
disp('Woosh! That was a lot of work.')
end
