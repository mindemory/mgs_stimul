function drawNoisePhosphene(parameters, screen, TF)
% created by Mrugank (09/09/2024):

% Simulate a 2D gaussian noise patch
noiseMask = normrnd(0, 2, size(TF,1), size(TF, 2));

%% For choosing trial
ntrls = size(TF, 1);
trlIdx = randi(ntrls);
thisPhosphIn = squeeze(TF(trlIdx, :, :));

% Create noiseMat by multiplying mask with logical
noiseMat = TF .* noiseMask;


noiseTex = Screen('MakeTexture', screen.win, noiseMat);
Screen('DrawTexture', screen.win, noiseTex, []);

end
