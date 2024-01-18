function [bad_ch, bad_tr, raw] = auto_reject(raw, epoc)
thresh                        = [];
thresh.pval                   = 90;
thresh.prop_badtrials         = 0.25;
ch_names                      = raw.label;
tseries                       = raw.trial{1};
ch_std                        = std(tseries, 0, 2);
ch_med                        = median(ch_std);

rej_thresh                    = prctile(abs(ch_std - ch_med), thresh.pval);
bad_ch1                       = ch_names(abs(ch_std - ch_med)>rej_thresh);

ntrials                       = length(epoc.trialinfo);
nchans                        = length(ch_names);
flagged_data                  = zeros(ntrials, nchans);

for ii                        = 1:ntrials
    tr_std                    = std(epoc.trial{ii}, 0, 2);
    flagged_data(ii, :)       = abs(tr_std - ch_med) > rej_thresh;
end

bad_chan_num                  = find(sum(flagged_data, 1) > thresh.prop_badtrials * ntrials);
flagged_data(:, bad_chan_num) = zeros(ntrials, length(bad_chan_num));
bad_tr                        = find(sum(flagged_data) > 0);
bad_ch                        = ch_names((ch_std < 0.01) | (ch_std > 100));
%bad_ch                        = unique([bad_ch; ch_names(bad_chan_num); bad_ch1]);
bad_ch                        = unique([bad_ch; bad_ch1]);
%bad_tr = [];
cfg                           = [];
cfg.channel                   = setdiff(ch_names, bad_ch);
raw                           = ft_selectdata(cfg, raw);

end