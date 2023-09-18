function data_eeg = RunBandPass(data_eeg)

cfg = [];
cfg.continuous = 'no';
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 60];
data_eeg = ft_preprocessing(cfg, data_eeg);
end