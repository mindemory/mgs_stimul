function A03_PreprocEEG_TMS(subjID, day, steps)
clearvars -except subjID day steps; close all; clc;

%% Intialization
left_occ_elecs = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_occ_elecs = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

if nargin < 4
    steps = {'concat', 'raweeg', 'bandpass', 'epoch', 'rereference', 'tfr'};
end

p.subjID = num2str(subjID,'%02d');
p.day = day;

[p, taskMap] = initialization(p, 'eeg', 0);
meta_data = readtable([p.analysis '/EEG_TMS_meta - Summary.csv']);
load([p.analysis '/sub' num2str(subjID, '%02d') '/flagged_trls.mat'])
% Load flagged trials based on timing errors
block_flag = flg.block(flg.day == p.day);
trl_flag = flg.trls(flg.day == p.day);
trls_to_remove = (block_flag - 1) * 40 + trl_flag;

HemiStimulated = table2cell(meta_data(:, ["HemisphereStimulated"]));
NoTMSDays = table2array(meta_data(:, ["NoTMSDay"]));
if day == NoTMSDays(subjID) % If this is a No TMS day
    steps = {'concat', 'raweeg', 'bandpass', 'rereference', 'tfr'};
else % if this is a TMS day
    steps = {'concat', 'raweeg', 'remove_pulse', 'bandpass', 'rereference', 'rereference_tms', 'tfr'};
end
%EEGfile = ['sub' num2str(p.subjID, '%02d') '_day' num2str(p.day, '%02d') '_concat.vhdr'];

% List of files to be saved
% Step 1: Loading data 'subXX_dayXX_raweeg.mat'
% Step 2: Remove low frequency drifts 'subXX_dayXX_highpass.mat'
% Step 3: Epoch data 'subXX_dayXX_epoched.mat'

% File names
fName.folder = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/day' num2str(p.day, '%02d')];
if ~exist(fName.folder, 'dir')
    mkdir(fName.folder)
end
fName.general = [fName.folder '/sub' num2str(p.subjID, '%02d') '_day' num2str(p.day, '%02d')];
fName.concat = [fName.general '.vhdr'];
fName.load = [fName.general '_raweeg.mat'];
fName.removed_pulse_whole = [fName.general '_eeg_removed_pulse_whole.mat'];
fName.ica = [fName.general '_ica.mat'];
fName.interp = [fName.general '_interpolated.mat'];
fName.bandpass = [fName.general '_bandpass.mat'];
fName.bandpass_TMS = [fName.general '_bandpass_TMS.mat'];
fName.epoched_alltrls = [fName.general '_epoched_alltrls.mat'];
fName.epoched_prointoVF = [fName.general '_epoched_prointoVF.mat'];
fName.epoched_prooutVF = [fName.general '_epoched_prooutVF.mat'];
fName.epoched_antiintoVF = [fName.general '_epoched_antiintoVF.mat'];
fName.epoched_antioutVF = [fName.general '_epoched_antioutVF.mat'];
fName.freqmat_prointoVF = [fName.general '_freqmat_prointoVF.mat'];
fName.freqmat_prooutVF = [fName.general '_freqmat_prooutVF.mat'];
fName.freqmat_antiintoVF = [fName.general '_freqmat_antiintoVF.mat'];
fName.freqmat_antioutVF = [fName.general '_freqmat_antioutVF.mat'];

fName.tms_epoched_alltrls = [fName.general '_tms_epoched_alltrls.mat'];
fName.tms_epoched_prointoVF = [fName.general '_tms_epoched_prointoVF.mat'];
fName.tms_epoched_prooutVF = [fName.general '_tms_epoched_prooutVF.mat'];
fName.tms_epoched_antiintoVF = [fName.general '_tms_epoched_antiintoVF.mat'];
fName.tms_epoched_antioutVF = [fName.general '_tms_epoched_antioutVF.mat'];
fName.tms_freqmat_prointoVF = [fName.general '_tms_freqmat_prointoVF.mat'];
fName.tms_freqmat_prooutVF = [fName.general '_tms_freqmat_prooutVF.mat'];
fName.tms_freqmat_antiintoVF = [fName.general '_tms_freqmat_antiintoVF.mat'];
fName.tms_freqmat_antioutVF = [fName.general '_tms_freqmat_antioutVF.mat'];



%% Concatenate EEG data
if any(strcmp(steps, 'concat'))
    if ~exist(fName.concat, 'file')
        disp('Concatenated file does not exist. Concatenating EEG data.')
        tic
        ConcatEEG(p, fName);
        toc
    else
        disp('Concatenated file exists. Skipping this step.')
    end
end

%% Creating mat file from EEG data
if any(strcmp(steps, 'raweeg'))
    if ~exist(fName.load, 'file')
        % Importing data
        disp('Raw file does not exist. Creating mat file.')
        tic
        cfg = [];
        cfg.dataset = fName.concat;
        cfg.trialdef.prestim = 0;
        cfg.trialdef.poststim = 7;
        cfg.trialdef.eventtype = 'Stimulus';
        cfg.trialdef.eventvalue = {'S  1'};
        cfg = ft_definetrial(cfg);
        %orig_trl = cfg.trl;
        cfg.continuous = 'yes';
        data_eeg = ft_preprocessing(cfg);

        cfg = [];
        cfg.channel = setdiff(data_eeg.label, {'LM', 'RM'});
        if ~isempty(trls_to_remove)
            cfg.trials = setdiff(1:length(data_eeg.trialinfo), trls_to_remove);
        end
        data_eeg = ft_selectdata(cfg, data_eeg);
        toc
        save(fName.load, 'data_eeg', '-v7.3')
    else
        if ~exist(fName.bandpass, 'file')
            disp('Raw file exists, importing mat file.')
            load(fName.load)
        else
            disp('Raw file exists, but not loading it.')
        end
    end
end

%% Remove TMS pulse from data
if any(strcmp(steps, 'remove_pulse'))
    if ~exist(fName.bandpass, 'file') 
        % Remove TMS pulse
        disp('Removing pulse and interpolating the data between.')
        tic

        % Remove TMS pulse from whole trial
        cfg = [];
        cfg.dataset = fName.concat;
        cfg.continuous = 'yes';
        cfg.trialdef.prestim = 0;
        cfg.trialdef.poststim = 7;
        cfg.trialdef.eventtype = 'Stimulus';
        cfg.trialdef.eventvalue = {'S  1'};
        cfg = ft_definetrial(cfg);
        orig_trl = cfg.trl;

        cfg = [];
        cfg.dataset = fName.concat;
        cfg.method = 'marker';
        cfg.prestim = -3.5;
        cfg.poststim = 3.8;
        cfg.trialdef.eventtype = 'Stimulus';
        cfg.trialdef.eventvalue = {'S  1'};
        cfg_ringing = ft_artifact_tms(cfg);

        cfg_artifact = [];
        cfg_artifact.dataset = fName.concat;
        cfg_artifact.artfctdef.ringing.artifact = cfg_ringing.artfctdef.tms.artifact;
        cfg_artifact.artfctdef.reject = 'partial';
        cfg_artifact.trl = orig_trl;
        cfg_artifact.artfctdef.minaccepttim = 1;
        cfg = ft_rejectartifact(cfg_artifact);
        data_tms_segmented_whole = ft_preprocessing(cfg);

        cfg = [];
        cfg.channel = setdiff(data_tms_segmented_whole.label, {'LM', 'RM'});
        data_tms_segmented_whole = ft_selectdata(cfg, data_tms_segmented_whole);

        cfg = [];
        cfg.trl = orig_trl;
        data_tms_clean = ft_redefinetrial(cfg, data_tms_segmented_whole);

        cfg = [];
        if ~isempty(trls_to_remove)
            cfg.trials = setdiff(1:length(data_tms_clean.trialinfo), trls_to_remove);
        end
        data_tms_clean = ft_selectdata(cfg, data_tms_clean);

        cfg = [];
        cfg.method = 'pchip';
        cfg.prewindow = 0.1;
        cfg.postwindow = 0.1;
        data_tms_clean_interp = ft_interpolatenan(cfg, data_tms_clean);
        toc
    end
end

%% Independent Component Analysis
if any(strcmp(steps, 'ica'))
    if ~exist(fName.ica, 'file')
        % Running ICA
        disp('ICA does not exist. Creating mat file.')
        tic
        cfg = [];
        cfg.demean = 'yes';
        cfg.method = 'fastica';
        cfg.fastica.approach = 'symm';
        cfg.fastica.g = 'gauss';
        comp_tms = ft_componentanalysis(cfg, data_tms_segmented_delay);
        toc
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

% 
% cfg = []; cfg.preproc.demean = 'yes';
% data_eeg_avg = ft_timelockanalysis(cfg, data_tms);
% cfg = []; ft_databrowser(cfg, data_eeg_avg)
% cfg = [];
% ft_databrowser(cfg, data_tms_clean_interp)
%
% cfg = [];
% cfg.preproc.demean = 'yes';
% % cfg.preproc.baselinewindow = [-1 0];
% data_eeg_avg = ft_timelockanalysis(cfg, data_tms_clean_interp);
% cfg = [];
% ft_databrowser(cfg, data_eeg_avg)
%
%
% cfg = [];
% cfg.preproc.demean = 'yes';
% % cfg.preproc.baselinewindow = [-1 0];
% data_tms_avg = ft_timelockanalysis(cfg, data_tms_segmented_whole);
% cfg = [];
% ft_databrowser(cfg, data_tms_avg)
% channel = 'O2';
%
% figure;
% i = find(strcmp(channel, data_tms_avg.label));
% plot(data_tms_avg.time, data_tms_avg.avg(i,:));   % Plot data
% xlim([3.5 4.3]);    % Here we can specify the limits of what to plot on the x-axis
% ylim([-20 25]);      % Here we can specify the limits of what to plot on the y-axis
% title(['Channel ' data_tms_avg.label{i}]);
% ylabel('Amplitude (uV)')
% xlabel('Time (s)');
%
% cfg = [];
% comp_tms_avg = ft_timelockanalysis(cfg, comp_tms);
%
% figure;
% cfg = [];
% cfg.viewmode = 'butterfly';
% ft_databrowser(cfg, comp_tms_avg);
%
% figure;
% cfg           = [];
% cfg.component = [1:65];
% cfg.comment   = 'no';
% cfg.layout    = 'acticap-64_md.mat';
% ft_topoplotIC(cfg, comp_tms);

% cfg = [];
% cfg.layout = 'acticap-64_md.mat';
% cfg.viewmode = 'component';
% ft_databrowser(cfg, comp_tms)

%% Bandpass filter
if any(strcmp(steps, 'bandpass'))
    if ~exist(fName.bandpass, 'file') && ~exist(fName.bandpass_TMS, 'file')
        disp('Bandpass filtered data does not exist. Applying band pass filter.')
        tic
        if day == NoTMSDays(subjID)
            data_eeg = RunBandPass(data_eeg);
            toc
            save(fName.bandpass, 'data_eeg', '-v7.3')
        else
            data_tms = RunBandPass(data_tms_clean_interp);
            data_eeg = RunBandPass(data_eeg);
            toc
            save(fName.bandpass_TMS, 'data_tms', '-v7.3')
            save(fName.bandpass, 'data_eeg', '-v7.3')
        end
    else
        if ~exist(fName.freqmat_prointoVF, 'file')
            disp('Bandpass file exists, importing mat file.')
            if day == NoTMSDays(subjID)
                load(fName.bandpass)
            else
                load(fName.bandpass)
                load(fName.bandpass_TMS)
            end
        else
            disp('Bandpass file exists, but not loading it.')
        end
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
    else % if this is a TMS day
        %load(fName.bandpass_TMS)
        cfg                    = [];
        cfg.viewmode           = 'vertical';
        cfg.channel            = union(left_occ_elecs, right_occ_elecs);
        ft_databrowser(cfg, data_tms);
    end
    
elseif art_run             == 0
    disp('You selected to skip artifact-rejection. Make sure that downstream analysis is interpreted accordingly.')
else
    disp('Invalid input! Skipping artifact-rejection.')
end

[flg_trls, flg_chans] = flagged_trls_chans(subjID, day);
%% Re-epoching data and re-referencing to CAR
if any(strcmp(steps, 'rereference'))
    if ~exist(fName.freqmat_prointoVF, 'file') || ~exist(fName.freqmat_prooutVF, 'file') || ...
            ~exist(fName.freqmat_antiintoVF, 'file') || ~exist(fName.freqmat_antioutVF, 'file')
        disp('Re-epoching and re-referencing')
        tic
        %load(fName.bandpass)
        good_channels = setdiff(data_eeg.label, flg_chans);
        load([p.save '/EEGflags.mat'])
        valid_flags = [11, 12, 13, 14];
        trl_sequence = flags.num(ismember(flags.num, valid_flags));

        % Select good trials and good channels for each epoched data type
        % prointoVF
        cfg = [];
        cfg.channel = good_channels;
        cfg_reref = [];
        cfg_reref.reref = 'yes';
        cfg_reref.refchannel = 'all';
        cfg_reref.implicitref = 'Cz';
        % good epoc prointoVF
        prointoVF_trls = find(trl_sequence == 11);
        prointoVF_mask = ismember(prointoVF_trls, flg_trls);
        prointoVF_trls(prointoVF_mask) = 0;
        cfg.trials = find(prointoVF_trls ~= 0);
        epoc_prointoVF = ft_selectdata(cfg, data_eeg);
        epoc_prointoVF = ft_preprocessing(cfg_reref, epoc_prointoVF);
        % good epoc prooutVF
        prooutVF_trls = find(trl_sequence == 12);
        prooutVF_mask = ismember(prooutVF_trls, flg_trls);
        prooutVF_trls(prooutVF_mask) = 0;
        cfg.trials = find(prooutVF_trls ~= 0);
        epoc_prooutVF = ft_selectdata(cfg, data_eeg);
        epoc_prooutVF = ft_preprocessing(cfg_reref, epoc_prooutVF);
        % good epoc antiintoVF
        antiintoVF_trls = find(trl_sequence == 13);
        antiintoVF_mask = ismember(antiintoVF_trls, flg_trls);
        antiintoVF_trls(antiintoVF_mask) = 0;
        cfg.trials = find(antiintoVF_trls ~= 0);
        epoc_antiintoVF = ft_selectdata(cfg, data_eeg);
        epoc_antiintoVF = ft_preprocessing(cfg_reref, epoc_antiintoVF);
        % good epoc prooutVF
        antioutVF_trls = find(trl_sequence == 14);
        antioutVF_mask = ismember(antioutVF_trls, flg_trls);
        antioutVF_trls(antioutVF_mask) = 0;
        cfg.trials = find(antioutVF_trls ~= 0);
        epoc_antioutVF = ft_selectdata(cfg, data_eeg);
        epoc_antioutVF = ft_preprocessing(cfg_reref, epoc_antioutVF);
        toc
    end
end

if any(strcmp(steps, 'rereference_tms'))
    if ~exist(fName.freqmat_prointoVF, 'file') || ~exist(fName.freqmat_prooutVF, 'file') || ...
            ~exist(fName.freqmat_antiintoVF, 'file') || ~exist(fName.freqmat_antioutVF, 'file')
        disp('Re-epoching and re-referencing')
        tic
        %load(fName.bandpass_TMS)
        good_channels = setdiff(data_tms.label, flg_chans);
        load([p.save '/EEGflags.mat'])
        valid_flags = [11, 12, 13, 14];
        trl_sequence = flags.num(ismember(flags.num, valid_flags));

        % Select good trials and good channels for each epoched data type
        % prointoVF
        cfg = [];
        cfg.channel = good_channels;
        cfg_reref = [];
        cfg_reref.reref = 'yes';
        cfg_reref.refchannel = 'all';
        cfg_reref.implicitref = 'Cz';
        % good epoc prointoVF
        prointoVF_trls = find(trl_sequence == 11);
        prointoVF_mask = ismember(prointoVF_trls, flg_trls);
        prointoVF_trls(prointoVF_mask) = 0;
        cfg.trials = find(prointoVF_trls ~= 0);
        tms_epoc_prointoVF = ft_selectdata(cfg, data_tms);
        tms_epoc_prointoVF = ft_preprocessing(cfg_reref, tms_epoc_prointoVF);
        % good epoc prooutVF
        prooutVF_trls = find(trl_sequence == 12);
        prooutVF_mask = ismember(prooutVF_trls, flg_trls);
        prooutVF_trls(prooutVF_mask) = 0;
        cfg.trials = find(prooutVF_trls ~= 0);
        tms_epoc_prooutVF = ft_selectdata(cfg, data_tms);
        tms_epoc_prooutVF = ft_preprocessing(cfg_reref, tms_epoc_prooutVF);
        % good epoc antiintoVF
        antiintoVF_trls = find(trl_sequence == 13);
        antiintoVF_mask = ismember(antiintoVF_trls, flg_trls);
        antiintoVF_trls(antiintoVF_mask) = 0;
        cfg.trials = find(antiintoVF_trls ~= 0);
        tms_epoc_antiintoVF = ft_selectdata(cfg, data_tms);
        tms_epoc_antiintoVF = ft_preprocessing(cfg_reref, tms_epoc_antiintoVF);
        % good epoc prooutVF
        antioutVF_trls = find(trl_sequence == 14);
        antioutVF_mask = ismember(antioutVF_trls, flg_trls);
        antioutVF_trls(antioutVF_mask) = 0;
        cfg.trials = find(antioutVF_trls ~= 0);
        tms_epoc_antioutVF = ft_selectdata(cfg, data_tms);
        tms_epoc_antioutVF = ft_preprocessing(cfg_reref, tms_epoc_antioutVF);
        toc
    end
end

%% Time-frequency analysis
if any(strcmp(steps, 'tfr'))
    if ~exist(fName.freqmat_prointoVF, 'file') || ~exist(fName.freqmat_prooutVF, 'file') || ...
            ~exist(fName.freqmat_antiintoVF, 'file') || ~exist(fName.freqmat_antioutVF, 'file')
        disp('Computing time-frequency plots')
        [freqmat_prointoVF, freqmat_prooutVF] = compute_TFRs(epoc_prointoVF, epoc_prooutVF);
        [freqmat_antiintoVF, freqmat_antioutVF] = compute_TFRs(epoc_antiintoVF, epoc_antioutVF);
        
        save(fName.freqmat_prointoVF, 'freqmat_prointoVF', '-v7.3')
        save(fName.freqmat_prooutVF, 'freqmat_prooutVF', '-v7.3')
        save(fName.freqmat_antiintoVF, 'freqmat_antiintoVF', '-v7.3')
        save(fName.freqmat_antioutVF, 'freqmat_antioutVF', '-v7.3')

        if day ~= NoTMSDays(subjID)
            [tms_freqmat_prointoVF, tms_freqmat_prooutVF] = compute_TFRs(tms_epoc_prointoVF, tms_epoc_prooutVF);
            [tms_freqmat_antiintoVF, tms_freqmat_antioutVF] = compute_TFRs(tms_epoc_antiintoVF, tms_epoc_antioutVF);
            save(fName.tms_freqmat_prointoVF, 'tms_freqmat_prointoVF', '-v7.3')
            save(fName.tms_freqmat_prooutVF, 'tms_freqmat_prooutVF', '-v7.3')
            save(fName.tms_freqmat_antiintoVF, 'tms_freqmat_antiintoVF', '-v7.3')
            save(fName.tms_freqmat_antioutVF, 'tms_freqmat_antioutVF', '-v7.3')
        end
    end
end

% t_idx = find(freqmat_ipsi_pro.time>0.5 & freqmat_ipsi_pro.time<4.5);
% figure;
% subplot(1, 3, 1)
% title('Ipsi');
% surf(freqmat_ipsi_pro.time(t_idx),freqmat_ipsi_pro.freq,permute(abs(freqmat_ipsi_pro.powspctrm(:,:,t_idx)),[2,3,1]),'EdgeColor','none');view([0 90]);
% subplot(1, 3, 2)
% title('Contra');
% surf(freqmat_contra_pro.time(t_idx),freqmat_contra_pro.freq,permute(abs(freqmat_contra_pro.powspctrm(:,:,t_idx)),[2,3,1]),'EdgeColor','none');view([0 90]);
% subplot(1, 3, 3)
% title('difference');
% surf(freqmat_contra_pro.time(t_idx),freqmat_contra_pro.freq,permute(freqmat_contra_pro.powspctrm(:,:,t_idx)-freqmat_ipsi_pro.powspctrm(:,:,t_idx),[2,3,1]),'EdgeColor','none');view([0 90]);

% t_idx = find(freqmat_ipsi_anti.time>0.5 & freqmat_ipsi_anti.time<4.5);
% figure;
% subplot(1, 3, 1)
% title('Ipsi');
% surf(freqmat_ipsi_anti.time(t_idx),freqmat_ipsi_anti.freq,permute(abs(freqmat_ipsi_anti.powspctrm(:,:,t_idx)),[2,3,1]),'EdgeColor','none');view([0 90]);
% subplot(1, 3, 2)
% title('Contra');
% surf(freqmat_contra_anti.time(t_idx),freqmat_contra_anti.freq,permute(abs(freqmat_contra_anti.powspctrm(:,:,t_idx)),[2,3,1]),'EdgeColor','none');view([0 90]);
% subplot(1, 3, 3)
% title('difference');
% surf(freqmat_contra_anti.time(t_idx),freqmat_contra_anti.freq,permute(freqmat_contra_anti.powspctrm(:,:,t_idx)-freqmat_ipsi_anti.powspctrm(:,:,t_idx),[2,3,1]),'EdgeColor','none');view([0 90]);

end