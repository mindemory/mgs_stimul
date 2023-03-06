function A03_PreprocEEG(subjID, day, steps)
%clearvars -except subjID day; close all; clc;

if nargin < 3
    steps = {'concat', 'raweeg', 'bandpass', 'epoch'};
end
p.subjID = num2str(subjID,'%02d');
p.day = day;

[p, taskMap] = initialization(p, 'eeg');

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
fName.bandpass = [fName.general '_bandpass.mat'];
fName.epoched = [fName.general '_epoched.mat'];

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
        cfg.demean = 'no';
        cfg.continuous = 'yes';
        data_eeg = ft_preprocessing(cfg);
        % Removing NAN timepoint
        if sum(sum(isnan(data_eeg.trial{1}))) > 0
            data_eeg.time{1} = data_eeg.time{1}(2:end);
            data_eeg.sampleinfo = data_eeg.sampleinfo - [0 1];
            data_eeg.trial{1} = data_eeg.trial{1}(1:end, 2:end);
            data_eeg.hdr.nSamples = data_eeg.hdr.nSamples - 1;
            data_eeg.cfg.trl = data_eeg.cfg.trl - [0 1 0];
        end
        toc
        % Check data
        % figure(); plot(data_eeg.time{1}, data_eeg.trial{1}(1:10, :))
        save(fName.load, 'data_eeg', '-v7.3')
    else
        disp('Raw file exists, importing mat file.')
        load(fName.load)
    end
end

%% Bandpass filter
if any(strcmp(steps, 'bandpass'))
    if ~exist(fName.bandpass, 'file')
        disp('Bandpass filtered data does not exist. Applying band pass filter.')
        tic
        cfg = [];
        cfg.demean = 'yes';
        cfg.bpfreq = [0.1,100];
        cfg.bpfilter = 'yes';
        cfg.bpfiltord = 2;
        data_eeg = ft_preprocessing(cfg, data_eeg);
        toc
        save(fName.bandpass, 'data_eeg', '-v7.3')
    else
        disp('Highpass file exists, importing mat file.')
        load(fName.bandpass)
    end
end

%% Epoch
if any(strcmp(steps, 'epoch'))
    if ~exist(fName.epoched, 'file')
        disp('Epoching the data.')
        tic
        cfg = [];
        cfg.dataset = fName.concat;
        cfg.trialfun = 'ft_trialfun_general';
        cfg.trialdef.eventtype = 'Stimulus';
        cfg.trialdef.eventvalue = {'S  2'};
        cfg.trialdef.prestim = 1;
        cfg.trialdef.poststim = 8;
        cfg = ft_definetrial(cfg);
        data_eeg = ft_redefinetrial(cfg, data_eeg);
        toc
        save(fName.epoched, 'data_eeg', '-v7.3')
    else
        disp('Epoched file exists, importing mat file.')
        load(fName.epoched)
    end
end

%%


%% Removing line noise
% NOTE: RUN AFTER LOOKING AT EPOCHED DATA!
% tic
% cfg = [];
% cfg.dftfilter = 'yes';
% cfg.dftfreq = [50 100];
% data_eeg = ft_preprocessing(cfg, data_eeg);
% toc
%
% %% Divide data by conditions
% data_eeg_prointoVF = block_data(data_eeg, prointoVF_idx_EEG);
% data_eeg_prooutVF = block_data(data_eeg, prooutVF_idx_EEG);
% data_eeg_antiintoVF = block_data(data_eeg, antiintoVF_idx_EEG);
% data_eeg_antioutVF = block_data(data_eeg, antioutVF_idx_EEG);
% %% Rejecting trials
% cfg = [];
% cfg.method = 'summary';
% cfg.layout = 'acticap-64_md.mat';
% cfg.channel = 'all';
% data_eeg_prointoVF = ft_rejectvisual(cfg, data_eeg_prointoVF);
% data_eeg_prooutVF = ft_rejectvisual(cfg, data_eeg_prooutVF);
% data_eeg_antiintoVF = ft_rejectvisual(cfg, data_eeg_antiintoVF);
% data_eeg_antioutVF = ft_rejectvisual(cfg, data_eeg_antioutVF);
%
% %% Time-frequency analysis
% cfg = [];
% cfg.output = 'pow';
% cfg.channel = 'all';
% cfg.method = 'wavelet';
% cfg.taper = 'hanning';
% cfg.toi = -0.7:0.2:7.5;
% cfg.foilim = [4, 30];
% cfg.trials = 'all';
% saveName = [direct.saveEEG '/sub' num2str(subjID, '%02d') '_day' num2str(day, '%02d') '_TFR.mat'];
%
% if ~exist(saveName, 'file')
%     disp('TFR file does not exist. Creating mat file.')
%     TFR_prointoVF = ft_freqanalysis(cfg, data_eeg_prointoVF);
%     TFR_prooutVF = ft_freqanalysis(cfg, data_eeg_prooutVF);
%     TFR_antiintoVF = ft_freqanalysis(cfg, data_eeg_antiintoVF);
%     TFR_antioutVF = ft_freqanalysis(cfg, data_eeg_antioutVF);
%     save(saveName, 'TFR_prointoVF', 'TFR_prooutVF', 'TFR_antiintoVF', 'TFR_antioutVF', '-v7.3')
% else
%     disp('TFR file exists, importing mat file.')
%     load(saveName)
% end
%
% %% Topoplot
% cfg = [];
% cfg.baseline = 'no';%[-0.5 -0.1];
% cfg.baselinetype = 'relative';
% cfg.xlim = [1, 5];
% cfg.ylim = [8 12];
% %cfg.zlim =
% cfg.marker = 'on';
% cfg.layout = 'acticap-64_md.mat';
% cfg.colorbar = 'yes';
% figure(); ft_topoplotTFR(cfg, TFR_prointoVF)
% figure(); ft_topoplotTFR(cfg, TFR_prooutVF)
% figure(); ft_topoplotTFR(cfg, TFR_antiintoVF)
% figure(); ft_topoplotTFR(cfg, TFR_antioutVF)
%
% %% Multiplot
% cfg = [];
% cfg.baseline = 'no';%[-0.5 -0.1];
% cfg.baselinetype = 'absolute';
% cfg.showlabels = 'yes';
% cfg.layout = 'acticap-64_md.mat';
% cfg.colorbar = 'yes';
% cfg.zlim = [0 10^4];
% figure(); ft_multiplotTFR(cfg, TFR_prointoVF)
% figure(); ft_multiplotTFR(cfg, TFR_prooutVF)
% figure(); ft_multiplotTFR(cfg, TFR_antiintoVF)
% figure(); ft_multiplotTFR(cfg, TFR_antioutVF)
%
% %% Removing LM and RM electrodes
% cfg = [];
% cfg.channel = setdiff(1:66, [64, 65]);
% data_eeg = ft_selectdata(cfg, data_eeg);
% %% Referencing to Mastoids
% cfg = [];
% cfg.channel = 'all';
% cfg.reref = 'yes';
% cfg.implicitref = 'Cz';
% cfg.refchannel = {'FT9', 'FT10'};
% data_eeg = ft_preprocessing(cfg, data_eeg);
% %% ERP analysis
% cfg = [];
% cfg.trials = prointoVF_idx;
% ERP_prointoVF = ft_timelockanalysis(cfg, data_eeg_prointoVF);
% cfg.trials = prooutVF_idx;
% ERP_prooutVF = ft_timelockanalysis(cfg, data_eeg_prooutVF);
% cfg.trials = antiintoVF_idx;
% ERP_antiintoVF = ft_timelockanalysis(cfg, data_eeg_antiintoVF);
% cfg.trials = antioutVF_idx;
% ERP_antioutVF = ft_timelockanalysis(cfg, data_eeg_antioutVF);
%
% cfg = [];
% cfg.parameter = 'powspctrm';
% cfg.trials = 'all';
% cfg.channel = {'PO7', 'PO3', 'O1'};
% cfg.zlim = [0, 10^4]
% ft_singleplotTFR(cfg,TFR_prointoVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
% ft_singleplotTFR(cfg,TFR_prooutVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
% ft_singleplotTFR(cfg,TFR_antiintoVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
% ft_singleplotTFR(cfg,TFR_antioutVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
%
% cfg.channel = 'all';%{'PO4', 'PO8', 'O2'};
% ft_singleplotTFR(cfg,TFR_prointoVF);pbaspect([1 1 1]);
%
%
% ft_singleplotTFR(cfg,TFR_prooutVF);pbaspect([1 1 1]);
% ft_singleplotTFR(cfg,TFR_antiintoVF);pbaspect([1 1 1]);
% ft_singleplotTFR(cfg,TFR_antioutVF);pbaspect([1 1 1]);
%
% %figure();
% %plot(data_eeg.time{1}, data_eeg.trial{1});
% %hold on;
% %plot(data_eeg.time{1}, data_eeg.trial{1}(12, :), 'g');
% % blurb =  NaN(9, 400);
% % for ii = 1:size(cfg.event, 2)
% %     for evenum = 1:9
% %         flag_sent = ['S  '  num2str(evenum)];
% %         if strcmp(cfg.event(ii).value, flag_sent)
% %             blurb(evenum, ii) = 1;
% %         end
% %     end
% % end
% % for evenum = 1:9
% %     evenum
% %     nansum(blurb(evenum, :))
% % end