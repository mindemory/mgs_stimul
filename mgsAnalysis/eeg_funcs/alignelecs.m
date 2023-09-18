function TFR_mat = alignelecs(freqmat, hemisphere, varargin)
left_elecs = {'Fp1', 'AF7', 'AF3', 'F7', 'F5', 'F3', 'F1', 'FT9', 'FT7', ...
              'FC5', 'FC3', 'FC1', 'T7', 'C5', 'C3', 'C1', 'TP9', 'TP7', ...
              'CP5', 'CP3', 'CP1', 'P7', 'P5', 'P3', 'P1', 'PO7', 'PO3', ...
              'O1'}';
right_elecs = {'Fp2', 'AF8', 'AF4', 'F8', 'F6', 'F4', 'F2', 'FT10', 'FT8', ...
               'FC6', 'FC4', 'FC2', 'T8', 'C6', 'C4', 'C2', 'TP10', 'TP8', ...
               'CP6', 'CP4', 'CP2', 'P8', 'P6', 'P4', 'P2', 'PO8', 'PO4', ...
               'O2'}';
middle_elecs = {'AFz', 'Fz', 'FCz', 'Cz', 'CPz', 'Pz', 'POz', 'Oz'}';

all_elecs = cat(1, left_elecs, right_elecs, middle_elecs);
missing_elecs_idx = ~ismember(all_elecs, freqmat.label);
missing_elecs = all_elecs(missing_elecs_idx);
elecs_N = length(missing_elecs);
freq_N = length(freqmat.freq);
time_N = length(freqmat.time);
toadd_powspctrm = NaN(elecs_N, freq_N, time_N);

% Add the missing electrodes to freqmat
freqmat.label = cat(1, freqmat.label, missing_elecs);
freqmat.cfg.channel = cat(1, freqmat.cfg.channel, missing_elecs);
freqmat.powspctrm = [freqmat.powspctrm; toadd_powspctrm];


if strcmp(hemisphere, 'Right')
    replaced_elecs = {};
    for ii = 1:length(freqmat.label)
        this_elec = freqmat.label{ii};
        if ismember(left_elecs, this_elec)
            replaced_elecs{end+1} = right_elecs(ismember(left_elecs, this_elec));
        elseif ismember(right_elecs, this_elec)
            replaced_elecs{end+1} = left_elcs(ismember(right_elecs, this_elec));
        else
            replaced_elecs{end+1} = this_elec;
        end
    end
    freqmat.label = replaced_elecs;
    freqmat.cfg.channel = replaced_elecs;
end

if nargin < 3
    TFR_mat = freqmat;
else
    TFR_mat = varargin{1};
    TFR_mat.powspctrm = mean(cat(4, TFR_mat.powspctrm, freqmat.powspctrm), 4, 'omitnan');
end
TFR_mat.missing_elecs = missing_elecs;
end