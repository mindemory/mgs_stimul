function ITC                         = combineITCs(freqmat, hemisphere, ...
                                                    is_ipsi, varargin)
% Left and right occipital electrodes
left_elecs                           = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_elecs                          = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

if nargin < 4
    ITC                              = struct();
else
    ITC                              = varargin{1};
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

ITC.label                            = goat_elecs;
ITC.dimord                           = freqmat.dimord;
ITC.freq                             = freqmat.freq;
ITC.time                             = freqmat.time;

if isfield(ITC, 'itcspctrm')
    temp_itcspctrm                   = mean(freqmat.itcspctrm(:, goat_elecs_idx, :, :), [1, 2], 'omitnan');
    ITC.itcspctrm                    = mean([ITC.itcspctrm; temp_itcspctrm], 1, 'omitnan');
else
    ITC.itcspctrm                    = mean(freqmat.itcspctrm(:, goat_elecs_idx, :, :), [1, 2], 'omitnan');
end

ITC.cfg                              = freqmat.cfg;
ITC.cfg.channel                      = goat_elecs;
end