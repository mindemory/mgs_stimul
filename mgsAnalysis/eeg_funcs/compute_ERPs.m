function [erp_intoVF, erp_outVF] = compute_ERPs(intoVF, outVF)

cfg = [];
cfg.keeptrials = 'no';
erp_intoVF = ft_timelockanalysis(cfg, intoVF);
erp_outVF = ft_timelockanalysis(cfg, outVF);

end