function mean_phase = get_circmean(phase_data)
% Assuming your 4-D array is called 'phase_data' with dimensions (num_trials x num_channels x num_freqs x num_time_points)
% You want to calculate the circular mean across dimensions 2 (num_channels) and 3 (num_freqs)

% Dimensions of your data
[num_trials, num_channels, num_freqs, num_time_points] = size(phase_data);

% Initialize an array to store the mean phase values
mean_phase = zeros(num_trials, num_time_points);

% Loop over trials and time points
for trial = 1:num_trials
    for time_point = 1:num_time_points
        % Extract the phase values for the current trial and time point
        phase_values = squeeze(phase_data(trial, :, :, time_point));
        
        % Reshape the phase values to work with circ_mean
        phase_values = reshape(phase_values, [num_channels * num_freqs, 1]);
        
        % Calculate the circular mean
        mean_phase(trial, time_point) = circ_mean(phase_values);
    end
end

end
