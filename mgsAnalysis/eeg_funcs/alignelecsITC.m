function ITC_mat                                 = alignelecsITC(freqmat, hemisphere, varargin)
% Created by Mrugank (09/04/2023): Reorganize the freqmat file so that the
% right hemisphere electrodes are flipped to left and vice versa.
if strcmp(hemisphere, 'Right')
    electrode_labels                             = freqmat.label;
    modified_labels                              = cell(size(electrode_labels));
    pattern                                      = '(\D+)(\d+)$';

    for i                                        = 1:numel(electrode_labels)
        label                                    = electrode_labels{i};
        [tokens, matches]                        = regexp(label, pattern, 'tokens', 'match');

        if ~isempty(matches)
            electrode_name                       = tokens{1}{1};
            electrode_num                        = str2double(tokens{1}{2});
            % If the number is even, subtract 1
            % If the number is odd, add 1
            if mod(electrode_num, 2)             == 0
                new_electrode_num                = electrode_num - 1;
            else
                new_electrode_num                = electrode_num + 1;
            end
            modified_labels{i}                   = [electrode_name, num2str(new_electrode_num)];
        else
            % No match found, leave the label unchanged for electrodes
            % along midline
            modified_labels{i}                   = label;
        end
    end
    [~, remap_idx]                               = ismember(modified_labels, electrode_labels);
    freqmat.itcspctrm                            = freqmat.itcspctrm(:, remap_idx, :, :);
    %freqmat.cfg.channel                          = modified_labels;
end

freqmat.dimord                                   = 'chan_freq_time';
freqmat.itcspctrm                                = squeeze(mean(freqmat.itcspctrm, 1, 'omitnan'));
freqmat                                          = rmfield(freqmat, 'trialinfo');
%freqmat                                          = rmfield(freqmat, 'elec');

if nargin                                        < 3
    ITC_mat                                      = freqmat;
else
    ITC_mat                                      = varargin{1};
    ITC_mat.itcspctrm                            = mean(cat(4, ITC_mat.itcspctrm, freqmat.itcspctrm), 4, 'omitnan');
end
end