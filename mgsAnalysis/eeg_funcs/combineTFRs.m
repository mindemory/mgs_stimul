function TFR_mat = combineTFRs(freqmat, hemisphere, ipsi, varargin)
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
        %goat_elecs = cellfun(@(x) [x(1:end-1), num2str(str2double(x(end))+1)], goat_elecs, 'UniformOutput', false);
    else
        goat_elecs = intersect(freqmat.label, right_elecs);
        goat_elecs_idx = find(ismember(freqmat.label, goat_elecs))';
        goat_elecs = {'O1'};
        %goat_elecs = cellfun(@(x) [x(1:end-1), num2str(str2double(x(end))-1)], goat_elecs, 'UniformOutput', false);
    end
end

% logical_idx_before = (freqmat.time > 0.8) & (freqmat.time < 2);
% idx_t_before = find(logical_idx_before);
% logical_idx_after = (freqmat.time > 3) & (freqmat.time < 4.2);
% idx_t_after = find(logical_idx_after);
% idx_t = [idx_t_before idx_t_after];
% 
% logical_freq_idx = (freqmat.freq > 10) & (freqmat.freq < 20);
% idx_f = find(logical_freq_idx);


TFR_mat.label                    = goat_elecs;
TFR_mat.dimord                   = freqmat.dimord;
TFR_mat.freq                     = freqmat.freq;
TFR_mat.time                     = freqmat.time;

if isfield(TFR_mat, 'powspctrm')
    TFR_mat.powspctrm            = mean([TFR_mat.powspctrm; freqmat.powspctrm(goat_elecs_idx, :, :)], 1, 'omitnan');
else
    TFR_mat.powspctrm            = mean(freqmat.powspctrm(goat_elecs_idx, :, :), 1, 'omitnan');
end

TFR_mat.cfg                      = freqmat.cfg;
TFR_mat.cfg.channel              = goat_elecs;



end