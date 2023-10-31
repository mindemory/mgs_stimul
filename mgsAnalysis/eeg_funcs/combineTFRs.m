function TFR                         = combineTFRs(freqmat, hemisphere, ...
                                                    is_ipsi, varargin)
% Left and right occipital electrodes
left_elecs                           = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_elecs                          = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

if nargin < 4
    TFR                              = struct();
else
    TFR                              = varargin{1};
end
if strcmp(hemisphere, 'Left')
    if is_ipsi                       == 1
        goat_elecs                   = intersect(freqmat.label, right_elecs);
        goat_elecs_idx               = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs                   = {'O2'};
    else
        goat_elecs                   = intersect(freqmat.label, left_elecs);
        goat_elecs_idx               = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs                   = {'O1'};
    end
elseif strcmp(hemisphere, 'Right')
    if is_ipsi                       == 1
        goat_elecs                   = intersect(freqmat.label, left_elecs);
        goat_elecs_idx               = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs                   = {'O2'};
    else
        goat_elecs                   = intersect(freqmat.label, right_elecs);
        goat_elecs_idx               = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs                   = {'O1'};
    end
end

TFR.label                            = goat_elecs;
TFR.dimord                           = freqmat.dimord;
TFR.freq                             = freqmat.freq;
TFR.time                             = freqmat.time;

if isfield(TFR, 'powspctrm')
    temp_powspctrm                   = mean(freqmat.powspctrm(:, goat_elecs_idx, :, :), [1, 2], 'omitnan');
    TFR.powspctrm                    = mean([TFR.powspctrm; temp_powspctrm], 1, 'omitnan');
else
    TFR.powspctrm                    = mean(freqmat.powspctrm(:, goat_elecs_idx, :, :), [1, 2], 'omitnan');
end

TFR.cfg                              = freqmat.cfg;
TFR.cfg.channel                      = goat_elecs;
end