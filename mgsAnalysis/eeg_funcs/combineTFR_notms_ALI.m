function [TFR_ipsi, TFR_contra]             = combineTFR_notms_ALI(POW, this_hemi, ivf_fname, ovf_fname)
% ipsi and contra are combined for into and outVF for NoTMS
in_ipsi                                     = combineTFRs_ALI(POW.(ivf_fname), this_hemi, 1);
in_contra                                   = combineTFRs_ALI(POW.(ivf_fname), this_hemi, 0);
out_ipsi                                    = combineTFRs_ALI(POW.(ovf_fname), this_hemi, 0);
out_contra                                  = combineTFRs_ALI(POW.(ovf_fname), this_hemi, 1);

% In vs out ipsi and contra powerspectra
TFR_ipsi                                    = in_ipsi;
TFR_ipsi.powspctrm                          = mean(cat(1, in_ipsi.powspctrm, out_ipsi.powspctrm), 5, 'omitnan');
TFR_contra                                  = in_contra;
TFR_contra.powspctrm                        = mean(cat(1, in_contra.powspctrm, out_contra.powspctrm), 5, 'omitnan');
end
