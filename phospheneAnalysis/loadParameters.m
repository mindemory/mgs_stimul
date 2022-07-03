function parameters = loadParameters(tmsRtnTpy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% program basic settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.rbuffer = 2; % degrees of visual angle
parameters.dotSize = 0.3; % degrees of visual angle
parameters.maxRadius = 14.5; % degrees of visual angle
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
parameters.numTrials = 20; % make sure it is a multiple of 2
parameters.numBlocks = 20;
end
