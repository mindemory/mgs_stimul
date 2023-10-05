function TFR_mat = alignelecs(freqmat, hemisphere, varargin)

if strcmp(hemisphere, 'Right')
    
    electrode_labels = freqmat.label;
    modified_labels = cell(size(electrode_labels));
    pattern = '(\D+)(\d+)$';

    for i = 1:numel(electrode_labels)
        label = electrode_labels{i};
        [tokens, matches] = regexp(label, pattern, 'tokens', 'match');

        if ~isempty(matches)
            electrode_name = tokens{1}{1};
            electrode_num = str2double(tokens{1}{2});

            if mod(electrode_num, 2) == 0
                % If the number is even, subtract 1
                new_electrode_num = electrode_num - 1;
            else
                % If the number is odd, add 1
                new_electrode_num = electrode_num + 1;
            end
            % Construct the new electrode label
            modified_labels{i} = [electrode_name, num2str(new_electrode_num)];
        else
            % No match found, leave the label unchanged
            modified_labels{i} = label;
        end
    end
    freqmat.label = modified_labels;
    freqmat.cfg.channel = modified_labels;
end

if nargin < 3
    TFR_mat = freqmat;
else
    TFR_mat = varargin{1};
    TFR_mat.powspctrm = mean(cat(4, TFR_mat.powspctrm, freqmat.powspctrm), 4, 'omitnan');
end
end