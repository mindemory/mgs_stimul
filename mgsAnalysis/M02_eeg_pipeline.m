% function [task_prointoVF, task_prooutVF, task_antiintoVF, task_antioutVF] = ...
%     eeg_pipeline(direct, EEGfile, prointoVF_idx, prooutVF_idx, ...
%     antiintoVF_idx, antioutVF_idx)
addpath /Users/mrugankdake/Documents/MATLAB/fieldtrip-20220104/;
ft_defaults;
%set(0,'DefaultFigureWindowStyle','docked')
%% Load the data
saveName = [direct.saveEEG '/sub' num2str(subjID, "%02d") '_day' num2str(day, "%02d") '_raweeg.mat'];
if ~exist(saveName, 'file')
    disp('Raw file does not exist. Creating mat file.')
    tic
    cfg = [];
    cfg.dataset = [direct.EEG filesep EEGfile];
    cfg.demean = 'no';
    cfg.continuous = 'yes';
    data_eeg = ft_preprocessing(cfg);
    toc
    % Removing NAN timepoint
    if sum(sum(isnan(data_eeg.trial{1}))) > 0
        data_eeg.time{1} = data_eeg.time{1}(2:end);
        data_eeg.sampleinfo = data_eeg.sampleinfo - [0 1];
        data_eeg.trial{1} = data_eeg.trial{1}(1:end, 2:end);
        data_eeg.hdr.nSamples = data_eeg.hdr.nSamples - 1;
        data_eeg.cfg.trl = data_eeg.cfg.trl - [0 1 0];
    end
    % Check data
    % figure(); plot(data_eeg.time{1}, data_eeg.trial{1}(1:10, :))
    save(saveName, 'data_eeg', '-v7.3')
else
    disp('Raw file exists, importing mat file.')
    load(saveName)
end
%% Removing low frequency drifts
saveName = [direct.saveEEG '/sub' num2str(subjID, "%02d") '_day' num2str(day, "%02d") '_highpass.mat'];
if ~exist(saveName, 'file')
    disp('Highpass file does not exist. Creating mat file.')
    tic
    cfg = [];
    cfg.demean = 'yes';
    cfg.bpfreq = [0.5,100];
    cfg.bpfilter = 'yes';
    cfg.bpfiltord = 2;
    data_eeg = ft_preprocessing(cfg, data_eeg);
    toc
    save(saveName, 'data_eeg', '-v7.3')
else
    disp('Highpass file exists, importing mat file.')
    load(saveName)
end
%% Removing line noise
% NOTE: RUN AFTER LOOKING AT EPOCHED DATA!
tic
cfg = [];
cfg.dftfilter = 'yes';
cfg.dftfreq = [50 100];
data_eeg = ft_preprocessing(cfg, data_eeg);
toc
%% Epoching the data
saveName = [direct.saveEEG '/sub' num2str(subjID, "%02d") '_day' num2str(day, "%02d") '_epoched.mat'];
if ~exist(saveName, 'file')
    disp('Epoched file does not exist. Creating mat file.')
    tic
    cfg = [];
    cfg.dataset = [direct.EEG filesep EEGfile];
    cfg.trialfun = 'ft_trialfun_general';
    cfg.trialdef.eventtype = 'Stimulus';
    cfg.trialdef.eventvalue = {'S  2'};
    cfg.trialdef.prestim = 1;
    cfg.trialdef.poststim = 8;
    cfg = ft_definetrial(cfg);
    data_eeg = ft_redefinetrial(cfg, data_eeg);
    toc
    % Check data
    % figure(); cfg = []; cfg.viewmode = 'vertical'; ft_databrowser(cfg, data_eeg)
    save(saveName, 'data_eeg', '-v7.3')
else
    disp('Epoched file exists, importing mat file.')
    load(saveName)
end
%% Rejecting trials
%set(0,'DefaultFigureWindowStyle','normal')
tic
cfg = [];
cfg.method = 'summary';
cfg.layout = 'acticap-64_md.mat';
cfg.channel = 'all';
data_eeg = ft_rejectvisual(cfg, data_eeg);
toc
%% Removing LM and RM electrodes
cfg = [];
cfg.channel = setdiff(1:66, [64, 65]);
data_eeg = ft_selectdata(cfg, data_eeg); 
%% Referencing to Mastoids
cfg = [];
cfg.channel = 'all';
cfg.reref = 'yes';
cfg.implicitref = 'Cz';
cfg.refchannel = {'TP9', 'TP10'};
data_eeg = ft_preprocessing(cfg, data_eeg);
%% ERP analysis
cfg = [];
cfg.trials = prointoVF_idx;
ERP_prointoVF = ft_timelockanalysis(cfg, data_eeg);
cfg.trials = prooutVF_idx;
ERP_prooutVF = ft_timelockanalysis(cfg, data_eeg);
cfg.trials = antiintoVF_idx;
ERP_antiintoVF = ft_timelockanalysis(cfg, data_eeg);
cfg.trials = antioutVF_idx;
ERP_antioutVF = ft_timelockanalysis(cfg, data_eeg);
%% Time-frequency analysis
cfg = [];
cfg.output = 'pow';
cfg.channel = 'all';
%cfg.channel = {'T7', 'C5', 'C3', '}
cfg.method = 'wavelet';
cfg.taper = 'hanning';
%cfg.pad = 'nextpow2';
cfg.toi = -0.7:0.2:7.5;
cfg.foilim = [4, 30];
cfg.trials = prointoVF_idx;
TFR_prointoVF = ft_freqanalysis(cfg, data_eeg);
cfg.trials = prooutVF_idx;
TFR_prooutVF = ft_freqanalysis(cfg, data_eeg);
cfg.trials = antiintoVF_idx;
TFR_antiintoVF = ft_freqanalysis(cfg, data_eeg);
cfg.trials = antioutVF_idx;
TFR_antioutVF = ft_freqanalysis(cfg, data_eeg);

% end

%% Topoplot
cfg = [];
cfg.baseline = [-0.5 -0.1];
cfg.baselinetype = 'absolute';
cfg.xlim = [8 12];
%cfg.zlim = 
cfg.marker = 'on';
cfg.layout = 'acticap-64_md.mat';
cfg.colorbar = 'yes';
figure(); ft_topoplotTFR(cfg, TFR_prointoVF)
figure(); ft_topoplotTFR(cfg, TFR_prooutVF)
figure(); ft_topoplotTFR(cfg, TFR_antiintoVF)
figure(); ft_topoplotTFR(cfg, TFR_antioutVF)

%% Multiplot
cfg = [];
cfg.baseline = [-0.5 -0.1];
cfg.baselinetype = 'absolute';
cfg.showlabels = 'yes';
cfg.layout = 'acticap-64_md.mat';
cfg.colorbar = 'yes';
figure(); ft_multiplotTFR(cfg, TFR_prointoVF)
figure(); ft_multiplotTFR(cfg, TFR_prooutVF)
figure(); ft_multiplotTFR(cfg, TFR_antiintoVF)
figure(); ft_multiplotTFR(cfg, TFR_antioutVF)


cfg = [];
cfg.parameter = 'powspctrm';
cfg.trials = 'all';
cfg.channel = {'PO7', 'PO3', 'O1'};
cfg.zlim = [0, 10^4]
ft_singleplotTFR(cfg,TFR_prointoVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
ft_singleplotTFR(cfg,TFR_prooutVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
ft_singleplotTFR(cfg,TFR_antiintoVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
ft_singleplotTFR(cfg,TFR_antioutVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')

cfg.channel = 'all';%{'PO4', 'PO8', 'O2'};
ft_singleplotTFR(cfg,TFR_prointoVF);pbaspect([1 1 1]);


ft_singleplotTFR(cfg,TFR_prooutVF);pbaspect([1 1 1]);
ft_singleplotTFR(cfg,TFR_antiintoVF);pbaspect([1 1 1]);
ft_singleplotTFR(cfg,TFR_antioutVF);pbaspect([1 1 1]);

%figure();
%plot(data_eeg.time{1}, data_eeg.trial{1});
%hold on;
%plot(data_eeg.time{1}, data_eeg.trial{1}(12, :), 'g');
% blurb =  NaN(9, 400);
% for ii = 1:size(cfg.event, 2)
%     for evenum = 1:9
%         flag_sent = ['S  '  num2str(evenum)];
%         if strcmp(cfg.event(ii).value, flag_sent)
%             blurb(evenum, ii) = 1;
%         end
%     end
% end
% for evenum = 1:9
%     evenum
%     nansum(blurb(evenum, :))
% end