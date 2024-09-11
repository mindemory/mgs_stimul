function mgsDistractor_task(subjID, day, start_block, TMSamp, prac_status, anti_type, aperture)
clearvars -except subjID day start_block TMSamp prac_status anti_type aperture;
close all; clc;
% Created by Mrugank Dake, Curtis Lab, NYU (09/09/2024)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize parameters
subjID = num2str(subjID, "%02d"); % convert subjID to string


parameters = loadParameters(subjID);
if nargin < 4
    TMSamp = 30; % default TMS amplitude of 30% MSO
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

eyetrackfeedback = 0;
% Check the system running on: currently accepted: syndrome, tmsubuntu
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

% Initialize PTB and EEG/TMS/Eyetracking parameters
if strcmp(hostname, 'syndrome') || strcmp(hostname, 'zod') || strcmp(hostname, 'zod.psych.nyu.edu') % Lab iMac is meant for debugging
    addpath(genpath('/Users/Shared/Psychtoolbox')) %% mrugank (01/28/2022): load PTB
    phosphene_data_path = ['/datc/MD_TMS_EEG/data/phosphene_data/sub' subjID];
    parameters.isDemoMode = true; % set to true if you want the screen to be transparent
    parameters.EEG = 0; % set to 0 if there is no EEG recording
    parameters.TMS = 0; % set to 0 if there is no TMS stimulation
    parameters.eyetracker = 0; % set to 0 if there is no eyetracker
    Screen('Preference','SkipSyncTests', 1)
    if prac_status == 1
        end_block = 2; % 2 blocks for practice session
        mgs_data_path = ['/datd/MD_TMS_EEG/data/mgs_practice_data/sub' subjID];
    else
        end_block = 10; % 10 blocks for main sessions
        mgs_data_path = ['/datd/MD_TMS_EEG/data/mgs_data/sub' subjID];
    end
elseif strcmp(hostname, 'tmsubuntu') % Running stimulus code for testing
    addpath(genpath('/usr/share/psychtoolbox-3'))
    parameters.isDemoMode = false; %set to true if you want the screen to be transparent
    parameters.TMS = 0; % set to 0 if there is no TMS stimulation
    % Relative paths for tmsubuntu
    curr_dir = pwd; filesepinds = strfind(curr_dir,filesep);
%     master_dir = curr_dir(1:(filesepinds(end-1)-1));
    master_dir = '/home/curtislab/Desktop/md_data/MD_TMS_EEG';
    phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
    % Path to MarkStim
    trigger_path = [master_dir '/mgs_stimul/EEG_TMS_triggers'];
    addpath(genpath(trigger_path));
    trigger_path_EEG = [trigger_path '/EEG'];
    if prac_status == 1
        parameters.EEG = 0; % set to 0 if there is no EEG recording
        end_block = 6; % 6 blocks for practice session
        mgs_data_path = [master_dir '/data/mgs_practice_data/sub' subjID];
    else
        parameters.EEG = 0;
        end_block = 10; % 10 blocks for main sessions
        mgs_data_path = [master_dir '/data/mgs_data/sub' subjID];
    end
    parameters.eyetracker = 1;
    PsychDefaultSetup(1);
elseif strcmp(hostname, 'bizarro') % Running stimulus code for testing
    addpath(genpath('/Applications/Psychtoolbox/'))
    parameters.isDemoMode = false; %set to true if you want the screen to be transparent
    parameters.TMS = 0; % set to 0 if there is no TMS stimulation
    % Absolute paths for bizzaro
    master_dir = '/Users/CurtisLab/Desktop/Mrugank';
    phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
    % Path to MarkStim
    trigger_path = [master_dir '/mgs_stimul/EEG_TMS_triggers'];
    addpath(genpath(trigger_path));
    trigger_path_EEG = [trigger_path '/EEG'];
    if prac_status == 1
        parameters.EEG = 0; % set to 0 if there is no EEG recording
        end_block = 6; % 6 blocks for practice session
        mgs_data_path = [master_dir '/data/mgs_practice_data/sub' subjID];
    else
        parameters.EEG = 0;
        end_block = 10; % 10 blocks for main sessions
        mgs_data_path = [master_dir '/data/mgs_data/sub' subjID];
    end
    parameters.eyetracker = 1;
%     PsychDefaultSetup(1);
    Screen('Preference','SkipSyncTests', 1)
else
    disp('Running on unknown device. Psychtoolbox might not be added correctly!')
    return;
end
parameters.hostname = hostname;
% Adding 15 blocks for day06
if day == 6
    end_block = 10;
    D1 = 2;
end

% Initialize data paths
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

% Load taskMap
if prac_status == 1
    load([phosphene_data_path '/taskMapPractice_sub' subjID '_antitype_' anti_type])
    parameters.TMS = 0;
else
    load([phosphene_data_path '/taskMap_sub' subjID, '_day' num2str(day, "%02d") '_antitype_' anti_type])
    if taskMap(1).TMScond == 1% determine if this is a TMS task
        parameters.TMS = 1;
    elseif taskMap(1).TMScond == 0
        parameters.TMS = 0;
    end
end

% Initialize screen and peripherals
screen = initScreen(parameters);
[kbx, parameters] = initPeripherals(parameters);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open TMS Port
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% detect the MagVenture and perform handshake.
if parameters.TMS > 0
    s = TMS('Open');
    TMS('Enable', s);
    TMS('Timing', s);
    TMS('Amplitude', s, TMSamp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for block = start_block:end_block
    if eyetrackfeedback == 1
        eyetrack_errors = struct;
    end
    timeReport = struct;
    trigReport = NaN(1, 400);
    EEGtimeReport = struct;
    trig_counter = 1;
    % EEG marker --> block begins
    if parameters.EEG
        fname = ['sudo python3 ' trigger_path_EEG '/eegflag0.py'];
        system(fname);
        EEGtimeReport.blockstart = GetSecs;
        trigReport(trig_counter) = 0;
        trig_counter = trig_counter + 1;
    end
    parameters.block = num2str(block, "%02d");
    
    % Create folders for the block and read taskMap for current block
    if prac_status == 1
        datapath = [mgs_data_path '/day01'];
        parameters = initFiles(parameters, screen, datapath, kbx, block);
        tMap = taskMapPractice(1, block);
    else
        datapath = [mgs_data_path '/day' num2str(day, "%02d")];
        parameters = initFiles(parameters, screen, datapath, kbx, block);
        tMap = taskMap(1, block);
    end
    [noiseTexIn, noiseTexOut] = makeNoisePhosphene(parameters, screen, tMap.TFin, tMap.TFout);
    
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
            el.eye_used = 1;
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
    
    trialArray = 1:trialNum;
    ITI = Shuffle(repmat(parameters.itiDuration, [1 trialNum/2]));
%     if day == 4 % control task
%         D1 = Shuffle(repmat(stim_times, [1 trialNum/2]));
%     end
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
        % initial fixation window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        initStartTime = GetSecs;
        % EEG marker --> Fixation
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path_EEG '/eegflag1.py'];
            system(fname);
            EEGtimeReport.init(trial) = GetSecs;
            trigReport(trig_counter) =  1;
            trig_counter = trig_counter + 1;
        end
        
        %record to the edf file that sample is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /fixation"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 1);
            Eyelink('Message', 'TarX %s ', num2str(screen.xCenter));
            Eyelink('Message', 'TarY %s ', num2str(screen.yCenter));
        end
        
        % draw fixation cross
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end
        drawTextures(parameters, screen, 'FixationCross');

        if GetSecs - initStartTime < parameters.initDuration
            WaitSecs(parameters.initDuration - (GetSecs-initStartTime));
        end
        timeReport.initDuration(trial) = GetSecs-initStartTime;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % sample window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        sampleStartTime = GetSecs;
        % EEG marker --> Sample begins
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
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path_EEG '/eegflag' num2str(trigger_code) '.py'];
            system(fname);
            EEGtimeReport.sample(trial) = GetSecs;
            trigReport(trig_counter) =  trigger_code;
            trig_counter = trig_counter + 1;
        end
        
        %record to the edf file that sample is started
        if parameters.eyetracker %&& Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /sample"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 10);
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
        if ~exist('D1', 'var') || D1 > 0 % Run this only if delay 1 exists (aka days 1-3) or if delay is greater than 0
            if parameters.EEG
                fname = ['sudo python3 ' trigger_path_EEG '/eegflag2.py'];
                system(fname);
                EEGtimeReport.delay1(trial) = GetSecs;
                trigReport(trig_counter) =  2;
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

            % Determine the delay 1 duration based on 'day'
            if ~exist('D1', 'var')
                d1_dur = D1;
            else
                d1_dur = parameters.delay1Duration;
            end
            
            if GetSecs - delay1StartTime < d1_dur
                WaitSecs(d1_dur - (GetSecs-delay1StartTime));
            end
        end
        timeReport.delay1Duration(trial) = GetSecs - delay1StartTime;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Delay2 window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        delay2StartTime = GetSecs;
        % EEG marker --> TMS pulse begins
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path_EEG '/eegflag3.py'];
            system(fname);
            EEGtimeReport.tms(trial) = GetSecs;
            trigReport(trig_counter) =  3;
            trig_counter = trig_counter + 1;
        end
        
        if parameters.TMS
            TMS('Train', s); % Train of TMS pulses, set pulse protocol on MagVenture Timing page
        end
        
        %record to the edf file that noise mask is started
        if parameters.eyetracker 
            Eyelink('command', 'record_status_message "TRIAL %i/%i /delay2"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 3);
        end
        
        % Draw fixation cross
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end

        % Find distractor hemi
%         WaitSecs(2);
%         dTemp = GetSecs();
        distractorHemi = tMap.distractorHemi(trial);
        if distractorHemi
            noiseTex = noiseTexOut;
        else
            noiseTex = noiseTexIn;
        end
        ntrls = size(noiseTex, 1);
        
%         WaitSecs(5);
%         dd = GetSecs();
        for i=1:3
            trlIdx = randi(ntrls);
            noiseTexNow = squeeze(noiseTex(trlIdx, :, :));
            nT = Screen('MakeTexture', screen.win, noiseTexNow);
            Screen('DrawTexture', screen.win, nT, []);
%             drawNoisePhosphene(parameters, screen, TF)
            drawTextures(parameters, screen, 'FixationCross');
            WaitSecs(0.02);
            drawTextures(parameters, screen, 'FixationCross');

        end
%         drawTextures(parameters, screen, 'FixationCross');
%         WaitSecs(0.5);
%         drawNoisePhosphene(parameters, screen, TF)
%         drawTextures(parameters, screen, 'FixationCross');
%         WaitSecs(0.5);
%         drawNoisePhosphene(parameters, screen, TF)
%         drawTextures(parameters, screen, 'FixationCross');
%         WaitSecs(0.5);
%         dd1 = GetSecs();
%         dd1 - dd
        
        % Show Noise flicker for 150 ms 
%         while GetSecs - delay2StartTime < 0.15
% %         while GetSecs - dTemp < 0.25
%             drawNoisePhosphene(parameters, screen, TF)
%             drawTextures(parameters, screen, 'FixationCross');
% %             WaitSecs(0.02);
% %             drawTextures(parameters, screen, 'FixationCross');
%         end
        drawTextures(parameters, screen, 'FixationCross');

        % Get the second delay duration, dependent on day
        if ~exist('D1', 'var') % Run this only if delay 1 exists (aka days 1-3) or if delay is greater than 0
            d2_dur = parameters.delay2Duration;
        elseif D1 > 0
            d2_dur = parameters.delayDuration - d1_dur;
        else
            d2_dur = parameters.delayDuration;
        end
        
        if GetSecs - delay2StartTime < d2_dur
            WaitSecs(d2_dur - (GetSecs - delay2StartTime));
        end
        timeReport.delay2Duration(trial) = GetSecs - delay2StartTime;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Response window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        respStartTime = GetSecs;
        % EEG marker --> Response cue begins
        if parameters.EEG
            fname = ['sudo python3 ' trigger_path_EEG '/eegflag4.py'];
            system(fname);
            EEGtimeReport.response(trial) = GetSecs;
            trigReport(trig_counter) =  4;
            trig_counter = trig_counter + 1;
        end
        saccLoc = tMap.saccLocpix(trial, :);
        %record to the edf file that response cue is started
        if parameters.eyetracker
            Eyelink('command', 'record_status_message "TRIAL %i/%i /response"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 4);
            Eyelink('Message', 'TarX %s ', num2str(saccLoc(1)));
            Eyelink('Message', 'TarY %s ', num2str(saccLoc(2)));
        end
        % Draw green fixation cross
        if aperture == 1
            drawTextures(parameters, screen, 'Aperture');
        end
        drawTextures(parameters, screen, 'FixationCross', parameters.cuecolor);
        
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
            fname = ['sudo python3 ' trigger_path_EEG '/eegflag6.py'];
            system(fname);
            EEGtimeReport.feedback(trial) = GetSecs;
            trigReport(trig_counter) =  5;
            trig_counter = trig_counter + 1;
        end
        %record to the edf file that feedback is started
        if parameters.eyetracker 
            Eyelink('command', 'record_status_message "TRIAL %i/%i /feedback"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 5);
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
            fname = ['sudo python3 ' trigger_path_EEG '/eegflag7.py'];
            system(fname);
            EEGtimeReport.iti(trial) = GetSecs;
            trigReport(trig_counter) =  6;
            trig_counter = trig_counter + 1;
        end
        %record to the edf file that iti is started
        if parameters.eyetracker 
            Eyelink('command', 'record_status_message "TRIAL %i/%i /iti"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 6);
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
        
        timeReport.itiDuration(trial) = GetSecs - itiStartTime;
        timeReport.trialDuration(trial) = GetSecs-sampleStartTime;
    end
    
    %% Saving Data and Closing everything
    % stop eyelink and save eyelink data
    showprompts(screen, 'BlockEnd', block)
    Beeper('med',0.5,0.1)
    
    if parameters.eyetracker
        Eyelink('StopRecording');
        Eyelink('ReceiveFile', parameters.edfFile);
        copyfile([parameters.edfFile '.edf'], [parameters.block_dir filesep parameters.edfFile '.edf']);
        Eyelink('Shutdown');
        disp(['Eyedata recieve for ' num2str(block,"%02d") ' OK!']);
    end
    
    if parameters.EEG
        fname = ['sudo python3 ' trigger_path_EEG '/eegflag8.py'];
        system(fname);
        EEGtimeReport.blockend = GetSecs;
        trigReport(trig_counter) =  7;
    end
    
    % save timeReport
    matFile.parameters = parameters;
    matFile.screen = screen;
    matFile.timeReport = timeReport;
    save([parameters.block_dir filesep parameters.matFile],'matFile')
    
    % Save EEG flags
    if parameters.EEG == 1
        trigReport = trigReport(~isnan(trigReport));
        EEGsummary.EEGtimeReport = EEGtimeReport;
        EEGsummary.trigReport = trigReport;
        save([parameters.block_dir filesep parameters.EEGreportFile],'EEGsummary')
    end

    % Save Eyetrack errors
    if eyetrackfeedback == 1
        save([parameters.block_dir filesep parameters.eyeErrorFile],'eyetrack_errors')
        fixbreaks = sum((eyetrack_errors.sample+eyetrack_errors.delay1+eyetrack_errors.delay2) > 0);
        resplate = sum(eyetrack_errors.response >= 0.8);
        disp(['Fixation breaks = ' num2str(fixbreaks) ' trials.']);
        disp(['Slow response = ' num2str(resplate) ' trials.']);
    end

    % check for end of block
    KbQueueFlush(kbx);
    [keyIsDown, ~] = KbQueueCheck(kbx);
    while ~keyIsDown
        showprompts(screen, 'ContinueorEsc', block)
        [keyIsDown, keyCode] = KbQueueCheck(kbx);
        cmndKey = KbName(keyCode);
    end
    
    if strcmp(cmndKey, parameters.space_key)
        continue;
    elseif strcmp(cmndKey, parameters.exit_key)
        % end Teensy handshake
        if parameters.TMS
            TMS('Disable', s);
            TMS('Close', s);
        end
        showprompts(screen, 'EndExperiment');
        WaitSecs(2);
        ListenChar(1);
        sca;
        return;
    end
end % end of block

% Close TMS Port and End Experiment
if parameters.TMS
    TMS('Disable', s);
    TMS('Close', s);
end
showprompts(screen, 'EndExperiment');
ListenChar(1);
WaitSecs(2);
sca;
Priority(0);
end