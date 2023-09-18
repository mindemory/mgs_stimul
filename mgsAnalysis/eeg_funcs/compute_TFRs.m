function [freqmat_intoVF, freqmat_outVF] = compute_TFRs(intoVF, outVF)
tic
cfg                                   = [];
cfg.method                            = 'mtmconvol';
cfg.foi                               = 2:40;
cfg.taper                             = 'hanning';
cfg.toi                               = 'all';
cfg.keeptrials                        = 'no';
cfg.t_ftimwin                         = 5./cfg.foi;%0.2 * ones(size(cfg.foi));%7./cfg.foi;
cfg.tapsmofrq                         = 2;
freqmat_intoVF                        = ft_freqanalysis(cfg, intoVF);
freqmat_outVF                         = ft_freqanalysis(cfg, outVF);
toc
end