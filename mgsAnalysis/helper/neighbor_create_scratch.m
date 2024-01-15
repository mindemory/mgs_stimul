clear; close all; clc;

% Make sure to add fieldtrip to path and set ft_defaults;
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

if strcmp(hostname, 'zod')
    input_data_path = '/clayspace/datc/MD_TMS_EEG/EEGfiles/sub01/day02/sub01_day02.vhdr';
    save_path = '/clayspace/hyper/experiments/Mrugank/TMS/mgs_stimul/mgsAnalysis/helper/neighbors.mat';
else % if on personal mac
    input_data_path = '/Users/mrugank/Documents/Clayspace/EEG_TMS/datc/MD_TMS_EEG/EEGfiles/sub01/day02/sub01_day02.vhdr';
    save_path = '/Users/mrugank/Documents/Clayspace/EEG_TMS/mgs_stimul/mgsAnalysis/helper/neighbors.mat';
end


cfg                           = [];
cfg.dataset                   = input_data_path;
cfg.continuous                = 'yes';
cfg.channel                   = {'all', '-LM', '-RM', '-TP9', '-TP10'};
cfg.trl                       = [10 100 0];
raw_data                      = ft_preprocessing(cfg);

cfg                           = [];
cfg.implicitref               = 'Cz';
cfg.reref                     = 'yes';
cfg.refchannel                = 'all';
cfg.refmethod                 = 'avg';
raw_data                      = ft_preprocessing(cfg, raw_data);


cfg_neighbor                  = [];
cfg_neighbor.method           = 'triangulation';
cfg_neighbor.compress         = 'yes';
cfg_neighbor.layout           = 'acticap-64_md.mat';
cfg_neighbor.feedback         = 'yes';
neighbors                     = ft_prepare_neighbours(cfg_neighbor, raw_data);


save(save_path, 'neighbors');