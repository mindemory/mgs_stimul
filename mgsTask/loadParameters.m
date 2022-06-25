function parameters = loadParameters(subjID, block, coilLocInd)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% program basic settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.EEG = 0; % set to 0 if there is no EEG recording
parameters.TMS = 0; % set to 0 if there is no TMS stimulation
parameters.eyetracker = 0; % set to 0 if there is no eyetracker
parameters.eyeTrackerOn = 0;
parameters.isDemoMode = true; %set to true if you want the screen to be transparent
parameters.transparency = 0.7; % transparency for debug mode
parameters.viewingDistance = 55;%viewDist
parameters.waitBeforePulse = 3.00; % seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% study parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.currentStudy = 'MGS_TMS_VisualCortex';
parameters.currentStudyVersion = '01';
parameters.subject = subjID;
parameters.block = block;
parameters.coilLocInd = coilLocInd;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.procolor = [256 0 0];
parameters.anticolor = [256 0 0];
parameters.cuecolor = [0 256 0];
parameters.feebackcolor = [0 256 0];
parameters.fixationSizeDeg = 0.6;
parameters.fixationBoundary = 66;%pixels
parameters.stimulusSizeDeg = 0.6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TMS pulse parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.pulseFrequency = 50;
parameters.pulseNum = 2;
parameters.pulseDuration = parameters.pulseNum/parameters.pulseFrequency;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timing parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.sampleDuration = 0.200;
parameters.delayDuration = 4;
parameters.delay1Duration = parameters.delayDuration/2;
parameters.delay2Duration = parameters.delayDuration-parameters.delay1Duration-parameters.pulseDuration;
parameters.respCueDuration = 0.150;
parameters.respDuration = 0.700;
parameters.feedbackDuration = 0.500;
parameters.itiDuration = [2,3];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% text parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.fixationPrepInstructions = sprintf('Please press any key and \n keep focused at the central fixation point for 5 seconds');
parameters.thankYouMsg = sprintf('Thank you for your participation!');
parameters.text_color = [0 0 0];
end
