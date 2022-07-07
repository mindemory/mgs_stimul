function parameters = loadParameters(tmsRtnTpy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% program basic settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.rbuffer = 2; % degrees of visual angle
parameters.dotSize = 0.35; % degrees of visual angle
parameters.maxRadius = 13.5; % degrees of visual angle
parameters.minRadius = 5; % degrees of visual angle

parameters.xCenter = tmsRtnTpy.Params.screen.xCenter;
parameters.yCenter = tmsRtnTpy.Params.screen.yCenter;
parameters.screenXpixels = tmsRtnTpy.Params.screen.screenXpixels;
parameters.screenYpixels = tmsRtnTpy.Params.screen.screenYpixels;
parameters.pixSize = tmsRtnTpy.Params.screen.pixSize; %cm/pixel
parameters.viewingDistance = tmsRtnTpy.Params.taskParams.viewingDistance;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% number of trials for each condition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.numTrials = 40; % make sure it is a multiple of 2
parameters.numBlocks = 30;
end
