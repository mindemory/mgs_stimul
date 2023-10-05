function master_statmat = alignelecs_stat(statmat, hemisphere, varargin)

% statmat.mask = squeeze(statmat.mask);
% statmat.prob = squeeze(statmat.prob);
% statmat.stat = squeeze(statmat.stat);
% statmat.dimord = 'chan_time';

if strcmp(hemisphere, 'Right')
    electrode_labels = statmat.label;
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
    statmat.label = modified_labels;
    statmat.cfg.channel = modified_labels;
end

if nargin < 3
    master_statmat = statmat;
else
    master_statmat = varargin{1};
    master_statmat.mask = double(any(cat(2, master_statmat.mask, statmat.mask), 2));
    master_statmat.prob = mean(cat(2, master_statmat.prob, statmat.prob), 2);
    master_statmat.stat = mean(cat(2, master_statmat.stat, statmat.stat), 2);
end
end