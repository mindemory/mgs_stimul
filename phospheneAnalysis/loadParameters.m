function parameters = loadParameters(tmsRtnTpy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% program basic settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.rbuffer = 2; % degrees of visual angle
parameters.dotSize = 0.6; % degrees of visual angle
parameters.xCenter = tmsRtnTpy.Params.screen.xCenter;
parameters.yCenter = tmsRtnTpy.Params.screen.yCenter;
parameters.screenXpixels = tmsRtnTpy.Params.screen.screenXpixels;
parameters.screenYpixels = tmsRtnTpy.Params.screen.screenYpixels;
parameters.pixSize = tmsRtnTpy.Params.screen.pixSize; %cm/pixel
parameters.viewingDistance = tmsRtnTpy.Params.taskParams.viewingDistance;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% number of trials for each condition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.numTrials = 4; % make sure it is a multiple of 2
parameters.numBlocks = 20;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TMS Pulse parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.Pulse.Frequency = 30; % in Hz
parameters.Pulse.num = 7;
parameters.Pulse.Duration = parameters.Pulse.num/parameters.Pulse.Frequency; % in seconds
end
