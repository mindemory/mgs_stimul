function parameters = loadParameters(subjID)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% program basic settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.eyeTrackerOn = 0;
parameters.transparency = 0.6; % transparency for debug mode
parameters.viewingDistance = 55; % viewDist (in cm)
parameters.waitBeforePulse = 3.00; % seconds
parameters.apertureSize = 28; % in degrees of visual angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% study parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.studyname = 'MGS_TMS_V1';
parameters.subject = subjID;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.procolor = [255 0 0]; % red
parameters.anticolor = [255 0 0]; % red
parameters.cuecolor = [0 255 0]; % green
parameters.feebackcolor = [0 255 0]; % green
parameters.fixationSizeDeg = 0.6; % degrees of visual angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TMS pulse parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.pulseFrequency = 20; % in Hz
parameters.pulseNum = 3; % Pulse count
parameters.pulseDuration = (parameters.pulseNum-1)/parameters.pulseFrequency; % in seconds
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % timing parameters (in seconds)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters.sampleDuration = 0.5;
% parameters.delayDuration = 4;
% parameters.delay1Duration = parameters.delayDuration/2;
% parameters.delay2Duration = parameters.delayDuration-parameters.delay1Duration-parameters.pulseDuration;
% parameters.respCueDuration = 0.15;
% parameters.respDuration = 0.7;
% %parameters.respDuration = 0.85;
% parameters.feedbackDuration = 0.8;
% parameters.itiDuration = [2,3];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timing parameters (in seconds)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.initDuration = 1;
parameters.sampleDuration = 0.5;
parameters.delayDuration = 4;
parameters.delay1Duration = parameters.delayDuration/2;
parameters.delay2Duration = parameters.delayDuration/2;%-parameters.delay1Duration-parameters.pulseDuration;
parameters.respCueDuration = 0.15;
parameters.respDuration = 0.85;
parameters.feedbackDuration = 0.8;
parameters.itiDuration = [1,2];
% parameters.initDuration = 0.1;
% parameters.sampleDuration = 0.1;
% parameters.delayDuration = 0.2;
% parameters.delay1Duration = parameters.delayDuration/2;
% parameters.delay2Duration = parameters.delayDuration/2;%-parameters.delay1Duration-parameters.pulseDuration;
% parameters.respCueDuration = 0.1;
% parameters.respDuration = 0.1;
% parameters.feedbackDuration = 0.1;
% parameters.itiDuration = [0.1,0.2];
end
