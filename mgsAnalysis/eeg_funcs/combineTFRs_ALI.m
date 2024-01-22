function TFR                         = combineTFRs_ALI(freqmat, hemisphere, ...
                                                    is_ipsi, fidx)
% Left and right occipital electrodes
left_elecs                           = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_elecs                          = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

TFR                                  = struct();

if strcmp(hemisphere, 'Left')
    if is_ipsi                       == 1
        goat_elecs                   = intersect(freqmat.label, right_elecs);
        goat_elecs_idx               = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs                   = {'lol'};
    else
        goat_elecs                   = intersect(freqmat.label, left_elecs);
        goat_elecs_idx               = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs                   = {'lol'};
    end
elseif strcmp(hemisphere, 'Right')
    if is_ipsi                       == 1
        goat_elecs                   = intersect(freqmat.label, left_elecs);
        goat_elecs_idx               = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs                   = {'lol'};
    else
        goat_elecs                   = intersect(freqmat.label, right_elecs);
        goat_elecs_idx               = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs                   = {'lol'};
    end
end

TFR.label                            = goat_elecs;
TFR.dimord                           = freqmat.dimord;
TFR.freq                             = freqmat.freq;
TFR.time                             = freqmat.time;
TFR.powspctrm                        = mean(freqmat.powspctrm(:, goat_elecs_idx, fidx, :), [2 3], 'omitnan');
TFR.cfg                              = freqmat.cfg;
TFR.cfg.channel                      = goat_elecs;
end