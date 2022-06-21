function parameters = loadParameters(subjID, session)
    %   loads experimental parameters
    global parameters;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % program basic settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.EEG = 0; % set to 0 if there is no EEG recording
    parameters.TMS = 1; % set to 0 if there is no TMS stimulation
    parameters.dummymode = 1; % set to 0 if you want to use eyetracker
    parameters.isDemoMode = false; %set to true if you want the screen to be transparent
    parameters.hideCursor = true;
    parameters.transparency = 0.8; % transparency for debug mode
    parameters.viewingDistance = 55;%viewDist
    parameters.waitBeforePulse = 3.00; % seconds
    parameters.rbuffer = 0.5; % degrees of visual angle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % study parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    parameters.currentStudy = 'MGS_TMS_VisualCortex';
    parameters.currentStudyVersion = '01';
    parameters.session = session;
    parameters.subject = subjID;
    parameters.runNumber = 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % file parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%     parameters.datafile = 'unitled.csv';
%     parameters.matfile = 'untitled.mat';
%     parameters.taskMapFile = 'untitled_taskMap.mat';
%     parameters.edfFile = 'untd.edf'; % can only be 4 characters long
%     parameters.logFile = 'untitled_log.txt';
%     parameters.runTaskMapFile = 'untitled_runTaskMap.mat';
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %parameters.numTrials.shamIn = parameters.numTrials.all/6;
    %parameters.numTrials.shamOut = parameters.numTrials.all/6;
    parameters.numTrials.In = parameters.numTrials.all/3;
    parameters.numTrials.Out = parameters.numTrials.all/3;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TMS Pulse parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.Pulse.Frequency = 30;
    parameters.Pulse.num = 3;
    parameters.Pulse.Duration = parameters.Pulse.num/parameters.Pulse.Frequency;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % timing parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.sampleDuration = 0.200; 
    parameters.delayDuration = 4; %[3 4];    
    parameters.dummyDuration = 1.5;
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
    % prompt parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.font_size = 30;
    parameters.text_color = [128 0 0];
    parameters.fixation_color = [128 0 0];
    parameters.instructions = ['During the task you will be constantly seeing a black screen. \n' ...
        'Whenever there is a red fixation cross at the center of the screen, make sure to fixate on it.\n' ...
        'The prompts will guide you through the task. Use 1, 2, 3 keys on numpads on the right-side of the keyboard. \n' ...
        'Whenever you see a phosphene after the TMS pulse, use mouse to draw the phosphene.\n To begin drawing ' ...
        'make a left click and hold and drag the mouse to create the shape.\n Make a second mouse click to finish drawing. '...
        'If, however, you do not see a phosphene,\n make a right click and wait for the next prompt.\n' ...
        'Press any key to continue!'];
    parameters.first_msg = '\n2: new coil location.\n3: terminate this run!\n2/3?: ';
    parameters.second_msg = '1: new trial.\n2: new coil location.\n3: terminate this run!\n1/2/3: ';
    parameters.no_phosph_msg = 'subject reported no phosphene';
    parameters.new_coil_msg = 'new coil location requested';
    parameters.quit_msg = 'program terminated by the experimenter!';
    
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
end
