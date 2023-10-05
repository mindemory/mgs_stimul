function TFR_mat = combineTFRs_stat(freqmat, hemisphere, ipsi, varargin)
left_elecs = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_elecs = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

if nargin < 4
    TFR_mat = struct();
else
    TFR_mat = varargin{1};
end
if strcmp(hemisphere, 'Left')
    if ipsi == 1
        goat_elecs = intersect(freqmat.label, right_elecs);
        goat_elecs_idx = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs = {'O2'};
    else
        goat_elecs = intersect(freqmat.label, left_elecs);
        goat_elecs_idx = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs = {'O1'};
    end
elseif strcmp(hemisphere, 'Right')
    if ipsi == 1
        goat_elecs = intersect(freqmat.label, left_elecs);
        goat_elecs_idx = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs = {'O2'};
    else
        goat_elecs = intersect(freqmat.label, right_elecs);
        goat_elecs_idx = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs = {'O1'};
    end
end

TFR_mat.label                    = goat_elecs;
TFR_mat.dimord                   = freqmat.dimord;
TFR_mat.freq                     = freqmat.freq;
TFR_mat.time                     = freqmat.time;

if isfield(TFR_mat, 'powspctrm')
    temp_powspctrm               = mean(freqmat.powspctrm(goat_elecs_idx, :, :), 1, 'omitnan');
    TFR_mat.powspctrm            = mean([TFR_mat.powspctrm; temp_powspctrm], 1, 'omitnan');
else
    TFR_mat.powspctrm            = mean(freqmat.powspctrm(goat_elecs_idx, :, :), 1, 'omitnan');
end

TFR_mat.cfg                      = freqmat.cfg;
TFR_mat.cfg.channel              = goat_elecs;
end