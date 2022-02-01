function drawFixationCross(fixCrossData)
    global screen;
    global parameters;
    
    xCenter = screen.xCenter;
    yCenter = screen.yCenter;

    
    %Trial fixation
    % make texture image out of image matrix 'imdata'
    fix=Screen('MakeTexture', screen.win, fixCrossData);
   
    fixRect = [ xCenter-parameters.fixationCrossSizePix ...
                yCenter-parameters.fixationCrossSizePix ...
                xCenter+parameters.fixationCrossSizePix ...
                yCenter+parameters.fixationCrossSizePix];
    
          
    Screen('DrawTexture', screen.win, fix,[],fixRect); %fixaton dot
    
end