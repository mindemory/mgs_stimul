function [erp_intoVF, erp_outVF]          = compute_ERPs(intoVF, outVF)
% Created by Mrugank (09/11/2023): Performs time-lockanalysis for intoVF
% and outVF datasets and returns average across all trials for each
% channel.
cfg                                       = [];
cfg.keeptrials                            = 'no';
erp_intoVF                                = ft_timelockanalysis(cfg, intoVF);
erp_outVF                                 = ft_timelockanalysis(cfg, outVF);

end