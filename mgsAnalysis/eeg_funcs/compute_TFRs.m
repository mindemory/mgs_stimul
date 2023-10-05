function [freqmat_intoVF, freqmat_outVF] = compute_TFRs(intoVF, outVF, varargin)

if nargin < 3
    
    cfg                                   = [];
    cfg.method                            = 'mtmconvol';
    cfg.foi                               = 2:40;
    cfg.taper                             = 'hanning';
    cfg.toi                               = 'all';
    cfg.keeptrials                        = 'no';
    cfg.polyremoval                       = -1;
    %cfg.pad                               = 'nextpow2';
    cfg.t_ftimwin                         = 5./cfg.foi;%0.2 * ones(size(cfg.foi));%7./cfg.foi;
    cfg.tapsmofrq                         = 2;
    freqmat_intoVF                        = ft_freqanalysis(cfg, intoVF);
    freqmat_outVF                         = ft_freqanalysis(cfg, outVF);
    
else
    cfg              = [];
    cfg.output       = 'pow'; 
    cfg.channel      = 'all';
    cfg.method       = 'wavelet';
    cfg.taper        = 'hanning';
    cfg.keeptrials   = 'yes';
    cfg.polyremoval  = -1;
    cfg.toi          = [0 : 0.10 : 5];
    cfg.foilim       = [2 40];
    % cfg.t_ftimwin    = ones(size(cfg.foi)) * 0.5;
     
    %cfg.trials       = inds_pulsIn;
    freqmat_intoVF     = ft_freqanalysis(cfg, intoVF);
    freqmat_outVF     = ft_freqanalysis(cfg, outVF);

end