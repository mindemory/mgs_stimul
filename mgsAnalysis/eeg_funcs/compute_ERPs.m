function [erp_intoVF, erp_outVF]          = compute_ERPs(intoVF, outVF, keeptrials)
% Created by Mrugank (09/11/2023): Performs time-lockanalysis for intoVF
% and outVF datasets and returns average across all trials for each
% channel.

if nargin < 3
    keeptrials                            = 0;
end
cfg                                       = [];
if keeptrials
    cfg.keeptrials                        = 'yes';
else
    cfg.keeptrials                        = 'no';
end
erp_intoVF                                = ft_timelockanalysis(cfg, intoVF);
erp_outVF                                 = ft_timelockanalysis(cfg, outVF);

end