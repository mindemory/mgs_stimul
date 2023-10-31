function [ITC_ipsi, ITC_contra]             = combineITC_notms(ITC, this_hemi, ivf_fname, ovf_fname)
% ipsin and contra are combined for into and outVF for NoTMS
in_ipsi                                     = combineITCs(ITC.(ivf_fname), this_hemi, 1);
in_contra                                   = combineITCs(ITC.(ivf_fname), this_hemi, 0);
out_ipsi                                    = combineITCs(ITC.(ovf_fname), this_hemi, 0);
out_contra                                  = combineITCs(ITC.(ovf_fname), this_hemi, 1);
%out_all                                     = alignelecs(POW.(ovf_fname), this_hemi, 0);

ITC_ipsi                                    = in_ipsi;
ITC_ipsi.itcspctrm                          = mean(cat(5, in_ipsi.itcspctrm, out_ipsi.itcspctrm), 5, 'omitnan');
ITC_contra                                  = in_contra;
ITC_contra.itcspctrm                        = mean(cat(5, in_contra.itcspctrm, out_contra.itcspctrm), 5, 'omitnan');
end
