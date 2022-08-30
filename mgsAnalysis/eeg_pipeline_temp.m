function [task_prointoVF, task_prooutVF, task_antiintoVF, task_antioutVF] = ...
    eeg_pipeline_temp(direct, EEGfile, prointoVF_idx, prooutVF_idx, ...
    antiintoVF_idx, antioutVF_idx)
addpath /Users/mrugankdake/Documents/MATLAB/fieldtrip-20220104/;
ft_defaults;
set(0,'DefaultFigureWindowStyle','docked')
%% Load the data
saveName = [direct.saveEEG '/sub01_day01_raweeg.mat'];
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
%     data_eeg.time{1} = data_eeg.time{1}(2:end);
%     data_eeg.sampleinfo = [1,12835950];
%     data_eeg.trial{1} = data_eeg.trial{1}(1:end, 2:end);
%     data_eeg.hdr.nSamples = 12835950;
%     data_eeg.cfg.trl = [1,12835950,0];
    save(saveName, 'data_eeg', '-v7.3')
else
    disp('Raw file exists, importing mat file.')
    load(saveName)
end
%% downsample data
tic
cfg = [];
%cfg.detrend = 'yes';
%cfg.demean = 'yes';
cfg.resamplefs = 1000;
data_eeg = ft_resampledata(cfg, data_eeg);
toc
%% Removing line noise
tic
cfg = [];
cfg.demean = 'yes';
% cfg.hpfilter = 'yes';
% cfg.hpfreq = 0.5;
% cfg.hpfiltord = 5;
%cfg.detrend = 'yes';
cfg.dftfilter = 'yes';
cfg.dftfreq = [50 100 150];
data_eeg = ft_preprocessing(cfg, data_eeg);
toc
%% Removing low frequency drifts
saveName = [direct.saveEEG '/sub01_day01_highpass.mat'];
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
%% Epoching the data
saveName = [direct.saveEEG '/sub01_day01_epoched.mat'];
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
    save(saveName, 'data_eeg', '-v7.3')
else
    disp('Epoched file exists, importing mat file.')
    load(saveName)
end
%% Rejecting trials
set(0,'DefaultFigureWindowStyle','normal')
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
%% Time-frequency analysis
cfg = [];
cfg.output = 'pow';
cfg.channel = {'PO7', 'PO3', 'O1', 'POz', 'Oz', 'PO4', 'PO8', 'O2'};
%cfg.channel = {'T7', 'C5', 'C3', '}
cfg.method = 'wavelet';
cfg.taper = 'hanning';
cfg.pad = 'nextpow2';
cfg.toi = -0.5:0.2:7;
cfg.foilim = [4, 30];
cfg.trials = prointoVF_idx;
TFR_prointoVF = ft_freqanalysis(cfg, data_eeg);
cfg.trials = prooutVF_idx;
TFR_prooutVF = ft_freqanalysis(cfg, data_eeg);
cfg.trials = antiintoVF_idx;
TFR_antiintoVF = ft_freqanalysis(cfg, data_eeg);
cfg.trials = antioutVF_idx;
TFR_antioutVF = ft_freqanalysis(cfg, data_eeg);

end

cfg = [];
cfg.parameter = 'powspctrm';
cfg.trials = 'all';
cfg.channel = {'PO7', 'PO3', 'O1'};
ft_singleplotTFR(cfg,TFR_prointoVF);pbaspect([1 1 1]);
cfg.channel = {'PO4', 'PO8', 'O2'};
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