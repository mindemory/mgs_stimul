function drawNoisePhosphene(parameters, screen, TF)
% created by Mrugank (09/09/2024):

% Simulate a 2D gaussian noise patch
colTEMP =  screen.grey + (screen.white - screen.grey) * 1;
noiseMask = normrnd(colTEMP, 2, size(TF,2), size(TF, 3));
% noiseMask = screen.grey + noiseMask;

method = 'trial'; % can be trial, intersect, union
switch method
    case 'trial'
        %% For choosing trial
        ntrls = size(TF, 1);
        trlIdx = randi(ntrls);
        thisPhosphIn = squeeze(TF(trlIdx, :, :));
        
    case 'union'
        %% For choosing union of phosphenes
        ntrls = size(TF, 1);
        trlIdx = randi(ntrls);
        thisPhosphIn = squeeze(TF(trlIdx, :, :));
        for i = 2:ntrls
            thisPhosphIn = thisPhosphIn | squeeze(TF(trlIdx, :, :));
        end
        
    case 'intersect'
        %% For choosing intersection of phosphenes
        ntrls = size(TF, 1);
        trlIdx = randi(ntrls);
        thisPhosphIn = squeeze(TF(trlIdx, :, :));
        for i = 2:ntrls
            thisPhosphIn = thisPhosphIn & squeeze(TF(trlIdx, :, :));
        end
end

% % Create noiseMat by multiplying mask with logical
% noiseMat = thisPhosphIn .* noiseMask;
% Create noiseMat by multiplying mask with logical
noiseMat = screen.grey + thisPhosphIn .* noiseMask;


noiseTex = Screen('MakeTexture', screen.win, noiseMat);
Screen('DrawTexture', screen.win, noiseTex, []);

end
