function data = generate_data(time)

freqs = 1:50;
amplitudes = randi(20, 1, length(freqs)) + 100 * normpdf(freqs, 10, 2.5);
nFreqs = length(freqs);
nTime = length(time);
nTrials = 300;
data_matrix = zeros(nFreqs, nTime, nTrials);

for trial = 1:nTrials
    for ff = 1:nFreqs
        freq = freqs(ff);
        amp = amplitudes(ff) + 2 * randn(1, 1);
        phase = randsample(-2*pi:0.01:2*pi, 1);
        signal = amp * sin(2*pi*freq.*time + phase);
        data_matrix(ff, :, trial) = signal;
        
    end
    imagesc(data_matrix(:, :, trial))
end
%DCoffset=-.5;

% create multi-frequency signal
%a = sin(2*pi*10.*time);             % part 1 of signal (high frequency)
%b = .1*sin(2*pi*.3*time)+DCoffset;  % part 2 of signal (low frequency)

%data = a.*b; % combined signal
%data = data + (2*sin(2*pi*3*time) .* sin(2*pi*.07*time)*.1+DCoffset);

data = mean(data_matrix, [1, 3]);
end