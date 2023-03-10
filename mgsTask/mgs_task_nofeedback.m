function mgs_task(subjID, day, start_block, TMSamp, prac_status, anti_type, aperture)
clearvars -except subjID day start_block TMSamp prac_status anti_type aperture;
close all; clc;
% Created by Mrugank Dake, Curtis Lab, NYU (10/11/2022)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4
    TMSamp = 52; % default TMS intensity value
end
if nargin < 5
    prac_status = 0; % 0: actual session, 1: practice session
end
if nargin < 6
    anti_type = 'mirror'; % mirror: mirrored anti conditon, diagonal: diagonal anti condition
end
if nargin < 7
    aperture = 0; % 0: full screen mode, 1: stimulus drawn on aperture
end

% Check the system running on: currently accepted: syndrome, tmsubuntu
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

% Initialize parameters
subjID = num2str(subjID, "%02d"); % convert subjID to string
parameters = loadParameters(subjID);

% Initialize PTB and EEG/TMS/Eyetracking parameters
if strcmp(hostname, 'syndrome') % Syndrome is meant for debugging
    addpath(genpath('/Users/Shared/Psychtoolbox')) %% mrugank (01/28/2022): load PTB
    phosphene_data_path = ['/datc/MD_TMS_EEG/data/phosphene_data/sub' subjID];
    parameters.isDemoMode = true; % set to true if you want the screen to be transparent
    parameters.EEG = 0; % set to 0 if there is no EEG recording
    parameters.TMS = 0; % set to 0 if there is no TMS stimulation
    parameters.eyetracker = 0; % set to 0 if there is no eyetracker
    Screen('Preference','SkipSyncTests', 1)
    if prac_status == 1
        end_block = 2; % 2 blocks for practice session
        mgs_data_path = ['/datc/MD_TMS_EEG/data/mgs_practice_data/sub' subjID];
    else
        end_block = 10; % 10 blocks for main sessions
        mgs_data_path = ['/datc/MD_TMS_EEG/data/mgs_data/sub' subjID];
    end
elseif strcmp(hostname, 'tmsubuntu') % Running stimulus code for testing
    addpath(genpath('/usr/share/psychtoolbox-3'))
    parameters.isDemoMode = false; %set to true if you want the screen to be transparent
    parameters.TMS = 0; % set to 0 if there is no TMS stimulation
    % Relative paths for tmsubuntu
    curr_dir = pwd; filesepinds = strfind(curr_dir,filesep);
    master_dir = curr_dir(1:(filesepinds(end-1)-1)); 
    phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
    % Path to MarkStim
    trigger_path = [master_dir '/mgs_stimul/EEG_TMS_triggers'];
    addpath(genpath(trigger_path));
    if prac_status == 1
        parameters.EEG = 0; % set to 0 if there is no EEG recording
        end_block = 2; % 2 blocks for practice session
        mgs_data_path = [master_dir '/data/mgs_practice_data/sub' subjID];
    else
        parameters.EEG = 0; % set to 0 if there is no EEG recording (turned to 0 for debugging, 03/06/2023)
        end_block = 10; % 10 blocks for main sessions
        mgs_data_path = [master_dir '/data/mgs_data/sub' subjID];
    end
    parameters.eyetracker = 0; % set to 0 if there is no eyetracker (turned to 0 for debugging, 03/06/2023)
    PsychDefaultSetup(1);
else
    disp('Running on unknown device. Psychtoolbox might not be added correctly!')
    return;
end

% Initialize data paths
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

% Load taskMap
if prac_status == 1
    load([phosphene_data_path '/taskMapPractice_sub' subjID '_antitype_' anti_type])
else
    load([phosphene_data_path '/taskMap_sub' subjID, '_day' num2str(day, "%02d") '_antitype_' anti_type])
end

% Initialize screen and peripherals
screen = initScreen(parameters);
[kbx, parameters] = initPeripherals(parameters);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open TMS Port
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% detect the MagVenture and perform handshake.
if taskMap(1).TMScond == 1 % determine if this is a TMS task
    parameters.TMS = 1; % keeping TMS of for debugging (03/06/2023)
elseif taskMap(1).TMScond == 0
    parameters.TMS = 0;
end

if parameters.TMS > 0
    s = TMS('Open');
    TMS('Enable', s);
    TMS('Timing', s);
    TMS('Amplitude', s, TMSamp);
end

trigReport = zeros(10, 322);
masterTimeReport = struct;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for block = start_block:end_block
    trig_counter = 1;
    % EEG marker --> block begins
    if parameters.EEG
        fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
        system(fname);
        masterTimeReport.blockstart(block) = GetSecs;
        trigReport(block, trig_counter) =  1;
        trig_counter = trig_counter + 1;
    end
    parameters.block = num2str(block, "%02d");
    
    % Create folders for the block and read taskMap for current block
    if prac_status == 1
        parameters = initFiles(parameters, screen, mgs_data_path, kbx, block);
        tMap = taskMapPractice(1, block);
    else
        datapath = [mgs_data_path '/day' num2str(day, "%02d")];
        parameters = initFiles(parameters, screen, datapath, kbx, block);
        
        tMap = taskMap(1, block);
    end
    
    % Get a count of trials (it should be 40 for this experiment).
    trialNum = length(tMap.stimLocpix);      
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize eyetracker
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    KbQueueFlush(kbx);
    if block == start_block
        while 1
            KbQueueStart(kbx);
            [keyIsDown, ~] = KbQueueCheck(kbx);
            while ~keyIsDown
                showprompts(screen, 'WelcomeWindow', parameters.TMS)
                [keyIsDown, ~] = KbQueueCheck(kbx);
            end
            break;
        end
    end
    
    % Initialize Eye Tracker and perform calibration
    if parameters.eyetracker ~= 0
        if ~parameters.eyeTrackerOn
            ListenChar(0);
            el = initEyeTracker(parameters, screen);
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
    
    % Show Block Start Screen
    if aperture == 1
        drawTextures(parameters, screen, 'Aperture');
    end
    showprompts(screen, 'BlockStart', block, tMap.condition)
    WaitSecs(2);
    
    % Draw Fixation Cross
    if aperture == 1
        drawTextures(parameters, screen, 'Aperture');
    end
    drawTextures(parameters, screen, 'FixationCross');
    
    timeReport = struct;
    trialArray = 1:trialNum;
    ITI = Shuffle(repmat(parameters.itiDuration, [1 trialNum/2]));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Task Starts
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for trial = trialArray
        disp(['runing block: ' num2str(block, "%02d") ', trial: ' num2str(trial, "%02d")])
        
        % Send trial start to eyetracker
        if parameters.eyetracker
            Eyelink('command', 'record_status_message "TRIAL %i/%i "', ...
                trial, trialNum);
            Eyelink('Message', 'TRIAL %i ', trial);
        end
        
        if trial == 1 % for first trial, pause for 2 seconds
            WaitSecs(2);
        end
        trial_start = GetSecs;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % sample window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        sampleStartTime = GetSecs;
        % EEG marker --> Sample begins
        if parameters.EEG
            if strcmp(tMap.condition, 'pro')
                if tMap.stimVF(trial) == 1
                    trigger_code = 11;
                elseif tMap.stimVF(trial) == 0
                    trigger_code = 12;
                end
            elseif strcmp(tMap.condition, 'anti')
                if tMap.stimVF(trial) == 1
                    trigger_code = 13;
                elseif tMap.stimVF(trial) == 0
                    trigger_code = 14;
                end
            end
            
            fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
            system(fname);
            masterTimeReport.sample(block, trial) = GetSecs;
            trigReport(block, trig_counter) =  trigger_code;
            trig_counter = trig_counter + 1;
        end
        
        %record to the edf file that sample is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /sample"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 1);
            Eyelink('Message', 'TarX %s ', num2str(screen.xCenter));
            Eyelink('Message', 'TarY %s ', num2str(screen.yCenter));
        end
        
        % draw sample and fixation cross
        dotSize = tMap.dotSizeStim(trial);
        dotCenter = tMap.stimLocpix(trial, :);
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end
        drawTextures(parameters, screen, 'Stimulus', screen.white, dotSize, dotCenter);
        drawTextures(parameters, screen, 'FixationCross');
        
        if GetSecs - sampleStartTime < parameters.sampleDuration
            WaitSecs(parameters.sampleDuration - (GetSecs-sampleStartTime));
        end
        timeReport.sampleDuration(trial) = GetSecs-sampleStartTime;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Delay1 window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        delay1StartTime = GetSecs;
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
            system(fname);
            masterTimeReport.delay1(block, trial) = GetSecs;
            trigReport(block, trig_counter) =  2;
            trig_counter = trig_counter + 1;
        end
        
        %record to the edf file that delay1 is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /delay1"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 2);
        end
        
        % Draw fixation cross
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end
        drawTextures(parameters, screen, 'FixationCross');
        
        if GetSecs - delay1StartTime < parameters.delay1Duration
            WaitSecs(parameters.delay1Duration - (GetSecs-delay1StartTime));
        end
        timeReport.delay1Duration(trial) = GetSecs - delay1StartTime;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % TMS pulse window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pulseStartTime = GetSecs;
        % EEG marker --> TMS pulse begins
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
            system(fname);
            masterTimeReport.tms(block, trial) = GetSecs;
            trigReport(block, trig_counter) =  3;
            trig_counter = trig_counter + 1;
        end
        
        if parameters.TMS
            TMS('Train', s); % Train of TMS pulses, set pulse protocol on MagVenture Timing page
        end
        
        %record to the edf file that noise mask is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /tmsPulse"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 3);
        end
        
        % Make sure that this epoch does not run for more than desired time
        if GetSecs - pulseStartTime < parameters.pulseDuration
            WaitSecs(parameters.pulseDuration - (GetSecs - pulseStartTime));
        end
        timeReport.pulseDuration(trial) = GetSecs - pulseStartTime;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Delay2 window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        delay2StartTime = GetSecs;
        % EEG marker --> Delay2 begins
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
            system(fname);
            masterTimeReport.delay2(block, trial) = GetSecs;
            trigReport(block, trig_counter) =  4;
            trig_counter = trig_counter + 1;
        end
        %record to the edf file that delay2 is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /delay2"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 4);
        end
        % Draw fixation cross
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end
        drawTextures(parameters, screen, 'FixationCross');
        
        if GetSecs - delay2StartTime < parameters.delay2Duration
            WaitSecs(parameters.delay2Duration - (GetSecs - delay2StartTime));
        end
        timeReport.delay2Duration(trial) = GetSecs - delay2StartTime;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Response Cue window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        respCueStartTime = GetSecs;
        % EEG marker --> Response cue begins
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
            system(fname);
            masterTimeReport.respcue(block, trial) = GetSecs;
            trigReport(block, trig_counter) =  5;
            trig_counter = trig_counter + 1;
        end
        saccLoc = tMap.saccLocpix(trial, :);
        %record to the edf file that response cue is started
        if parameters.eyetracker% && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /responseCue"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 5);
            Eyelink('Message', 'TarX %s ', num2str(saccLoc(1)));
            Eyelink('Message', 'TarY %s ', num2str(saccLoc(2)));
        end
        % Draw green fixation cross
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end
        drawTextures(parameters, screen, 'FixationCross', parameters.cuecolor);
        
        if GetSecs - respCueStartTime < parameters.respCueDuration
            WaitSecs(parameters.respCueDuration - (GetSecs - respCueStartTime));
        end
        timeReport.respCueDuration(trial) = GetSecs - respCueStartTime;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Response window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        respStartTime = GetSecs;
        % EEG marker --> response begins
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
            system(fname);
            masterTimeReport.resp(block, trial) = GetSecs;
            trigReport(block, trig_counter) =  6;
            trig_counter = trig_counter + 1;
        end
        %record to the edf file that response is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /response"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 6);
            Eyelink('command', 'record_status_message "TRIAL %i/%i /saccadeCoords"', trial, trialNum);
        end
        %draw the fixation dot
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end
        drawTextures(parameters, screen, 'FixationCross');
        
        if GetSecs - respStartTime < parameters.respDuration
            WaitSecs(parameters.respDuration - (GetSecs - respStartTime));
        end
        timeReport.respDuration(trial) = GetSecs - respStartTime;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Feedback window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        feedbackStartTime = GetSecs;
        % EEG marker --> feedback begins
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
            system(fname);
            masterTimeReport.feedback(block, trial) = GetSecs;
            trigReport(block, trig_counter) =  7;
            trig_counter = trig_counter + 1;
        end
        %record to the edf file that feedback is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /feedback"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 7);
        end
        % Get the size and location of dot
        dotSize = tMap.dotSizeSacc(trial);
        dotCenter = tMap.saccLocpix(trial, :);
        
        % draw the fixation dot
        % Render stimulus
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end
        drawTextures(parameters, screen, 'Stimulus', parameters.feebackcolor, dotSize, dotCenter);
        drawTextures(parameters, screen, 'FixationCross');

        if GetSecs - feedbackStartTime < parameters.feedbackDuration
            WaitSecs(parameters.feedbackDuration - (GetSecs - feedbackStartTime));
        end
        timeReport.feedbackDuration(trial) = GetSecs-feedbackStartTime;
        
        if parameters.eyetracker
            Eyelink('Message', 'TRIAL_RESULT  0')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Intertrial window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        itiStartTime = GetSecs;
        % EEG marker --> ITI begins
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
            system(fname);
            masterTimeReport.iti(block, trial) = GetSecs;
            trigReport(block, trig_counter) =  8;
            trig_counter = trig_counter + 1;
        end
        %record to the edf file that iti is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /iti"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 8);
            Eyelink('Message', 'TarX %s ', num2str(screen.xCenter));
            Eyelink('Message', 'TarY %s ', num2str(screen.yCenter));
        end
        % Draw a fixation cross
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end
        drawTextures(parameters, screen, 'FixationCrossITI');
        
        if GetSecs - itiStartTime < ITI(trial)
            WaitSecs(ITI(trial) - (GetSecs - itiStartTime));
        end
%         KbQueueFlush(kbx);
%         KbQueueStart(kbx);
%         [keyIsDown, ~] = KbQueueCheck(kbx);
%         while ~keyIsDown
%             WaitSecs(ITI(trial));
%             [~, keyCode] = KbQueueCheck(kbx);
%             cmndKey = KbName(keyCode);
%             break;
%         end
%         % check for end of block PS: This chunk is not working! 
%         if strcmp(cmndKey, parameters.exit_key)
%             KbQueueStart(kbx);
%             [keyIsDown, ~] = KbQueueCheck(kbx);
%             while ~keyIsDown
%                 showprompts(screen, 'TrialPause');
%                 [keyIsDown, ~] = KbQueueCheck(kbx);
%             end
%         end
        timeReport.itiDuration(trial) = GetSecs - itiStartTime;
        timeReport.trialDuration(trial) = GetSecs-sampleStartTime;
    end
        
    %% Saving Data and Closing everything
    % stop eyelink and save eyelink data
    if parameters.eyetracker
        Eyelink('StopRecording');
        Eyelink('ReceiveFile', parameters.edfFile);
        copyfile([parameters.edfFile '.edf'], [parameters.block_dir filesep parameters.edfFile '.edf']);
        Eyelink('Shutdown');
        disp(['Eyedata recieve for ' num2str(block,"%02d") ' OK!']);
    end
    
    if parameters.EEG
        fname = ['sudo python3 ' trigger_path '/trigger_send.py'];
        system(fname);
        masterTimeReport.blockend(block) = GetSecs;
        trigReport(block, trig_counter) =  9;
        %trig_counter = trig_counter + 1;
    end
    
    % save timeReport
    matFile.parameters = parameters;
    matFile.screen = screen;
    matFile.timeReport = timeReport;
    save([parameters.block_dir filesep parameters.matFile],'matFile')
    
    % check for end of block (removed on 03/06: for debugging timing)
%     KbQueueFlush(kbx);
%     [keyIsDown, ~] = KbQueueCheck(kbx);
%     while ~keyIsDown
%         showprompts(screen, 'BlockEnd', block)
%         [keyIsDown, keyCode] = KbQueueCheck(kbx);
%         cmndKey = KbName(keyCode);
%     end
%     
%     if strcmp(cmndKey, parameters.space_key)
%         continue;
%     elseif strcmp(cmndKey, parameters.exit_key)
%         sca;
%         ListenChar(1);
%         return;
%     end
end % end of block
reportFile.masterTimeReport = masterTimeReport;
reportFile.trigReport = trigReport;
save([datapath '/reportFile.mat'],'reportFile')
% end Teensy handshake
if parameters.TMS
    TMS('Disable', s);
    TMS('Close', s);
end
showprompts(screen, 'EndExperiment');
ListenChar(1);
WaitSecs(2);
Priority(0);
sca;
end