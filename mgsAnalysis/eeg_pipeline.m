clear; close all;
subjID = '01';
master_dir = '/d/DATC/datc/MD_TMS_EEG';

addpath /Users/mrugank/Documents/fieldtrip;
ft_defaults;

phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
mgs_data_path = [master_dir '/data/mgs_data/sub' subjID];
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

%EEGpath_temp = '/hyper/experiments/Masih/EEG_MGS/VisualCortex-grant/data/eeg/sub01_session02';
%EEGfile_temp = [EEGpath_temp '/s1s2_r1_pro.vhdr'];
EEGpath = [master_dir '/EEGData'];
EEGfile = dir(fullfile(EEGpath, '*.vhdr'));
EEGfile.name
cfg = [];
cfg.dataset = [EEGpath filesep EEGfile.name];
%cfg.dataset = EEGfile_temp;
data_eeg = ft_preprocessing(cfg);

cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.eventvalue = 'S  8';
cfg = ft_definetrial(cfg);


data_new = ft_redefinetrial(cfg, data_eeg);
%figure();
%plot(data_eeg.time{1}, data_eeg.trial{1});
%hold on;
%plot(data_eeg.time{1}, data_eeg.trial{1}(12, :), 'g');
