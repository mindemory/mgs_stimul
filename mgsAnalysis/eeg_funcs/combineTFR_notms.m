function [TFR_ipsi, TFR_contra]     = combineTFR_notms(POW, this_hemi, ivf_fname, ovf_fname)
% ipsin and contra are combined for into and outVF for NoTMS
in_ipsi                                     = combineTFRs(POW.(ivf_fname), this_hemi, 1);
in_contra                                   = combineTFRs(POW.(ivf_fname), this_hemi, 0);
out_ipsi                                    = combineTFRs(POW.(ovf_fname), this_hemi, 0);
out_contra                                  = combineTFRs(POW.(ovf_fname), this_hemi, 1);
%out_all                                     = alignelecs(POW.(ovf_fname), this_hemi, 0);

TFR_ipsi                                     = in_ipsi;
TFR_ipsi.powspctrm                           = mean(cat(5, in_ipsi.powspctrm, out_ipsi.powspctrm), 5, 'omitnan');
TFR_contra                                   = in_contra;
TFR_contra.powspctrm                         = mean(cat(5, in_contra.powspctrm, out_contra.powspctrm), 5, 'omitnan');
end
