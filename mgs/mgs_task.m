%% Initialization
%%% Edits by Mrugank (01/29/2022)
% Suppressed VBL Sync Error by PTB, added sca, clear; close all;
clear; close all; clc;% clear mex;
global parameters screen hostname kbx

subjID = '20';
session = '01';
block = 1;
coilLocInd = 1;

%%% Check the system name to ensure correct paths are added.
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

%%% Adding all necessary paths
curr_dir = pwd;
mgs_dir = curr_dir(1:end-4);
master_dir = mgs_dir(1:end-11);
markstim_path = [mgs_dir filesep 'markstim-master'];
phosphene_data_path = [master_dir filesep 'data/phosphene_data/sub' subjID];
mgs_data_path = [master_dir filesep 'data/mgs_data/sub' subjID '/block' num2str(block, "%02d")];
addpath(genpath(markstim_path));
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

%%% Load PTB and toolboxes
if strcmp(hostname, 'syndrome')
    % Location of PTB on Syndrome
    addpath(genpath('/Users/Shared/Psychtoolbox')) %% mrugank (01/28/2022): load PTB
elseif strcmp(hostname, 'tmsubuntu')
    addpath(genpath('/usr/share/psychtoolbox-3'))
else
    disp('Running on unknown device. Psychtoolbox might not be added correctly!')
end

sca;
Screen('Preference','SkipSyncTests', 1) %% mrugank (01/29/2022): To suppress VBL Sync Error by PTB

loadParameters(subjID, block, coilLocInd);
initScreen();
initFiles(mgs_data_path);
initPeripherals();

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
showprompts('LoadExperimentWindow')

if parameters.eyetracker == 0
    el = 1;
    eye_used = 1;
else
    % Initialize Eye Tracker and perform calibration
    if ~parameters.eyeTrackerOn
        initEyeTracker;
        % Perform calibration task before starting trials
        [avgGazeCenter, avgPupilSize] = etFixCalibTask(el, eye_used);
        FlushEvents;
    else
        Eyelink('Openfile', parameters.edfFile);
    end
end

% Init start of experiment procedures
if parameters.eyetracker
    Eyelink('StartRecording');
end
ListenChar(-1);
drawTextures('FixationCross');

timeReport = struct;
timeReport = repmat(timeReport, [1, trialNum]);

startExperimentTime = GetSecs;
trialArray = 1:trialNum;
ITI = Shuffle(repmat(parameters.itiDuration, [1 trialNum/2]));
%% run over trials
for trial = trialArray
    % EEG marker --> trial begins
    if parameters.TMS
        MarkStim('t', 10);
    end
    %     % if backTick is pressed by the experimenter to pause the experiment
    %     KbQueueStart(kbx);
    %     [keyIsDown, keyCode] = KbQueueCheck(kbx);
    %     cmndKey = KbName(keyCode);
    %
    %     % terminate the experiment if escape is pressed by the experimenter
    %     if strcmp(cmndKey,'ESCAPE')
    %         break
    %     end
    %
    %     if strcmp(cmndKey,'`~')
    %         cmndKey = nan;
    %         disp('Paused! Press backTick to resume this run')
    %         KbQueueStart(kbx);
    %         % wait for the experimenter to press backTick to resume experiment
    %         while ~strcmp(cmndKey,'`~')
    %             [keyIsDown, keyCode]=KbQueueCheck(kbx);
    %             cmndKey = KbName(keyCode);
    %         end
    %     end
    
    disp(['runing trial  ' num2str(trial, '%02d') ' ....'])
    
    if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
        Eyelink('command', 'record_status_message "TRIAL %i/%i "', ...
            trial, trialNum);
        Eyelink('Message', 'TRIAL %i ', trial);
        
        %re-initialize breakOfFixation variable -- assume there is no break of
        %fixation at the beginning of the trial
        breakOfFixation = 0;
        minPupil = 0.4 * avgPupilSize;
        
        %initialize required variables
        thisFixBreakCountCummulative = 0; %variable for storing the total number of eye blinks
        gazeCheckCounter = 0;
        %fixBreak = 0;
        thisFixBreakCount = 0;
        fixationBreakInstance = 0;
        gazeDisFromCenter = 0;
        blinkTimeLowerBound = 0;
        blinkTimeUpperBound = 0;
        %--------------------------------------------------------------------------
    end
    trial_start = GetSecs;
    % synchronize time in edf file
    if parameters.eyetracker
        Eyelink('Message', 'SYNCTIME');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Run a trial
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while GetSecs-trial_start<=parameters.sampleDuration+parameters.delayDuration
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Track subject's break of fixation
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fixBreak  = 0;
        if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
            evt = Eyelink('NewestFloatSample');
            if eye_used ~= -1 % do we know which eye to use yet?
                gazeCheckCounter = gazeCheckCounter + 1; %use the counter to tag the fixation checks
                % Get eye position and pupil size
                gazePosX = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                gazePosY = evt.gy(eye_used+1);
                pupilSize = evt.pa(eye_used+1);
                %once pupil size is available, check against the threshold
                %for blink, and if it crosses threshold, create a range
                %around the current instance of fixation break. use this
                %range to mark all breaks of fixations in this time period as
                %part of the blink
                if pupilSize < minPupil
                    blinkTimeUpperBound = gazeCheckCounter + 5;
                    blinkTimeLowerBound = gazeCheckCounter - 5;
                end
                % do we have valid data and is the pupil visible?
                if gazePosX~=el.MISSING_DATA && gazePosY~=el.MISSING_DATA && pupilSize>0
                    gazeDisFromCenter = sqrt(([gazePosX, gazePosY] - avgGazeCenter).^2);
                    %check whether gaze position hasnt gone out of a circle of set radius.
                    if gazeDisFromCenter > parameters.fixationBoundary %in pixels
                        fixBreak = fixBreak + 1;
                        fixationBreakInstance = gazeCheckCounter;
                        %have a counter here that gives information on how many +1s have already happened
                        thisFixBreakCount = thisFixBreakCount + 1;
                    end
                end
                %this resets fixBreak back to zero in case of a blink
                if fixationBreakInstance > blinkTimeLowerBound && fixationBreakInstance < blinkTimeUpperBound
                    fixBreak = fixBreak - thisFixBreakCount;
                    thisFixBreakCount = 0;
                    fixationBreakInstance = 0;
                end
                %reset thisFixBreakCount when the eye fixates again eg. after a blink
                if gazeDisFromCenter < parameters.fixationBoundary
                    thisFixBreakCount = 0;
                end
            end
            %if gaze position goes out of a circle around centre of a set
            %radius in pixels, count it as a break in fixation
            if fixBreak > 0
                breakOfFixation = 1;
            else
                breakOfFixation = 0;
            end
            %count how many eye blinks occured
            thisFixBreakCountCummulative = thisFixBreakCountCummulative + thisFixBreakCount;
        end %end of if checking eyetracker
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % sample window
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        sampleStartTime = GetSecs;
        % EEG marker --> Sample begins
        if parameters.EEG
            MarkStim('t', 20);
        end
        %record to the edf file that sample is started
        if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /sample"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 1);
        end
        % draw sample and fixation cross
        while GetSecs-sampleStartTime <= parameters.sampleDuration
            Screen('FillOval',screen.win, screen.white, ...
                [taskMap.stimLocpix(trial,:) - parameters.stimDiam, ...
                taskMap.stimLocpix(trial,:) + parameters.stimDiam]);
            drawTextures('FixationCross');

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
        if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /delay1"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 2);
        end
        % Draw fixation cross
        while GetSecs-delay1StartTime <= parameters.delay1Duration
            drawTextures('FixationCross');
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
        if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
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
        if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /delay2"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 4);
        end
        % Draw fixation cross
        while GetSecs-delay2StartTime<=parameters.delay2Duration
            drawTextures('FixationCross');
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
        %record to the edf file that response cue is started
        if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /responseCue"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 5);
        end
        % Draw green fixation cross
        while GetSecs-respCueStartTime < parameters.respCueDuration
            drawTextures('FixationCross', parameters.cuecolor);
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
        %saccLoc_VA_x = taskMap.saccLoc_va(trial,1) * cosd(taskMap.saccLoc_va(trial,2));
        %saccLoc_VA_y = taskMap.saccLoc_va(trial,1) * sind(taskMap.saccLoc_va(trial,2)); % the angle is +CCW with 0 at horizontal line twoards right.
        saccLoc = taskMap.saccLocpix(trial);
        %record to the edf file that response is started
        if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /response"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 6);
            Eyelink('command', 'record_status_message "TRIAL %i/%i /saccadeCoords"', trial, trialNum);
%             Eyelink('Message', 'TarX %s ', num2str(saccLoc_VA_x));
%             Eyelink('Message', 'TarY %s ', num2str(saccLoc_VA_y));
            Eyelink('Message', 'TarX %s ', num2str(saccLoc(1)));
            Eyelink('Message', 'TarX %s ', num2str(saccLoc(2)));
        end
        %draw the fixation dot
        while GetSecs-respStartTime<=parameters.respDuration
            drawTextures('FixationCross');
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
        if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %i/%i /feedback"', trial, trialNum);
            Eyelink('Message', 'XDAT %i ', 7);
        end
        % draw the fixation dot
        while GetSecs-feedbackStartTime<=parameters.feedbackDuration
            Screen('FillOval',screen.win, parameters.feebackcolor, ...
                [taskMap.saccLocpix(trial,:) - parameters.stimDiam, ...
                taskMap.saccLocpix(trial,:) + parameters.stimDiam]);
            drawTextures('FixationCross');
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
    if parameters.eyetracker && Eyelink('NewFloatSampleAvailable') > 0
        Eyelink('command', 'record_status_message "TRIAL %i/%i /iti"', trial, trialNum);
        Eyelink('Message', 'XDAT %i ', 8);
    end
    % Draw a fixation cross
    while GetSecs-itiStartTime < ITI(trial)
        drawTextures('FixationCross');
    end
    timeReport(trial).itiDuration = GetSecs - itiStartTime;
    timeReport(trial).trialDuration = GetSecs-sampleStartTime;
end

totalTime = GetSecs-startExperimentTime;

%% Saving Data and Closing everything
% stop eyelink
%--------------------------------------------------------------------------------------------------------------------------------------%
if parameters.eyetracker
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    % download data file
    try
        fprintf('Receiving data file ''%s''\n', parameters.edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %i\n', status);
        end
        if 2==exist(parameters.edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', parameters.edfFile, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', parameters.edfFile );
    end
end
ListenChar(0);

%%% save results
resultsDIR = [mgs_data_path filesep 'Results'];
saveName = [resultsDIR '/timeReport_subj' subjID '_block' num2str(block, "%02d")];
save(saveName,'timeReport')
% save Response and time reports
% showEndOfCurrentRun(currentRun);
% allRuns(currentRun) = allRuns(currentRun)+1;
showprompts('EndOfExperimentWindow');

if parameters.eyetracker
    Eyelink('Shutdown');
end

if parameters.TMS
    MarkStim('x');
end