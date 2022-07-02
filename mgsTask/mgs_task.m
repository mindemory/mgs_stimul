function mgs_task(subjID, session, coilLocInd, start_block)
%% Initialization
clearvars -except subjID session coilLocInd start_block;
close all; clc;% clear mex;

subjID = num2str(subjID, "%02d");
session = num2str(session, "%02d");

%%% Check the system name to ensure correct paths are added.
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

%%% Adding all necessary paths
curr_dir = pwd;
filesepinds = strfind(curr_dir,filesep);
master_dir = curr_dir(1:(filesepinds(end-1)-1));
markstim_path = [master_dir '/markstim-master'];
phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
mgs_data_path = [master_dir '/data/mgs_data/sub' subjID];
addpath(genpath(markstim_path));
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

parameters = loadParameters(subjID, coilLocInd);
%%% Load PTB and toolboxes
if strcmp(hostname, 'syndrome')
    % Location of PTB on Syndrome
    addpath(genpath('/Users/Shared/Psychtoolbox')) %% mrugank (01/28/2022): load PTB
    parameters.isDemoMode = true; %set to true if you want the screen to be transparent
    parameters.EEG = 0; % set to 0 if there is no EEG recording
    parameters.TMS = 0; % set to 0 if there is no TMS stimulation
    parameters.eyetracker = 0; % set to 0 if there is no eyetracker
    Screen('Preference','SkipSyncTests', 1)
elseif strcmp(hostname, 'tmsubuntu')
    addpath(genpath('/usr/share/psychtoolbox-3'))
    parameters.isDemoMode = false; %set to true if you want the screen to be transparent
    parameters.EEG = 1; % set to 0 if there is no EEG recording
    parameters.TMS = 1; % set to 0 if there is no TMS stimulation
    parameters.eyetracker = 1; % set to 0 if there is no eyetracker
    PsychDefaultSetup(1);
else
    disp('Running on unknown device. Psychtoolbox might not be added correctly!')
end

sca;
screen = initScreen(parameters);

[kbx, parameters] = initPeripherals(parameters, hostname);

for block = start_block:42
    parameters.block = num2str(block, "%02d");
    parameters = initFiles(parameters, screen, mgs_data_path, kbx, block);
    % Initialize taskMap
    load([phosphene_data_path '/PhospheneReport_sub' subjID '_sess' session])
    taskMap = PhosphReport(coilLocInd).taskMap(block);
    trialNum = length(taskMap.stimLocpix);
    %% Start Experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MarkStim CHECK!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % detect the MarkStim and perform handshake make sure that the orange
    % light is turned on! If not, press the black button on Teensy.
    if parameters.TMS
        % Checks for possible identifiers of Teensy
        dev_num = 0;
        devs = dir('/dev/');
        while 1
            dev_name = ['ttyACM', num2str(dev_num)];
            if any(strcmp({devs.name}, dev_name))
                break
            else
                dev_num = dev_num + 1;
            end
        end
        trigger_id = ['/dev/', dev_name]
        MarkStim('i', trigger_id)
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize eyetracker
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    KbQueueFlush(kbx);
    if block == start_block
        while 1
            KbQueueStart(kbx);
            [keyIsDown, ~]=KbQueueCheck(kbx);
            while ~keyIsDown
                showprompts(screen, 'WelcomeWindow')
                [keyIsDown, ~]=KbQueueCheck(kbx);
            end
            break;
        end
    end
    
    if parameters.eyetracker ~= 0
        % Initialize Eye Tracker and perform calibration
        if ~parameters.eyeTrackerOn
            ListenChar(0);
            initEyeTracker(parameters, screen);
            FlushEvents;
            ListenChar(-1);
        else
            Eyelink('Openfile', parameters.edfFile);
        end
    end
    
    % Init start of experiment procedures
    if parameters.eyetracker
        Eyelink('StartRecording');
        WaitSecs(0.1);
        % synchronize time in edf file
        Eyelink('Message', 'SYNCTIME');
    end
    ListenChar(-1);
    drawTextures(parameters, screen, 'Aperture');
    showprompts(screen, 'BlockStart', block, taskMap.condition)
    
    WaitSecs(2);
    
    drawTextures(parameters, screen, 'Aperture');
    drawTextures(parameters, screen, 'FixationCross');
    
    timeReport = struct;
    timeReport = repmat(timeReport, [1, trialNum]);
    
    trialArray = 1:trialNum;
    ITI = Shuffle(repmat(parameters.itiDuration, [1 trialNum/2]));
    %% run over trials
    for trial = trialArray
        % EEG marker --> trial begins
        if parameters.TMS
            MarkStim('t', 10);
        end
        
        disp(['runing trial  ' num2str(trial, '%02d') ' ....'])
        
        if parameters.eyetracker
            Eyelink('command', 'record_status_message "TRIAL %i/%i "', ...
                trial, trialNum);
            Eyelink('Message', 'TRIAL %i ', trial);
        end
        trial_start = GetSecs;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Run a trial
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        while GetSecs-trial_start<=parameters.sampleDuration+parameters.delayDuration
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % sample window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            sampleStartTime = GetSecs;
            % EEG marker --> Sample begins
            if parameters.EEG
                MarkStim('t', 20);
            end
            %record to the edf file that sample is started
            if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
                Eyelink('command', 'record_status_message "TRIAL %i/%i /sample"', trial, trialNum);
                Eyelink('Message', 'XDAT %i ', 1);
                %Eyelink('Message', 'TarX %s ', screen.xCenter);
                %Eyelink('Message', 'TarY %s ', screen.yCenter);
            end
            % draw sample and fixation cross
            while GetSecs-sampleStartTime <= parameters.sampleDuration
                dotSize = taskMap.dotSizeStim(trial);
                dotCenter = taskMap.stimLocpix(trial, :);
                drawTextures(parameters, screen, 'Aperture');
                drawTextures(parameters, screen, 'Stimulus', screen.white, dotSize, dotCenter);
                drawTextures(parameters, screen, 'FixationCross');
            end
            timeReport(trial).sampleDuration = GetSecs-sampleStartTime;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Delay1 window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            delay1StartTime = GetSecs;
            if parameters.EEG
                MarkStim('t', 30);
            end
            %record to the edf file that delay1 is started
            if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
                Eyelink('command', 'record_status_message "TRIAL %i/%i /delay1"', trial, trialNum);
                Eyelink('Message', 'XDAT %i ', 2);
            end
            % Draw fixation cross
            while GetSecs-delay1StartTime <= parameters.delay1Duration
                drawTextures(parameters, screen, 'Aperture');
                drawTextures(parameters, screen, 'FixationCross');
            end
            timeReport(trial).delay1Duration = GetSecs - delay1StartTime;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % TMS pulse window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pulseStartTime = GetSecs;
            % EEG marker --> TMS pulse begins
            if parameters.EEG
                if parameters.TMS
                    MarkStim('t', 168); % 128 for TMS + 40 for EEG marker
                else
                    MarkStim('t', 40);
                end
            else
                if parameters.TMS
                    MarkStim('t', 128); % 128 for TMS
                end
            end
            %record to the edf file that noise mask is started
            if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
                Eyelink('command', 'record_status_message "TRIAL %i/%i /tmsPulse"', trial, trialNum);
                Eyelink('Message', 'XDAT %i ', 3);
            end
            WaitSecs(parameters.pulseDuration);
            timeReport(trial).pulseDuration = GetSecs - pulseStartTime;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Delay2 window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            delay2StartTime = GetSecs;
            % EEG marker --> Delay2 begins
            if parameters.EEG
                MarkStim('t', 50);
            end
            %record to the edf file that delay2 is started
            if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
                Eyelink('command', 'record_status_message "TRIAL %i/%i /delay2"', trial, trialNum);
                Eyelink('Message', 'XDAT %i ', 4);
            end
            % Draw fixation cross
            while GetSecs-delay2StartTime<=parameters.delay2Duration
                drawTextures(parameters, screen, 'Aperture');
                drawTextures(parameters, screen, 'FixationCross');
            end
            timeReport(trial).delay2Duration = GetSecs - delay2StartTime;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Response Cue window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            respCueStartTime = GetSecs;
            % EEG marker --> Response cue begins
            if parameters.EEG
                MarkStim('t', 60);
            end
            saccLoc = taskMap.saccLocpix(trial, :);
            %record to the edf file that response cue is started
            if parameters.eyetracker% && Eyelink('NewFloatSampleAvailable') > 0
                Eyelink('command', 'record_status_message "TRIAL %i/%i /responseCue"', trial, trialNum);
                Eyelink('Message', 'XDAT %i ', 5);
                Eyelink('Message', 'TarX %s ', num2str(saccLoc(1)));
                Eyelink('Message', 'TarY %s ', num2str(saccLoc(2)));
            end
            % Draw green fixation cross
            while GetSecs-respCueStartTime < parameters.respCueDuration
                drawTextures(parameters, screen, 'Aperture');
                drawTextures(parameters, screen, 'FixationCross', parameters.cuecolor);
            end
            timeReport(trial).respCueDuration = GetSecs - respCueStartTime;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Response window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            respStartTime = GetSecs;
            % EEG marker --> response begins
            if parameters.EEG
                MarkStim('t', 70)
            end
            %record to the edf file that response is started
            if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
                Eyelink('command', 'record_status_message "TRIAL %i/%i /response"', trial, trialNum);
                Eyelink('Message', 'XDAT %i ', 6);
                Eyelink('command', 'record_status_message "TRIAL %i/%i /saccadeCoords"', trial, trialNum);
            end
            %draw the fixation dot
            while GetSecs-respStartTime<=parameters.respDuration
                drawTextures(parameters, screen, 'Aperture');
                drawTextures(parameters, screen, 'FixationCross');
            end
            timeReport(trial).respDuration = GetSecs - respStartTime;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Feedback window
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            feedbackStartTime = GetSecs;
            % EEG marker --> feedback begins
            if parameters.EEG
                MarkStim('t', 80);
            end
            %record to the edf file that feedback is started
            if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
                Eyelink('command', 'record_status_message "TRIAL %i/%i /feedback"', trial, trialNum);
                Eyelink('Message', 'XDAT %i ', 7);
            end
            % draw the fixation dot
            while GetSecs-feedbackStartTime<=parameters.feedbackDuration
                dotSize = taskMap.dotSizeSacc(trial);
                dotCenter = taskMap.saccLocpix(trial, :);
                drawTextures(parameters, screen, 'Aperture');
                drawTextures(parameters, screen, 'Stimulus', parameters.feebackcolor, dotSize, dotCenter);
                drawTextures(parameters, screen, 'FixationCross');
            end
            timeReport(trial).feedbackDuration = GetSecs-feedbackStartTime;
        end
        
        if parameters.eyetracker
            Eyelink('Message', 'TRIAL_RESULT  0')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Intertrial window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        itiStartTime = GetSecs;
        % EEG marker --> ITI begins
        if parameters.TMS
            MarkStim('t', 90);
        end
        %record to the edf file that iti is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /iti"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 8);
            %Eyelink('Message', 'TarX %s ', screen.xCenter);
            %Eyelink('Message', 'TarY %s ', screen.yCenter);
        end
        % Draw a fixation cross
        while GetSecs-itiStartTime < ITI(trial)
            drawTextures(parameters, screen, 'Aperture');
            drawTextures(parameters, screen, 'FixationCross');
        end
        timeReport(trial).itiDuration = GetSecs - itiStartTime;
        timeReport(trial).trialDuration = GetSecs-sampleStartTime;
    end
        
    %% Saving Data and Closing everything
    % stop eyelink and save eyelink data
    if parameters.eyetracker
        Eyelink('StopRecording');
        Eyelink('ReceiveFile', 'temp.edf');
        movefile('temp.edf', parameters.edfFile);
        Eyelink('Shutdown');
        disp(['Eyedata recieve for ' num2str(block,"%02d") ' OK!']);
    end
    ListenChar(1);
    
    % save timeReport
    matFile.parameters = parameters;
    matFile.screen = screen;
    matFile.timeReport = timeReport;
    save(parameters.matFile,'matFile')
    % end Teensy handshake
    if parameters.TMS
        MarkStim('x');
    end
    
    % check for end of block
    KbQueueFlush(kbx);
    [keyIsDown, ~] = KbQueueCheck(kbx);
    while ~keyIsDown
        showprompts(screen, 'BlockEnd', block)
        [keyIsDown, keyCode] = KbQueueCheck(kbx);
        cmndKey = KbName(keyCode);
    end
    if strcmp(cmndKey, parameters.space_key)
        continue;
    elseif strcmp(cmndKey, parameters.exit_key)
        sca;
        return;
    end
end % end of block
showprompts(screen, 'EndExperiment');
WaitSecs(2);
sca;
end