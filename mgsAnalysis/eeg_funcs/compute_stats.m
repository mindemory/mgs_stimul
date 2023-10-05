function [stats] = compute_stats(intoVF, outVF)

tic
cfg                                 = [];
cfg.channel                         = intoVF.label;
cfg.latency                         = [0.5 4.5]; 
cfg.frequency                       = [8 12];
cfg.avgovertime                     = 'no';
cfg.avgoverfreq                     = 'yes';
cfg.keepfreq                        = 'no';
cfg.parameter                       = 'powspctrm';
cfg.method                          = 'stats';
cfg.correctm                        = 'no';
cfg.statistic                       = 'ttest2';
len_IVF                             = length(intoVF.trialinfo);
len_OVF                             = length(outVF.trialinfo);
design                              = ones(1,len_IVF+len_OVF);
design(len_IVF+1:len_IVF+len_OVF)   = 2;
cfg.design                          = design;
cfg_orig                            = cfg;
stats                               = ft_freqstatistics(cfg, intoVF, outVF);
toc

% cfg = []; cfg.layout = 'acticap-64_md.mat'; cfg.style = 'straight';
% cfg.xlim = [0.5:1:4.5];
% cfg.parameter = 'stat';
% ft_topoplotTFR(cfg, stats);colorbar
% title('stimLVF - stimRVF');
end