function loadParameters(subjID, session, task, coilLocInd)
    %   loads experimental parameters
    global parameters;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % program basic settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.EEG = 0; % set to 0 if there is no EEG recording
    parameters.TMS = 0; % set to 0 if there is no TMS stimulation
    parameters.eyetracker = 0; % set to 0 if there is no eyetracker
    parameters.isDemoMode = true; %set to true if you want the screen to be transparent
    %parameters.hideCursor = true;
    parameters.transparency = 0.7; % transparency for debug mode
    parameters.viewingDistance = 55;%viewDist
    parameters.waitBeforePulse = 3.00; % seconds
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % study parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    parameters.currentStudy = 'MGS_TMS_VisualCortex';
    parameters.currentStudyVersion = '01';
    parameters.runNumber = 1;
    parameters.session = session;
    parameters.subject = subjID;
    parameters.runVersion = 1;
    parameters.task = task;
    parameters.coilLocInd = coilLocInd;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % file parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    parameters.logFile = 'untitled_log.txt';
    parameters.runTaskMapFile = 'untitled_runTaskMap.mat';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stimulus parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.eccentricity = [10]; % visual degrees
    parameters.stimDiam = 4; % pixels
    parameters.StimContrast = 1;
    parameters.StimColor = 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % number of trials for each condition 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.numTrials.all = 40; % make sure this is a multiple of 4
    %parameters.numTrials.shamIn = parameters.numTrials.all/6;
    %parameters.numTrials.shamOut = parameters.numTrials.all/6;
    parameters.numTrials.In = parameters.numTrials.all/2;
    parameters.numTrials.Out = parameters.numTrials.all/2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TMS pulse parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.Pulse.Frequency = 50;
    parameters.Pulse.num = 2;
    parameters.Pulse.Duration = parameters.Pulse.num/parameters.Pulse.Frequency;
    %parameters.Pulse.Hemisphere = [2 1]; %???
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % timing parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.delayDuration = 4; %[3 4];    
    parameters.dummyDuration = 1.5; % what's the reason?
    parameters.sampleDuration = 0.200;
    parameters.delay1Duration = 2;
    parameters.delay2Duration = parameters.delayDuration - parameters.delay1Duration;
    parameters.respCueDuration = 0.150;
    parameters.respDuration = 0.700;
    parameters.feedbackDuration = 0.500;
    parameters.itiDuration = [2,3];
    parameters.trialDuration = parameters.sampleDuration + parameters.delayDuration + ...
        parameters.Pulse.Duration + parameters.respCueDuration + ...
        parameters.respDuration + parameters.feedbackDuration + ...
        mean(parameters.itiDuration);                           
    parameters.runDuration = parameters.numTrials.all * parameters.trialDuration + parameters.dummyDuration;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % text parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.welcomeMsg = sprintf('Please wait until the experimenter sets up parameters.');
    parameters.thankYouMsg = sprintf('Thank you for your participation!');
    parameters.ttlMsg = sprintf('Initializing Scanner...');
    parameters.startOfRunMsg = sprintf('Get ready...');
    parameters.fixationPrepInstructions = sprintf('Please press any key and \n keep focused at the central fixation point for 5 seconds');    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  geometry parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.greyFactor = 0.5; % to make screen background darker or lighter    
    parameters.fixationCrossSizeDeg = 0.3;
    parameters.fixationCrossSizePix = 12; % size of fixation cross in pixels by default        
    parameters.eyeTrackerOn = 0;
    %define a fixation boundary in case its not part of the input arguments
    parameters.fixationBoundary = 66;%pixels
end
