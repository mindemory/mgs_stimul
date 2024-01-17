function [these_trls, this_epoch]    = create_epochs(all_epocs, evtCode, trls_to_remove)
cfg                                  = [];
cfg.channel                          = 'all';

% epoch data based on evtCode
these_trls                           = find(all_epocs.trialinfo == evtCode);
cfg.trials                           = setdiff(these_trls, trls_to_remove);
this_epoch                           = ft_selectdata(cfg, all_epocs);

end
