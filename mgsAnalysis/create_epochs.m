function epoched_data = create_epochs(fName, eventType, raw_new)
    cfg = [];
    cfg.dataset = fName.concat;
    cfg.continuous = 'yes';
    cfg.trialdef.prestim = 1.5;
    cfg.trialdef.poststim = 6;
    cfg.trialdef.eventtype = 'Stimulus';
    cfg.trialdef.eventvalue = {eventType};
    cfg = ft_definetrial(cfg);

    trlInfo = cfg.trl;
    cfg_new = [];
    cfg_new.trl = trlInfo;
    epoched_data = ft_redefinetrial(cfg_new, raw_new);

    cfg = [];
    cfg.resamplefs = 200;
    cfg.method = 'downsample';
    epoched_data = ft_resampledata(cfg, epoched_data);
end
