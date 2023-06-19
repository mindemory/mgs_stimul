%% Flag bad trials and channels
cfg = [];
cfg.channel = occipital_elecs;
ft_rejectvisual(cfg, data_eeg_control_prointoVF);

cfg = [];
ft_rejectvisual(cfg, data_eeg_control_prooutVF);

cfg = [];
ft_rejectvisual(cfg, data_eeg_TMS_prointoVF);

cfg = [];
ft_rejectvisual(cfg, data_eeg_TMS_prooutVF);

%% Visualize epoched data
occipital_elecs = {'P2', 'P4', 'P6', 'P8', 'PO4', 'PO8', 'O2', 'P1', 'P3', 'P5', 'P7', 'PO3', 'PO7', 'O1'};
cfg = [];
cfg.viewmode = 'vertical';
cfg.ylim = [-4 4];
cfg.channel = occipital_elecs;
ft_databrowser(cfg, data_eeg_control_prointoVF)

cfg = [];
cfg.viewmode = 'vertical';
cfg.ylim = [-4 4];
cfg.channel = occipital_elecs;
ft_databrowser(cfg, data_eeg_control_prooutVF)

cfg = [];
cfg.viewmode = 'vertical';
cfg.channel = occipital_elecs;
cfg.ylim = [-4 4];
ft_databrowser(cfg, data_eeg_TMS_prointoVF_holder(2))

cfg = [];
cfg.viewmode = 'vertical';
cfg.channel = occipital_elecs;
cfg.ylim = [-4 4];
ft_databrowser(cfg, data_eeg_TMS_prooutVF_holder(2))
