clear; close all; clc;
subjID = '01';
day = 1;
master_dir = '/d/DATC/datc/MD_TMS_EEG';

addpath /Users/mrugank/Documents/fieldtrip;
ft_defaults;

phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
mgs_data_path = [master_dir '/data/mgs_data/sub' subjID '/day' num2str(day, "%02d")];
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

EEGpath = [master_dir '/EEGData/sub' subjID];
EEGfile = 'sub01_day01_block03.vhdr';
cfg = [];
cfg.dataset = [EEGpath filesep EEGfile];
cfg.continuous = 'yes';
data_eeg = ft_preprocessing(cfg);

cfg = [];
cfg.dataset = [EEGpath filesep EEGfile];
%cfg.trialfun = 'ft_trialfun_general';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = {'S  1'};
%cfg.trialdef.prestim = 1;
%cfg.trialdef.poststim = 1;
cfg = ft_definetrial(cfg);

data_new = ft_redefinetrial(cfg, data_eeg);
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