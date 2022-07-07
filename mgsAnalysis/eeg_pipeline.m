clear; close all;
subjID = '20';
curr_dir = pwd;
mgs_dir = curr_dir(1:end-12);
master_dir = mgs_dir(1:end-11);


addpath /Users/mrugank/Documents/fieldtrip;
ft_defaults;

phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
mgs_data_path = [master_dir '/data/mgs_data/sub' subjID];
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

EEGpath = [mgs_data_path '/EEGData'];
EEGfile = dir(fullfile(EEGpath, '*.vhdr'));
EEGfile.name
cfg = [];
cfg.dataset = [EEGpath filesep EEGfile.name];
data_eeg = ft_preprocessing(cfg);

cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = 'S  8';
cfg = ft_definetrial(cfg);


data_new = ft_redefinetrial(cfg, data_eeg);
%figure();
%plot(data_eeg.time{1}, data_eeg.trial{1});
%hold on;
%plot(data_eeg.time{1}, data_eeg.trial{1}(12, :), 'g');
