function loadParameters()
    %   set experimental parameters
    global parameters;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % program basic settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.dummymode = 1; % set to 0 if you want to use eyetracker
    parameters.isDemoMode = false; %set to true if you want the screen to be transparent
    parameters.hideCursor = true;
    parameters.transparency = 0.8;
    parameters.viewingDistance = 58;%viewDist
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % study parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    parameters.currentStudy = 'MGS_TMS_VisulCortex';
    parameters.currentStudyVersion = 1;
    parameters.runNumber = 1;
    parameters.session = 1;
    parameters.subjectId = 0;
    parameters.runVersion = 1; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % file parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    parameters.datafile = 'unitled.csv';
    parameters.matfile = 'untitled.mat';
    parameters.taskMapFile = 'untitled_taskMap.mat';
    parameters.logFile = 'untitled_log.txt';
    parameters.edfFile = 'untd.edf'; % can only be 4 characters long
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
    parameters.numTrials.all = 42;
    parameters.numTrials.shamIn = parameters.numTrials.all/6;
    parameters.numTrials.shamOut = parameters.numTrials.all/6;
    parameters.numTrials.In = parameters.numTrials.all/3;
    parameters.numTrials.Out = parameters.numTrials.all/3;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TMS pulse parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.Pulse.Frequency = 30;
    parameters.Pulse.num = 3;
    parameters.Pulse.Duration = parameters.Pulse.num/parameters.Pulse.Frequency;
    parameters.Pulse.Hemisphere = [2 1]; %???
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % timing parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.delayDuration = [3 4];    
    parameters.dummyDuration = 1.5;
    parameters.sampleDuration = 0.200; 
    parameters.delay1Duration = .5;
    parameters.Pulse.Duration;
    parameters.delay2Duration = parameters.delayDuration - parameters.delay1Duration;
    parameters.respCueDuration = 0.150;
    parameters.respDuration = 0.500;
    parameters.feedbackDuration = 0.500;
    parameters.itiDuration = [2,3];
    parameters.trialDuration = parameters.sampleDuration + mean(parameters.delayDuration) + parameters.Pulse.Duration + parameters.respCueDuration + ...
                               parameters.respDuration + parameters.feedbackDuration + mean(parameters.itiDuration);                           
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
    parameters.greyFactor = 0.6; % to make screen background darker or lighter    
    parameters.fixationCrossSizeDeg = 0.3;
    parameters.fixationCrossSizePix =12; % size of fixation cross in pixels by default        
end
