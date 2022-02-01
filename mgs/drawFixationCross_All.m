function fixAll = drawFixationCross_All(fixCrossData)
    global screen;
    global parameters;
    
    xCenter = screen.xCenter;
    yCenter = screen.yCenter;

    fixCrossList = fieldnames(fixCrossData);
    fixAll = struct();
    for fixInd = 1:length(fixCrossList)
        
       fixID = fixCrossList{fixInd};
       fixCross = getfield(fixCrossData,fixID);
       
       sc = Screen('MakeTexture', screen.win, fixCross);
       fixAll = setfield(fixAll,fixID,'sc',sc);
       
       rect = [ xCenter-parameters.fixationCrossSizePix ...
                yCenter-parameters.fixationCrossSizePix ...
                xCenter+parameters.fixationCrossSizePix ...
                yCenter+parameters.fixationCrossSizePix];

       fixAll = setfield(fixAll,fixID,'Rect',rect);
       
    end
    
end