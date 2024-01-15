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
disp(subjID)
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
if day == NoTMSDays(subjID) % If this is a No TMS day
    steps = {'concat', 'raweeg'};
else % if this is a TMS day
    steps = {'concat'};
end

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
fName.load                      = [fName.general '_raweeg.mat'];
fName.ica                       = [fName.general '_ica.mat'];
fName.raw_cleaned               = [fName.general '_raw_cleaned.mat'];
fName.erp                       = [fName.general '_erp.mat'];
fName.tms_erp                   = [fName.general '_tms_erp.mat'];
fName.TFR                       = [fName.general '_TFR.mat'];
fName.TMS_TFR                   = [fName.general '_TMS_TFR.mat'];
fName.TFR_induced               = [fName.general '_TFR_induced.mat'];
fName.TMS_TFR_induced           = [fName.general '_TMS_TFR_induced.mat'];
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
    if ~exist(fName.load, 'file')
        % Load up raw data
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
        
        % Epoch data to trial start
        cfg                           = [];
        cfg.dataset                   = fName.concat;
        cfg.continuous                = 'yes';
        cfg.trialdef.prestim          = 0.5;
        cfg.trialdef.poststim         = 5.5;
        cfg.trialdef.eventtype        = 'Stimulus';
        cfg.trialdef.eventvalue       = {'S 11'};
        cfg                           = ft_definetrial(cfg);
        cfg_new                       = [];
        cfg_new.trl                   = cfg.trl;
        trl_info                      = cfg.trl;
        raw_epoc                      = ft_redefinetrial(cfg_new, raw_data);
        cfg                           = [];
        % Remove trials that have bad timing
        if ~isempty(trls_to_remove)
            cfg.trials                = setdiff(1:length(raw_epoc.trialinfo), trls_to_remove);
            trl_info                  = trl_info(cfg.trials, :);
        end
        raw_epoc                      = ft_selectdata(cfg, raw_epoc);
        
        thresh                        = [];
        thresh.pval                   = 90;
        thresh.prop_badtrials         = 0.25;
        ch_names                      = raw_data.label;
        tseries                       = raw_data.trial{1};
        ch_std                        = std(tseries, 0, 2);
        ch_med                        = median(ch_std);
        rej_thresh                    = prctile(abs(ch_std - ch_med), thresh.pval);
        bad_ch1                       = ch_names(abs(ch_std - ch_med)>rej_thresh);
        ntrials                       = length(raw_epoc.trialinfo);
        nchans                        = length(ch_names);
        flagged_data                  = zeros(ntrials, nchans);
        for ii = 1:ntrials
            tr_std = std(raw_epoc.trial{ii}, 0, 2);
            flagged_data(ii, :) = abs(tr_std - ch_med) > rej_thresh;
        end
        bad_chan_num = find(sum(flagged_data, 1) > thresh.prop_badtrials * ntrials);
        flagged_data(:, bad_chan_num) = zeros(ntrials, length(bad_chan_num));
        bad_trls = find(sum(flagged_data) > 0);
        % Reject channel if flat or too noisy
        bad_ch = ch_names((ch_std < 0.01) | (ch_std > 100));
        bad_ch = unique([bad_ch; ch_names(bad_chan_num); bad_ch1]);
        
        cfg                           = [];
        cfg.channel                   = setdiff(ch_names, bad_ch);
        raw_data                      = ft_selectdata(cfg, raw_data);
        
        cfg                           = [];
        cfg.implicitref               = 'Cz';
        cfg.reref                     = 'yes';
        cfg.refchannel                = 'all';
        cfg.refmethod                 = 'avg';
        raw_data                      = ft_preprocessing(cfg, raw_data);
        
        save(fName.load, 'raw_data', 'bad_ch')
    else
        if ~exist(fName.ica, 'file')
            disp('Cleaned data exists. Loading existing file.')
            load(fName.load)
        else
            disp('Cleaned data exists, but not loading it.')
        end
    end
end

%% Run ICA
if any(strcmp(steps, 'ica'))
    if ~exist(fName.ica, 'ica')
        cfg = []; cfg.method = 'fastica';
        cfg.randomseed = 42;
        ica_comp = ft_componentanalysis(cfg, raw_data);
        save(fName.ica, 'ica_comp')
    else
        disp('ICA already ran. Loading existing ICA.')
        load(fName.ica)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code for ICA visualization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cfg = [];  cfg.component = 1:length(ica_comp.label); cfg.layout = 'acticap-64_md.mat'; cfg.comment = 'no';
% ft_topoplotIC(cfg, ica_comp)
% 
% cfg = [];
% cfg.layout = 'acticap-64_md.mat'; % specify the layout file that should be used for plotting
% cfg.viewmode = 'component';
% ft_databrowser(cfg, ica_comp)
% 
% cfg = [];
% cfg.component = [30 39];
% raw_ica_cleaned = ft_rejectcomponent(cfg, ica_comp, raw_cleaned_reref);
% 
% save(fName.raw_cleaned, 'raw_data')
% cfg = []; cfg.viewmode = 'vertical';
% ft_databrowser(cfg, raw_cleaned_reref)
% ft_databrowser(cfg, raw_ica_cleaned)
% 

% % Interpolate bad channels
% load('helper/neighbors.mat');
% % Interpolate bad channels
% cfg_chanrepair                     = [];
% cfg_chanrepair.badchannel          = bad_ch;
% cfg_chanrepair.method              = 'weighted';
% cfg_chanrepair.neighbours          = neighbors;
% cfg_chanrepair.layout              = 'acticap-64_md.mat';
% cfg_chanrepair.senstype            = 'eeg';
% raw_new                            = ft_channelrepair(cfg_chanrepair,raw_ica_cleaned);
%     
% proinVF = create_epochs(fName, 'S 11', raw_new);
% prooutVF = create_epochs(fName, 'S 12', raw_new);
% antiinVF = create_epochs(fName, 'S 13', raw_new);
% antioutVF = create_epochs(fName, 'S 14', raw_new);
% 
% [erp_proinVF, erp_prooutVF]          = compute_ERPs(proinVF, prooutVF);
% [erp_antioutVF, erp_antioutVF]       = compute_ERPs(antiinVF, antioutVF);
% 
% [TFR_proinVF, ~, ~]       = compute_TFRs(proinVF);
% [TFR_prooutVF, ~, ~]       = compute_TFRs(prooutVF);
% [TFR_antiinVF, ~, ~]       = compute_TFRs(antiinVF);
% [TFR_antioutVF, ~, ~]       = compute_TFRs(antioutVF);
% 
% cfg                                              = [];
% cfg.operation                                    = '(10^(x1/10) - 10^(x2/10)) / (10^(x1/10) + 10^(x2/10))';
% cfg.parameter                                    = 'powspctrm';
% pro_contrast                                       = ft_math(cfg, TFR_proinVF, TFR_prooutVF);
% 
% 
% cfg                                              = []; 
% cfg.layout                                       = 'acticap-64_md.mat'; 
% cfg.figure                                       = 'gcf';
% %cfg.style                                        = 'straight';
% freqband = 'alpha';
% if strcmp(freqband, 'alpha')
%     cfg.ylim                                     = [8 12]; 
% elseif strcmp(freqband, 'beta')
%     cfg.ylim                                     = [13 30];
% elseif strcmp(freqband, 'gamma')
%     cfg.ylim                                     = [30 50];
% end
% cfg.colorbar                                     = 'yes'; 
% cfg.comment                                      = 'no'; 
% cfg.colormap                                     = '*RdBu'; 
% cfg.marker                                       = 'on';
% %cfg.zlim                                         = [min_pow max_pow];
% cfg.interpolatenan                               = 'no';
% 
% subplot(2, 2, 1)
% cfg.xlim                                         = [0.5 1.5];
% cfg.title                                        = [freqband ' @ 0.5:1.5s'];
% ft_topoplotTFR(cfg, pro_contrast)
% subplot(2, 2, 2)
% cfg.xlim                                         = [1.5 2.5];
% cfg.title                                        = [freqband ' @ 1.5:2.5s'];
% ft_topoplotTFR(cfg, pro_contrast)
% subplot(2, 2, 3)
% cfg.xlim                                         = [3 3.5];
% cfg.title                                        = [freqband ' @ 2.8:3.3s'];
% ft_topoplotTFR(cfg, pro_contrast)
% subplot(2, 2, 4)
% cfg.xlim                                         = [3.5 4.5];
% cfg.title                                        = [freqband ' @ 3.5:4.5s'];
% ft_topoplotTFR(cfg, pro_contrast)
disp('Woosh! That was a lot of work.')
end
