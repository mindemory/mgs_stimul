function data_eeg           = RunBandPass(data_eeg)
% Created by Mrugank (10/23/2023): Applies
cfg                         = [];
cfg.bpfilter                = 'yes';
cfg.bpfilttype              = 'firws';
cfg.bpfiltdir               = 'onepass-zerophase';
cfg.bpfreq                  = [0.5 50];
data_eeg                    = ft_preprocessing(cfg, data_eeg);
end