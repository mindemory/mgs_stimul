function A03_PreprocEEG_TMS(subjID, day)
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
if day == NoTMSDays(subjID) % If this is a No TMS day
    steps = {'concat', 'raweeg', 'bandpass', 'reepoch', 'erp', 'tfr', 'tfr_induced'};
else % if this is a TMS day
    steps = {'concat', 'raweeg', 'remove_pulse', 'bandpass', 'reepoch', 'erp', 'tfr', 'tfr_induced'};
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
fName.bandpass                  = [fName.general '_bandpass.mat'];
fName.bandpass_TMS              = [fName.general '_bandpass_TMS.mat'];
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

cfg                           = [];
cfg.dataset                   = fName.concat;
cfg.continuous                = 'yes';
% cfg.hpfilter                  = 'yes';
% cfg.hpfilttype                = 'firws';
% cfg.hpfiltdir                 = 'onepass-zerophase';
% cfg.hpfreq                    = 0.5;
cfg.bpfilter                  = 'yes';
cfg.bpfreq                    = [0.5 50];
cfg.bpfilttype                = 'but';
cfg.bpfiltord                 = 4; 
cfg.bpfiltdir                 = 'twopass'; 
cfg.channel                   = {'all', '-LM', '-RM', '-TP9', '-TP10'};
raw_data                      = ft_preprocessing(cfg);

cfg                           = [];
cfg.dataset                   = fName.concat;
cfg.continuous                = 'yes';
cfg.trialdef.prestim          = 0.5;
cfg.trialdef.poststim         = 5.5;
cfg.trialdef.eventtype        = 'Stimulus';
cfg.trialdef.eventvalue       = {'S  1'};
cfg                           = ft_definetrial(cfg);
cfg_new                       = [];
cfg_new.trl                   = cfg.trl;
trl_info                      = cfg.trl;
raw_epoc                      = ft_redefinetrial(cfg_new, raw_data);
cfg                           = [];
if ~isempty(trls_to_remove)
    cfg.trials                = setdiff(1:length(raw_epoc.trialinfo), trls_to_remove);
    trl_info                  = trl_info(cfg.trials, :);
end
raw_epoc                      = ft_selectdata(cfg, raw_epoc);

thresh = [];
thresh.pval = 90;
thresh.prop_badtrials = 0.25;
ch_names = raw_data.label;
tseries = raw_data.trial{1};
ch_std = std(tseries, 0, 2);
ch_med = median(ch_std);
rej_thresh = prctile(abs(ch_std - ch_med), thresh.pval);
bad_ch1 = ch_names(abs(ch_std - ch_med)>rej_thresh);
ntrials = length(raw_epoc.trialinfo);
nchans = length(ch_names);
flagged_data = zeros(ntrials, nchans);
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

% cfg                           = [];
% cfg.dataset                   = fName.concat;
% cfg.continuous                = 'yes';
% % cfg.hpfilter                  = 'yes';
% % cfg.hpfilttype                = 'firws';
% % cfg.hpfiltdir                 = 'onepass-zerophase';
% % cfg.hpfreq                    = 1;
% % cfg.lpfilter                  = 'yes';
% % cfg.lpfilttype                = 'firws';
% % cfg.lpfiltdir                 = 'onepass-zerophase';
% % cfg.lpfreq                    = 55;
% cfg.bpfilter = 'yes';
% cfg.bpfreq = [0.1 50];
% cfg.bpfilttype = 'but';
% cfg.bpfiltord = 4; 
% cfg.bpfiltdir = 'twopass'; 
% cfg.channel                   = {'all', '-LM', '-RM', '-TP9', '-TP10'};
% raw_data                      = ft_preprocessing(cfg);

cfg                           = [];
cfg.channel                   = setdiff(ch_names, bad_ch);
raw_cleaned                   = ft_selectdata(cfg, raw_data);

cfg                           = [];
cfg.implicitref               = 'Cz';
cfg.reref                     = 'yes';
cfg.refchannel                = 'all';
cfg.refmethod                 = 'avg';
raw_cleaned_reref             = ft_preprocessing(cfg, raw_cleaned);

cfg = []; cfg.method = 'fastica';
cfg.randomseed = 42;
ica_comp = ft_componentanalysis(cfg, raw_cleaned_reref);

cfg = [];  cfg.component = 1:length(ica_comp.label); cfg.layout = 'acticap-64_md.mat'; cfg.comment = 'no';
ft_topoplotIC(cfg, ica_comp)

cfg = [];
cfg.layout = 'acticap-64_md.mat'; % specify the layout file that should be used for plotting
cfg.viewmode = 'component';
ft_databrowser(cfg, ica_comp)

cfg = [];
cfg.component = [30 39];
raw_ica_cleaned = ft_rejectcomponent(cfg, ica_comp, raw_cleaned_reref);

cfg = []; cfg.viewmode = 'vertical';
ft_databrowser(cfg, raw_cleaned_reref)
ft_databrowser(cfg, raw_ica_cleaned)


% Interpolate bad channels
load('helper/neighbors.mat');
% Interpolate bad channels
cfg_chanrepair                     = [];
cfg_chanrepair.badchannel          = bad_ch;
cfg_chanrepair.method              = 'weighted';
cfg_chanrepair.neighbours          = neighbors;
cfg_chanrepair.layout              = 'acticap-64_md.mat';
cfg_chanrepair.senstype            = 'eeg';
raw_new                            = ft_channelrepair(cfg_chanrepair,raw_ica_cleaned);
    
proinVF = create_epochs(fName, 'S 11', raw_new);
prooutVF = create_epochs(fName, 'S 12', raw_new);
antiinVF = create_epochs(fName, 'S 13', raw_new);
antioutVF = create_epochs(fName, 'S 14', raw_new);

[erp_proinVF, erp_prooutVF]          = compute_ERPs(proinVF, prooutVF);
[erp_antioutVF, erp_antioutVF]       = compute_ERPs(antiinVF, antioutVF);

[TFR_proinVF, ~, ~]       = compute_TFRs(proinVF);
[TFR_prooutVF, ~, ~]       = compute_TFRs(prooutVF);
[TFR_antiinVF, ~, ~]       = compute_TFRs(antiinVF);
[TFR_antioutVF, ~, ~]       = compute_TFRs(antioutVF);

cfg                                              = [];
cfg.operation                                    = '(10^(x1/10) - 10^(x2/10)) / (10^(x1/10) + 10^(x2/10))';
cfg.parameter                                    = 'powspctrm';
pro_contrast                                       = ft_math(cfg, TFR_proinVF, TFR_prooutVF);


cfg                                              = []; 
cfg.layout                                       = 'acticap-64_md.mat'; 
cfg.figure                                       = 'gcf';
%cfg.style                                        = 'straight';
freqband = 'alpha';
if strcmp(freqband, 'alpha')
    cfg.ylim                                     = [8 12]; 
elseif strcmp(freqband, 'beta')
    cfg.ylim                                     = [13 30];
elseif strcmp(freqband, 'gamma')
    cfg.ylim                                     = [30 50];
end
cfg.colorbar                                     = 'yes'; 
cfg.comment                                      = 'no'; 
cfg.colormap                                     = '*RdBu'; 
cfg.marker                                       = 'on';
%cfg.zlim                                         = [min_pow max_pow];
cfg.interpolatenan                               = 'no';

subplot(2, 2, 1)
cfg.xlim                                         = [0.5 1.5];
cfg.title                                        = [freqband ' @ 0.5:1.5s'];
ft_topoplotTFR(cfg, pro_contrast)
subplot(2, 2, 2)
cfg.xlim                                         = [1.5 2.5];
cfg.title                                        = [freqband ' @ 1.5:2.5s'];
ft_topoplotTFR(cfg, pro_contrast)
subplot(2, 2, 3)
cfg.xlim                                         = [3 3.5];
cfg.title                                        = [freqband ' @ 2.8:3.3s'];
ft_topoplotTFR(cfg, pro_contrast)
subplot(2, 2, 4)
cfg.xlim                                         = [3.5 4.5];
cfg.title                                        = [freqband ' @ 3.5:4.5s'];
ft_topoplotTFR(cfg, pro_contrast)

% cfg_new = [];
% cfg_new.trl = trlproinVF_info;
% proinVF = ft_redefinetrial(cfg_new, raw_new);
% cfg_new.trl = trlprooutVF_info;
% prooutVF = ft_redefinetrial(cfg_new, raw_new);
% cfg_new.trl = trlantiinVF_info;
% antiinVF = ft_redefinetrial(cfg_new, raw_new);
% cfg_new.trl = trlantioutVF_info;
% antioutVF = ft_redefinetrial(cfg_new, raw_new);


%% Reading segmented data
% stim-locked: 
%   'S 11': prointoVF
%   'S 12': prooutVF
%   'S 13': antiintoVF
%   'S 14': antioutVF
% fixation: 1s
% sample: 0.5s
% delay1: 2s
% delay2: 2s% response: 0.85s
% feedback: 0.8s
% iti: 1/2s
if any(strcmp(steps, 'raweeg'))
    if ~exist(fName.bandpass, 'file')
        % Reading segmented data
        disp('Reading segmented data.')
        cfg                           = [];
        cfg.dataset                   = fName.concat;
        cfg.trialdef.prestim          = 1.5;
        cfg.trialdef.poststim         = 5.5;
        cfg.trialdef.eventtype        = 'Stimulus';
        cfg.trialdef.eventvalue       = {'S 11', 'S 12', 'S 13', 'S 14'};
        cfg                           = ft_definetrial(cfg);
        cfg.continuous                = 'yes';
        cfg.channel                   = {'all', '-LM', '-RM', '-TP9', '-TP10'};
        data_eeg                      = ft_preprocessing(cfg);
        
        % Removing bad trials with timing issues
        cfg                           = [];
        if ~isempty(trls_to_remove)
            cfg.trials                = setdiff(1:length(data_eeg.trialinfo), trls_to_remove);
        end
        data_eeg                      = ft_selectdata(cfg, data_eeg);
    end
end


%% Remove TMS pulse from data
if any(strcmp(steps, 'remove_pulse'))
    if ~exist(fName.bandpass, 'file') 
        % Remove TMS pulse
        disp('Removing pulse and interpolating the data between.')
        cfg                                    = [];
        cfg.dataset                            = fName.concat;
        cfg.continuous                         = 'yes';
        cfg.trialdef.prestim                   = 1.5;
        cfg.trialdef.poststim                  = 5.5;
        cfg.trialdef.eventtype                 = 'Stimulus';
        cfg.trialdef.eventvalue                = {'S 11', 'S 12', 'S 13', 'S 14'};
        cfg                                    = ft_definetrial(cfg);
        orig_trl                               = cfg.trl;

        cfg                                    = [];
        cfg.dataset                            = fName.concat;
        cfg.method                             = 'marker';
        cfg.prestim                            = -2.5;
        cfg.poststim                           = 2.8;
        cfg.trialdef.eventtype                 = 'Stimulus';
        cfg.trialdef.eventvalue                = {'S 11', 'S 12', 'S 13', 'S 14'};
        cfg_ringing                            = ft_artifact_tms(cfg);

        cfg_art                                = [];
        cfg_art.dataset                        = fName.concat;
        cfg_art.artfctdef.ringing.artifact     = cfg_ringing.artfctdef.tms.artifact;
        cfg_art.artfctdef.reject               = 'partial';
        cfg_art.trl                            = orig_trl;
        cfg_art.artfctdef.minaccepttim         = 1;
        cfg                                    = ft_rejectartifact(cfg_art);
        data_eeg                               = ft_preprocessing(cfg);

        cfg                                    = [];
        cfg.channel                            = setdiff(data_eeg.label, {'LM', 'RM'});
        data_eeg                               = ft_selectdata(cfg, data_eeg);

        cfg                                    = [];
        cfg.trl                                = orig_trl;
        data_eeg                               = ft_redefinetrial(cfg, data_eeg);

        cfg                                    = [];
        if ~isempty(trls_to_remove)
            cfg.trials                         = setdiff(1:length(data_eeg.trialinfo), trls_to_remove);
        end
        data_eeg                               = ft_selectdata(cfg, data_eeg);

        cfg                                    = [];
        cfg.method                             = 'pchip';
        cfg.prewindow                          = 0.1;
        cfg.postwindow                         = 0.1;
        data_eeg                               = ft_interpolatenan(cfg, data_eeg);
   end
end

%% Bandpass filter
if any(strcmp(steps, 'bandpass'))
    if ~exist(fName.bandpass, 'file') && ~exist(fName.bandpass_TMS, 'file')
        disp('Bandpass filtered data does not exist. Applying band pass filter.')
        data_eeg                               = RunBandPass(data_eeg);
        save(fName.bandpass, 'data_eeg', '-v7.3')
%         if day                                 ~= NoTMSDays(subjID)
%             data_tms                           = RunBandPass(data_eeg);
%             save(fName.bandpass_TMS, 'data_tms', '-v7.3')
%         end
    else
        disp('Bandpass file exists, importing mat file.')
        load(fName.bandpass)
%         if day                                 ~= NoTMSDays(subjID)
%             load(fName.bandpass_TMS)
%         end
    end
end




%% Artifact rejection
art_run                    = 0;%input('Do you want to trial and channel rejection? (1: rejvisual, 2: databroswer, 0: No): ');
if art_run                 == 1
    disp('Loading epoched data for all trials.')
    if day == NoTMSDays(subjID) % If this is a No TMS day
        %load(fName.bandpass)
        cfg                    = [];
        ft_rejectvisual(cfg, data_eeg)
    else % if this is a TMS day
        %load(fName.bandpass_TMS)
        cfg                    = [];
        ft_rejectvisual(cfg, data_tms)
    end
    
elseif art_run             == 2
    disp('Loading epoched data for all trials.')
    if day == NoTMSDays(subjID) % If this is a No TMS day
        %load(fName.bandpass)
        cfg                    = [];
        cfg.viewmode           = 'vertical';
        cfg.channel            = union(left_occ_elecs, right_occ_elecs);
        ft_databrowser(cfg, data_eeg);

        cfg = []; cfg.preproc.demean = 'yes'; cfg.keeptrials = 'no';
        data_eeg_avg = ft_timelockanalysis(cfg, data_eeg);
        cfg = []; cfg.viewmode = 'vertical'; 
        ft_databrowser(cfg, data_eeg_avg);
        
        cfg                    = [];
        cfg.viewmode           = 'butterfly';
        %cfg.trl                = sampleinfo(union(find(data_tms.trialinfo ==11), find(data_tms.trialinfo == 12)), :);
        cfg.channel            = union(left_occ_elecs, right_occ_elecs);
        ft_databrowser(cfg, data_eeg);
    else % if this is a TMS day
        %load(fName.bandpass_TMS)
        cfg = []; cfg.preproc.demean = 'yes'; cfg.keeptrials = 'no';
        data_tms_avg = ft_timelockanalysis(cfg, data_tms);

        cfg = []; cfg.viewmode = 'vertical'; 
        ft_databrowser(cfg, data_tms_avg);

        cfg                            = [];
        cfg.viewmode                   = 'butterfly';
        %cfg.trl                = sampleinfo(union(find(data_tms.trialinfo ==11), find(data_tms.trialinfo == 12)), :);
        cfg.channel                    = union(left_occ_elecs, right_occ_elecs);
        ft_databrowser(cfg, data_tms);
    end
    
elseif art_run                         == 0
    disp('You selected to skip artifact-rejection. Make sure that downstream analysis is interpreted accordingly.')
else
    disp('Invalid input! Skipping artifact-rejection.')
end

[flg_trls, flg_chans]                  = flagged_trls_chans(subjID, day);

%% Independent Component Analysis
% Added by Mrugank (09/11/2023): The goal was to remove eye-blink, muscle
% and cardiac artifacts from the data as well as the decaying artifact in
% TMS datasets. However, this is still is work in progress and has not been
% used for analyzing any of the data so far.
if any(strcmp(steps, 'ica'))
    if ~exist(fName.ica, 'file')
        % Running ICA
        disp('ICA does not exist. Creating mat file.')
        cfg                            = [];
        cfg.demean                     = 'yes';
        cfg.method                     = 'fastica';
        cfg.fastica.approach           = 'symm';
        cfg.fastica.g                  = 'gauss';
        comp_tms                       = ft_componentanalysis(cfg, data_tms_segmented_delay);
        save(fName.ica, 'comp_tms', '-v7.3')
    else
        if ~exist(fName.interp, 'file')
            disp('ICA file exists, importing mat file.')
            load(fName.ica)
        else
            disp('ICA file exists, but not loading it.')
        end
    end
end

%% Interpolate bad channels and rereference
if ~exist(fName.TFR, 'file')
    if ~isempty(flg_chans) 
        disp('The flagged channels will be reinterpolated before running furhter analyses.')
        % Create a neighbor template
        cfg_neighbor                       = [];
        cfg_neighbor.method                = 'triangulation';
        cfg_neighbor.compress              = 'yes';
        cfg_neighbor.layout                = 'acticap-64_md.mat';
        cfg_neighbor.feedback              = 'no';
        neighbors                          = ft_prepare_neighbours(cfg_neighbor, data_eeg);
    
        % Interpolate bad channels
        cfg_chanrepair                     = [];
        cfg_chanrepair.badchannel          = flg_chans;
        cfg_chanrepair.method              = 'spline';
        cfg_chanrepair.neighbours          = neighbors;
        cfg_chanrepair.layout              = 'acticap-64_md.mat';
        cfg_chanrepair.senstype            = 'eeg';
        data_eeg                           = ft_channelrepair(cfg_chanrepair,data_eeg);
    
        % Do the same for TMS artifact cleared data
        if day ~= NoTMSDays(subjID)
            data_tms                       = ft_channelrepair(cfg_chanrepair,data_tms);
        end 
    end
end

%% Re-epoching and eliminating bad trials
if any(strcmp(steps, 'reepoch'))
    if ~exist(fName.TFR_induced, 'file') 
        disp('Re-epoching and eliminating bad trials')
        %load(fName.bandpass)
        %good_channels = setdiff(data_eeg.label, flg_chans);
        %load([p.save '/EEGflags.mat'])
        %valid_flags = [11, 12, 13, 14];
        %trl_sequence = flags.num(ismember(flags.num, valid_flags));

        % Re-reference data to CAR
        cfg                            = [];
        cfg.reref                      = 'yes';
        cfg.refchannel                 = 'all';
        cfg.refmethod                  = 'avg';
        data_eeg                       = ft_preprocessing(cfg, data_eeg);
    
        % Do the same for TMS artifact cleared data
        if day ~= NoTMSDays(subjID)
            data_tms                   = ft_preprocessing(cfg, data_tms);
        end 
        
        % Select good trials for each epoched data type
        cfg                            = [];
        cfg.channel                    = 'all';
        
        % good epoc prointoVF
        prointoVF_trls                 = find(data_eeg.trialinfo == 11);
        cfg.trials                     = setdiff(prointoVF_trls, flg_trls);
        epoc_prointoVF                 = ft_selectdata(cfg, data_eeg);
        if day                         ~= NoTMSDays(subjID)
            tms_epoc_prointoVF         = ft_selectdata(cfg, data_tms);
        end 
        
        % good epoc prooutVF
        prooutVF_trls                  = find(data_eeg.trialinfo == 12);
        cfg.trials                     = setdiff(prooutVF_trls, flg_trls);
        epoc_prooutVF                  = ft_selectdata(cfg, data_eeg);
        if day                         ~= NoTMSDays(subjID)
            tms_epoc_prooutVF          = ft_selectdata(cfg, data_tms);
        end 
        
        % good epoc antiintoVF
        antiintoVF_trls                = find(data_eeg.trialinfo == 13);
        cfg.trials                     = setdiff(antiintoVF_trls, flg_trls);
        epoc_antiintoVF                = ft_selectdata(cfg, data_eeg);
        if day                         ~= NoTMSDays(subjID)
            tms_epoc_antiintoVF        = ft_selectdata(cfg, data_tms);
        end 

        % good epoc antioutVF
        antioutVF_trls                 = find(data_eeg.trialinfo == 14);
        cfg.trials                     = setdiff(antioutVF_trls, flg_trls);
        epoc_antioutVF                 = ft_selectdata(cfg, data_eeg);
        if day                         ~= NoTMSDays(subjID)
            tms_epoc_antioutVF         = ft_selectdata(cfg, data_tms);
        end 
    end
end

%% Event-related potentials (CDA)
if any(strcmp(steps, 'erp'))
    if ~exist(fName.erp, 'file')
        disp('Computing event-related potentials')
        [ERP.prointoVF, ERP.prooutVF]                   = compute_ERPs(epoc_prointoVF, epoc_prooutVF);
        [ERP.antiintoVF, ERP.antioutVF]                 = compute_ERPs(epoc_antiintoVF, epoc_antioutVF);
        save(fName.erp, 'ERP', '-v7.3')

        if day                                          ~= NoTMSDays(subjID)
            [TMS_ERP.prointoVF, TMS_ERP.prooutVF]       = compute_ERPs(tms_epoc_prointoVF, tms_epoc_prooutVF);
            [TMS_ERP.antiintoVF, TMS_ERP.antioutVF]     = compute_ERPs(tms_epoc_antiintoVF, tms_epoc_antioutVF);
            save(fName.tms_erp, 'TMS_ERP', '-v7.3')
        end
    end
end

% cfg = [];
% cfg.channel = left_occ_elecs;
% cfg.figure = 'gcf';
% cfg.xlim = [0 4.5];
% figure();
% subplot(2, 2, 1)
% ft_singleplotER(cfg, ERP.prointoVF)
% subplot(2, 2, 2)
% ft_singleplotER(cfg, ERP.antiintoVF)
% subplot(2, 2, 3)
% ft_singleplotER(cfg, ERP.prooutVF)
% subplot(2, 2, 4)
% ft_singleplotER(cfg, ERP.antioutVF)
% 
% cfg = [];
% cfg.channel = left_occ_elecs;
% cfg.figure = 'gcf';
% cfg.xlim = [0 4.5];
% figure();
% subplot(2, 2, 1)
% ft_singleplotER(cfg, TMS_ERP.prointoVF)
% subplot(2, 2, 2)
% ft_singleplotER(cfg, TMS_ERP.antiintoVF)
% subplot(2, 2, 3)
% ft_singleplotER(cfg, TMS_ERP.prooutVF)
% subplot(2, 2, 4)
% ft_singleplotER(cfg, TMS_ERP.antioutVF)
%% Time-Frequency Analysis (TFA)
if any(strcmp(steps, 'tfr'))
   if ~exist(fName.TFR, 'file') 
        disp('Running time-frequency analysis')
        [POW.prointoVF, ITC.prointoVF, PHASE.prointoVF]          = compute_TFRs(epoc_prointoVF, 1);
        [POW.prooutVF, ITC.prooutVF, PHASE.prooutVF]             = compute_TFRs(epoc_prooutVF, 1);
        [POW.antiintoVF, ITC.antiintoVF, PHASE.antiintoVF]       = compute_TFRs(epoc_antiintoVF, 1);
        [POW.antioutVF, ITC.antioutVF, PHASE.antioutVF]          = compute_TFRs(epoc_antioutVF, 1);
        save(fName.TFR, 'POW', 'ITC', 'PHASE', '-v7.3')

        if day                                                                ~= NoTMSDays(subjID)
            [TMSPOW.prointoVF, TMSITC.prointoVF, TMSPHASE.prointoVF]          = compute_TFRs(tms_epoc_prointoVF, 1);
            [TMSPOW.prooutVF, TMSITC.prooutVF, TMSPHASE.prooutVF]             = compute_TFRs(tms_epoc_prooutVF, 1);
            [TMSPOW.antiintoVF, TMSITC.antiintoVF, TMSPHASE.antiintoVF]       = compute_TFRs(tms_epoc_antiintoVF, 1);
            [TMSPOW.antioutVF, TMSITC.antioutVF, TMSPHASE.antioutVF]          = compute_TFRs(tms_epoc_antioutVF, 1);
            save(fName.TMS_TFR, 'TMSPOW', 'TMSITC', 'TMSPHASE', '-v7.3')
        end
   end
end

%% Time-Frequency Analysis (TFA)
if any(strcmp(steps, 'tfr_induced'))
   if ~exist(fName.TFR_induced, 'file') 
        disp('Running time-frequency analysis')
        [ERP.prointoVF, ERP.prooutVF]                            = compute_ERPs(epoc_prointoVF, epoc_prooutVF);
        [ERP.antiintoVF, ERP.antioutVF]                          = compute_ERPs(epoc_antiintoVF, epoc_antioutVF);
        epoc_prointoVF_minus_ERP                                 = epoc_prointoVF;
        for k = 1:numel(epoc_prointoVF.trial)
            epoc_prointoVF_minus_ERP.trial{k}                    = epoc_prointoVF.trial{k} - ERP.prointoVF.avg;
        end
        epoc_prooutVF_minus_ERP                                  = epoc_prooutVF;
        for k = 1:numel(epoc_prooutVF.trial)
            epoc_prooutVF_minus_ERP.trial{k}                     = epoc_prooutVF.trial{k} - ERP.prooutVF.avg;
        end
        epoc_antiintoVF_minus_ERP                                = epoc_antiintoVF;
        for k = 1:numel(epoc_antiintoVF.trial)
            epoc_antiintoVF_minus_ERP.trial{k}                   = epoc_antiintoVF.trial{k} - ERP.antiintoVF.avg;
        end
        epoc_antioutVF_minus_ERP                                 = epoc_antioutVF;
        for k = 1:numel(epoc_antioutVF.trial)
            epoc_antioutVF_minus_ERP.trial{k}                    = epoc_antioutVF.trial{k} - ERP.antioutVF.avg;
        end
        [POW.prointoVF, ITC.prointoVF, PHASE.prointoVF]          = compute_TFRs(epoc_prointoVF_minus_ERP, 1);
        [POW.prooutVF, ITC.prooutVF, PHASE.prooutVF]             = compute_TFRs(epoc_prooutVF_minus_ERP, 1);
        [POW.antiintoVF, ITC.antiintoVF, PHASE.antiintoVF]       = compute_TFRs(epoc_antiintoVF_minus_ERP, 1);
        [POW.antioutVF, ITC.antioutVF, PHASE.antioutVF]          = compute_TFRs(epoc_antioutVF_minus_ERP, 1);
        save(fName.TFR_induced, 'POW', 'ITC', 'PHASE', '-v7.3')

        if day                                                                ~= NoTMSDays(subjID)
            [TMS_ERP.prointoVF, TMS_ERP.prooutVF]                              = compute_ERPs(tms_epoc_prointoVF, tms_epoc_prooutVF);
            [TMS_ERP.antiintoVF, TMS_ERP.antioutVF]                            = compute_ERPs(tms_epoc_antiintoVF, tms_epoc_antioutVF);
            TMSepoc_prointoVF_minus_ERP                                 = tms_epoc_prointoVF;
            for k = 1:numel(tms_epoc_prointoVF.trial)
                TMSepoc_prointoVF_minus_ERP.trial{k}                    = tms_epoc_prointoVF.trial{k} - TMS_ERP.prointoVF.avg;
            end
            TMSepoc_prooutVF_minus_ERP                                  = tms_epoc_prooutVF;
            for k = 1:numel(tms_epoc_prooutVF.trial)
                TMSepoc_prooutVF_minus_ERP.trial{k}                     = tms_epoc_prooutVF.trial{k} - TMS_ERP.prooutVF.avg;
            end
            TMSepoc_antiintoVF_minus_ERP                                = tms_epoc_antiintoVF;
            for k = 1:numel(tms_epoc_antiintoVF.trial)
                TMSepoc_antiintoVF_minus_ERP.trial{k}                   = tms_epoc_antiintoVF.trial{k} - TMS_ERP.antiintoVF.avg;
            end
            TMSepoc_antioutVF_minus_ERP                                 = tms_epoc_antioutVF;
            for k = 1:numel(tms_epoc_antioutVF.trial)
                TMSepoc_antioutVF_minus_ERP.trial{k}                    = tms_epoc_antioutVF.trial{k} - TMS_ERP.antioutVF.avg;
            end
            [TMSPOW.prointoVF, TMSITC.prointoVF, TMSPHASE.prointoVF]          = compute_TFRs(TMSepoc_prointoVF_minus_ERP, 1);
            [TMSPOW.prooutVF, TMSITC.prooutVF, TMSPHASE.prooutVF]             = compute_TFRs(TMSepoc_prooutVF_minus_ERP, 1);
            [TMSPOW.antiintoVF, TMSITC.antiintoVF, TMSPHASE.antiintoVF]       = compute_TFRs(TMSepoc_antiintoVF_minus_ERP, 1);
            [TMSPOW.antioutVF, TMSITC.antioutVF, TMSPHASE.antioutVF]          = compute_TFRs(TMSepoc_antioutVF_minus_ERP, 1);
            save(fName.TMS_TFR_induced, 'TMSPOW', 'TMSITC', 'TMSPHASE', '-v7.3')
        end
   end
end
%% Testing here
% cfg = [];
% cfg.avgoverrpt = 'yes';
% avgTFR_power_intoVF = ft_selectdata(cfg, TMSPOW.prointoVF);
% avgTFR_power_outVF = ft_selectdata(cfg, TMSPOW.prooutVF);
% cfg = [];
% cfg.operation = '(10^(x1/10) - 10^(x2/10)) / (10^(x1/10) + 10^(x2/10))';
% cfg.parameter = 'powspctrm';
% TFR_contrast = ft_math(cfg, avgTFR_power_intoVF, avgTFR_power_outVF);
% % cfg = [];
% % cfg.operation = '(x1-x2)';
% % cfg.parameter = 'itcspctrm';
% % itc_contrast = ft_math(cfg, ITC.prointoVF, ITC.prooutVF);
% 
% cfg = [];
% cfg.figure = 'gcf';
% cfg.channel = left_occ_elecs;
% cfg.ylim = [7 50];
% %cfg.zlim = [-2.5 2.5];
% figure();
% subplot(3, 2, 1)
% ft_singleplotTFR(cfg, avgTFR_power_intoVF);
% subplot(3, 2, 3)
% ft_singleplotTFR(cfg, avgTFR_power_outVF);
% subplot(3, 2, 5)
% ft_singleplotTFR(cfg, TFR_contrast);
% 
% cfg.channel = right_occ_elecs;
% subplot(3, 2, 2)
% ft_singleplotTFR(cfg, avgTFR_power_intoVF);
% subplot(3, 2, 4)
% ft_singleplotTFR(cfg, avgTFR_power_outVF);
% subplot(3, 2, 6)
% ft_singleplotTFR(cfg, TFR_contrast);
% 
% 
% cfg = [];
% cfg.operation = '(x1-x2)';
% cfg.parameter = 'itcspctrm';
% itc_contrast = ft_math(cfg, TMSITC.prointoVF, TMSITC.prooutVF);
% 
% cfg = [];
% cfg.figure = 'gcf';
% cfg.channel = left_occ_elecs;
% cfg.ylim = [7 50];
% cfg.parameter = 'itcspctrm';
% %cfg.zlim = [-2.5 2.5];
% figure();
% subplot(3, 2, 1)
% ft_singleplotTFR(cfg, TMSITC.prointoVF);
% subplot(3, 2, 3)
% ft_singleplotTFR(cfg, TMSITC.prooutVF);
% subplot(3, 2, 5)
% ft_singleplotTFR(cfg, itc_contrast);
% 
% cfg.channel = right_occ_elecs;
% subplot(3, 2, 2)
% ft_singleplotTFR(cfg, TMSITC.prointoVF);
% subplot(3, 2, 4)
% ft_singleplotTFR(cfg, TMSITC.prooutVF);
% subplot(3, 2, 6)
% ft_singleplotTFR(cfg, itc_contrast);
disp('Woosh! That was a lot of work.')
end
