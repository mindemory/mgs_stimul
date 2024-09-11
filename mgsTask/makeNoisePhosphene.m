function [noiseTexIn, noiseTexOut] = makeNoisePhosphene(parameters, screen, TFin, TFout)
% created by Mrugank (09/09/2024):

% Simulate a 2D gaussian noise patch
colTEMP =  screen.grey + (screen.white - screen.grey) * 1;
noiseMask = normrnd(colTEMP, 2, size(TFin,2), size(TFin, 3));
% noiseMask = screen.grey + noiseMask;

method = 'trial'; % can be trial, intersect, union
noiseTexIn = NaN(size(TFin, 1), size(TFin, 2), size(TFin, 3));
noiseTexOut = NaN(size(TFin, 1), size(TFin, 2), size(TFin, 3));

switch method
    case 'trial'
        %% For choosing trial
        
        ntrls = size(TFin, 1);
        
        for trlIdx = 1:ntrls
            thisPhosphIn = squeeze(TFin(trlIdx, :, :));
            thisPhosphOut = squeeze(TFout(trlIdx, :, :));
            
            noiseMatIn = screen.grey + thisPhosphIn .* noiseMask;
            noiseMatOut = screen.grey + thisPhosphOut .* noiseMask;
            noiseTexIn(trlIdx, :, :) = noiseMatIn;
            noiseTexOut(trlIdx, :, :) = noiseMatOut;
%             noiseTexIn(trlIdx,:,:)  = Screen('MakeTexture', screen.win, noiseMatIn);
%             noiseTexOut(trlIdx,:,:) = Screen('MakeTexture', screen.win, noiseMatOut);
        end
%         trlIdx = randi(ntrls);
%         thisPhosphIn = squeeze(TFin(trlIdx, :, :));
%         thisPhosphOut
        
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

% tN = GetSecs();
% for i = 1:5
%     Screen('DrawTexture', screen.win, noiseTex, []);
% end
% tend = GetSecs();
% tend-tN

end
