function createtopo_SfN(TFR, tidx, fidx, t_type, freqband)

if nargin < 5
    freqband                                     = 'alpha';
end

in_type                                          = [t_type 'in'];
out_type                                         = [t_type, 'out'];
NTin_tfr                                         = TFR.NT.(in_type).all;
NTout_tfr                                        = TFR.NT.(out_type).all;
Tin_tfr                                          = TFR.T.(in_type).all;
Tout_tfr                                         = TFR.T.(out_type).all;
Allin_tfr                                        = NTin_tfr;
Allin_tfr.powspctrm                              = mean(cat(4, NTin_tfr.powspctrm, Tin_tfr.powspctrm), 4, 'omitnan');
Allout_tfr                                       = NTout_tfr;
Allout_tfr.powspctrm                             = mean(cat(4, NTout_tfr.powspctrm, Tout_tfr.powspctrm), 4, 'omitnan');

cfg                                              = [];
cfg.operation                                    = '(10^(x1/10) - 10^(x2/10)) / (10^(x1/10) + 10^(x2/10))';
cfg.parameter                                    = 'powspctrm';
NTcontrast                                       = ft_math(cfg, NTout_tfr, NTin_tfr);
Tcontrast                                        = ft_math(cfg, Tout_tfr, Tin_tfr);
Allcontrast                                      = ft_math(cfg, Allout_tfr, Allin_tfr);

occ_elecs                                        = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7', 'O2', ...
                                                    'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};
NT_idx                                           = find(ismember(NTcontrast.label,occ_elecs));
T_idx                                            = find(ismember(Tcontrast.label,occ_elecs));

NT_pmax                                          = max(NTcontrast.powspctrm(NT_idx, fidx, tidx), [], 'all', 'omitnan');
NT_pmin                                          = min(NTcontrast.powspctrm(NT_idx, fidx, tidx), [], 'all', 'omitnan');
T_pmax                                           = max(Tcontrast.powspctrm(T_idx, fidx, tidx), [], 'all', 'omitnan');
T_pmin                                           = min(Tcontrast.powspctrm(T_idx, fidx, tidx), [], 'all', 'omitnan');

min_pow                                          = min([NT_pmin, T_pmin]);
max_pow                                          = max([NT_pmax, T_pmax]);
%min_pow = 0;
%max_pow = 1;

figure('Renderer', 'painters', 'Position', [0 1000 1600 800])
if strcmp(t_type, 'P')
    sgtitle(['pro blocks, ' freqband ' band']);
elseif strcmp(t_type, 'A')
    sgtitle(['anti blocks, ' freqband ' band']);
end
cfg                                              = []; 
cfg.layout                                       = 'acticap-64_md.mat'; 
cfg.figure                                       = 'gcf';
%cfg.style                                        = 'straight';
if strcmp(freqband, 'alpha')
    cfg.ylim                                     = [8 12]; 
elseif strcmp(freqband, 'beta')
    cfg.ylim                                     = [13 30];
elseif strcmp(freqband, 'gamma')
    cfg.ylim                                     = [30 50];
end
%cfg.highlight                                      = 'on'; 
%cfg.highlightsymbol                              = 'x'; 
%cfg.highlightsize                                  = 8;
cfg.colorbar                                     = 'yes'; 
cfg.comment                                      = 'no'; 
cfg.colormap                                     = '*RdBu'; 
cfg.marker                                       = 'on';
cfg.zlim                                         = [-0.1 0.1];
cfg.interpolatenan                               = 'no';

subplot(2, 3, 1)
cfg.xlim                                         = [0.5 2];
cfg.title                                        = [freqband ' @ 0.5:2.0s'];
ft_topoplotTFR(cfg, Allcontrast)

subplot(2, 3, 2)
cfg.xlim                                         = [2.8 3.2];
cfg.title                                        = [freqband ' @ 2.8:3.2s'];
ft_topoplotTFR(cfg, NTcontrast)

subplot(2, 3, 3)
cfg.xlim                                         = [3.5 4.2];
cfg.title                                        = [freqband ' @ 3.5:4.2s'];
ft_topoplotTFR(cfg, NTcontrast)

subplot(2, 3, 5)
cfg.xlim                                         = [2.8 3.2];
cfg.title                                        = [freqband ' @ 2.8:3.2s'];
ft_topoplotTFR(cfg, Tcontrast)

subplot(2, 3, 6)
cfg.xlim                                         = [3.5 4.2];
cfg.title                                        = [freqband ' @ 3.5:4.2s'];
ft_topoplotTFR(cfg, Tcontrast)

end