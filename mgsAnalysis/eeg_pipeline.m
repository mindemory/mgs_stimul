function [task_prointoVF, task_prooutVF, task_antiintoVF, task_antioutVF] = ...
    eeg_pipeline(direct, EEGfile, prointoVF_idx, prooutVF_idx, ...
    antiintoVF_idx, antioutVF_idx)
addpath /Users/mrugank/Documents/fieldtrip;
ft_defaults;

cfg = [];
cfg.dataset = [direct.EEG filesep EEGfile];
%cfg.demean = 'yes';
cfg.continuous = 'yes';
data_eeg = ft_preprocessing(cfg);

% Removing NAN timepoint
data_eeg.time{1} = data_eeg.time{1}(2:end);
data_eeg.sampleinfo = [1,12835950];
data_eeg.trial{1} = data_eeg.trial{1}(1:end, 2:end);
data_eeg.hdr.nSamples = 12835950;
data_eeg.cfg.trl = [1,12835950,0];

% downsample data
cfg = [];
cfg.detrend = 'no';
cfg.demean = 'yes';
cfg.resamplefs = 500;
data_eeg = ft_resampledata(cfg, data_eeg);

% Removing line noise
cfg = [];
%cfg.hpfilter = 'yes';
%cfg.hpfreq = 0.5;
%cfg.hpfiltord = 5;
cfg.demean = 'yes';
cfg.dftfilter = 'yes';
cfg.dftfreq = [50 100 150];
data_eeg = ft_preprocessing(cfg, data_eeg);

% Epoching the data
cfg = [];
cfg.dataset = [direct.EEG filesep EEGfile];
cfg.trialfun = 'ft_trialfun_general';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = {'S  1'};
cfg.trialdef.prestim = 0.5;
cfg.trialdef.poststim = 7.65;
cfg = ft_definetrial(cfg);
data_eeg = ft_redefinetrial(cfg, data_eeg);

% Rejecting trials
cfg = [];
cfg.method = 'summary';
cfg.layout = 'acticap-64_md.mat';
cfg.channel = 'all';
data_eeg = ft_rejectvisual(cfg, data_eeg);

% % Removing LM and RM electrodes
% cfg = [];
% cfg.channel = setdiff(1:66, [64, 65]);
% data_eeg = ft_selectdata(cfg, data_eeg);
% 
% % Referencing to Mastoids
% cfg = [];
% cfg.channel = 'all';
% cfg.reref = 'yes';
% cfg.implicitref = 'Cz';
% cfg.refchannel = {'TP9', 'TP10'};
% data_eeg = ft_preprocessing(cfg, data_eeg);

cfg_prointoVF = [];
cfg_prointoVF.trails = prointoVF_idx;
task_prointoVF = ft_timelockanalysis(cfg_prointoVF, data_eeg);

cfg_prooutVF = [];
cfg_prooutVF.trails = prooutVF_idx;
task_prooutVF = ft_timelockanalysis(cfg_prooutVF, data_eeg);

cfg_antiintoVF = [];
cfg_antiintoVF.trails = antiintoVF_idx;
task_antiintoVF = ft_timelockanalysis(cfg_antiintoVF, data_eeg);

cfg_antioutVF = [];
cfg_antioutVF.trails = antioutVF_idx;
task_antioutVF = ft_timelockanalysis(cfg_antioutVF, data_eeg);

end



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