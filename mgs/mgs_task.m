%% Initialization
%%% Edits by Mrugank (01/29/2022)
% Suppressed VBL Sync Error by PTB, added sca, clear; close all;
clear; close all; clc;% clear mex;
global parameters screen hostname kbx

subjID = '02';
session = '02';
task = 'pro';
coilLocInd = 1;

%%% Check the system name to ensure correct paths are added.
[ret, hostname] = system('hostname');   
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

%%% Load PTB and toolboxes
if strcmp(hostname, 'syndrome')
    % Location of PTB on Syndrome
    addpath(genpath('/Users/Shared/Psychtoolbox')) %% mrugank (01/28/2022): load PTB
    addpath(genpath('/d/DATA/hyper/experiments/Mrugank/TMS/mgs_stimul/mgs'))
    pth_to_data = ['/d/DATA/hyper/experiments/Mrugank/TMS/data/phosphene_data/sub', subjID];
elseif strcmp(hostname, 'tmsubuntu')
    addpath(genpath('/usr/lib/psychtoolbox-3'))
    addpath(genpath('/home/curtislab/Desktop/mgs_stimul/mgs'))
    addpath(genpath('/home/curtislab/Desktop/mgs_stimul/markstim-master'))
else
    disp('Running on unknown device. Psychtoolbox might not be added correctly!')
end

% function recordPhosphene()
sca; 
Screen('Preference','SkipSyncTests', 1) %% mrugank (01/29/2022): To suppress VBL Sync Error by PTB
% coilHemField --> 1: Right visual filed , 2: Left visual field
% conditions: 1: Pulse/In , 2: Pulse/Out , 3: sham/In , 4: sham/Out

loadParameters(subjID, session, task, coilLocInd);
initScreen();
%initSubjectInfo_trial();
initFiles();
initPeripherals();

parameters.task = task;

%%   MarkStim CHECK!
% detect the MarkStim and perform handshake make sure that the orange 
% light is turned on! If not, press the black button on Teensy.
if parameters.TMS
    % Checks for possible identifiers of Teensy
    dev_num = 0;
    devs = dir('/dev/');
    while 1
        dev_name = ['ttyACM', num2str(dev_num)]
        if any(strcmp({devs.name}, dev_name))
            break
        else
            dev_num = dev_num + 1;
        end
    end
    trigger_id = ['/dev/', dev_name];
    MarkStim('i', trigger_id)
end


%   Load phosphene retinitopy data
%--------------------------------------------------------------------------------------------------------------------------------------%

%load([pth_to_data '/PhospheneReport_sub' subjID '_sess' session])
%load([pth_to_data '/tmsRtnTpy_sub' subjID '_sess' session])
load([pth_to_data '/Stim_sub' subjID '_sess' session])

%   Initialize taskMap
%--------------------------------------------------------------------------------------------------------------------------------------%
taskMap = generateTaskMap(Stim,coilLocInd);

FixCross = [screen.xCenter-1,screen.yCenter-4,screen.xCenter+1,screen.yCenter+4;...
    screen.xCenter-4,screen.yCenter-1,screen.xCenter+4,screen.yCenter+1];

%  show load of experiment 
%showprompts('LoadExperimentWindow')

timeIdx = 1;

%  init start of experiment procedures
showprompts('SoeWindow')

allRuns = ones(1,taskMap.trialNum);
%runVersion = parameters.runVersion;
%currentRun = parameters.runNumber;
%[runVersion,currentRun] = enterRunToStart(allRuns,currentRun,runVersion);

%reInitSubjectInfo(currentRun, runVersion);

%parameters.runVersion = runVersion;

%create inputs for dummy runs
%parameters.edfFile = [parameters.subject parameters.session num2str(currentRun) '_' parameters.task];
if parameters.dummymode == 1
    el = 1;
    eye_used = 1;
else
    % initialize Eye Tracker and perform calibration  
    if ~parameters.eyeTrackerOn
        initEyeTracker_costomCalTargets;
        %perform calibration task before starting trials
        %--------------------------------------------------------------------------------------------------------------------------------------%
        [avgGazeCenter, avgPupilSize] = etFixCalibTask(el, eye_used, FixCross');
        FlushEvents;
    else
        Eyelink('Openfile', parameters.edfFile);
    end
end

if parameters.dummymode == 0
    Eyelink('StartRecording');
end
startExperimentTime = GetSecs();
%  init start of experiment procedures
%--------------------------------------------------------------------------------------------------------------------------------------%
%showStartOfRunWindow();
showprompts('StartOfRunWindow')

WaitSecs(parameters.dummyDuration); % dummy time
ListenChar(-1);
Screen('FillRect', screen.win, screen.white, FixCross');
Screen('Flip', screen.win);
%  iterate over all trials
%--------------------------------------------------------------------------------------------------------------------------------------%
%
topPriorityLevel = MaxPriority(screen.win);

trialDurationArray = [];
texDurationArray = zeros(1, taskMap.trialNum);
sampleDurationArray = [];
delay1DurationArray = [];
pulseDurationArray = [];
delay2DurationArray = [];
respCueDurationArray = [];
respDurationArray = [];
feedbackDurationArray = [];
itiDurationArray = [];

startExperimentTime = GetSecs();
trialArray = 1:taskMap.trialNum;

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
    texStartTime = GetSecs;
    
    Loc_Stim = taskMap.stimLoc_pix(trial,:);
    Loc_Sacc = taskMap.saccLoc_pix(trial,:);
    
    texDuration = GetSecs - texStartTime;
    texDurationArray(trial) = texDuration;
    
    if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
        Eyelink('command', 'record_status_message "TRIAL %d/%d "', ...
            trialArray(trial), taskMap.trialNum);
        Eyelink('Message', 'TRIAL %d ', trialArray(trial));
        
        %--------------------------------------------------------------------------
        %re-initialize breakOfFixation variable -- assume there is no break of
        %fixation at the beginning of the trial
        breakOfFixation = 0;
        %
        minPupil = 0.4 * avgPupilSize;
        %define a fixation boundary in case its not part of the input arguments
        fixationBoundary = 66;%pixels
        
        %initialize required variables
        thisFixBreakCountCummulative = 0; %variable for storing the total number of eye blinks
        gazeCheckCounter = 0;
        fixBreak = 0;
        thisFixBreakCount = 0;
        fixationBreakInstance = 0;
        gazeDisFromCenter = 0;
        blinkTimeLowerBound = 0;
        blinkTimeUpperBound = 0;    
        %--------------------------------------------------------------------------
    end
    
    % sample window
    %----------------------------------------------------------------------
    Priority(topPriorityLevel);
    trial_start = GetSecs();
    % synchronize time in edf file
    if parameters.dummymode == 0
        Eyelink('Message', 'SYNCTIME');
    end
    
    while GetSecs-trial_start<=parameters.sampleDuration + taskMap.delay1(trial) + ...
          taskMap.pulseDuration(trial) + taskMap.delay2(trial)
        
        % sample window
        %----------------------------------------------------------------------
        sampleStartTime = GetSecs;
        %Track subject's break of fixation
        fixBreak  = 0;
        if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
            evt = Eyelink( 'NewestFloatSample');
            if eye_used ~= -1 % do we know which eye to use yet?
                gazeCheckCounter = gazeCheckCounter + 1; %use the counter to tag the fixation checks
                %get eye position
                gazePosX = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                gazePosY = evt.gy(eye_used+1);
                %get pupil size
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
                if gazePosX~=el.MISSING_DATA && gazePosY~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                    gazePosRelativeX = gazePosX-avgGazeCenter(1,1);
                    gazePosRelativeY = gazePosY-avgGazeCenter(1,2);
                    gazeDisFromCenter = (gazePosRelativeX^2 + gazePosRelativeY^2)^0.5;
                    
                    %check whether gaze position hasnt gone out of
                    %a circle of set radius.
                    if gazeDisFromCenter > fixationBoundary %in pixels
                        fixBreak = fixBreak + 1;
                        %disp(gazeDisFromCenter)
                        fixationBreakInstance = gazeCheckCounter;
                        %have a counter here that gives information on how many +1s have already happened
                        thisFixBreakCount = thisFixBreakCount + 1;
                    end
                end
                if fixationBreakInstance > blinkTimeLowerBound && fixationBreakInstance < blinkTimeUpperBound
                    fixBreak = fixBreak - thisFixBreakCount; %this resets fixBreak back to zero in case of a blink
                    thisFixBreakCount = 0;
                    fixationBreakInstance = 0;
                end
                
                if gazeDisFromCenter < fixationBoundary   %reset thisFixBreakCount when the eye fixates again eg. after a blink
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
            
        end %end of if checking dummymode
        
        % EEG marker --> Sample begins
        if parameters.TMS
            MarkStim('t', 20);
        end
        %record to the edf file that sample is started
        if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %d/%d /sample"', trialArray(trial), taskMap.trialNum);
            Eyelink('Message', 'xDAT %d ', 1);
        end
        
        flag = 0;
        while GetSecs-sampleStartTime<=parameters.sampleDuration
            if ~flag
                %draw sample
                Screen('FillOval',screen.win, screen.white, ...
                    [Loc_Stim(1)-parameters.stimDiam, Loc_Stim(2)-parameters.stimDiam, ...
                    Loc_Stim(1)+parameters.stimDiam, Loc_Stim(2)+parameters.stimDiam]);
                %draw the fixation dot
                Screen('FillRect', screen.win, screen.white, FixCross');
                Screen('Flip', screen.win);
                flag = 1;
            end
        end
        sampleDuration = GetSecs-sampleStartTime;
        sampleDurationArray = [sampleDurationArray, sampleDuration];
        
        % Delay1 window
        %----------------------------------------------------------------------
        % EEG marker --> Delay1 begins
        if parameters.TMS
            MarkStim('t', 30);
        end
        %record to the edf file that delay1 is started
        if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %d/%d /delay1"', trialArray(trial), taskMap.trialNum);
            Eyelink('Message', 'xDAT %d ', 2);
        end
        
        delay1StartTime = GetSecs;
        flag = 0;
        while GetSecs-delay1StartTime<=taskMap.delay1(trial)
            if ~flag
                Screen('FillRect', screen.win, screen.white, FixCross');
                Screen('Flip', screen.win);
                flag = 1;
            end
        end
        delay1Duration = GetSecs - delay1StartTime;
        delay1DurationArray = [delay1DurationArray,delay1Duration];
        % TMS pulse window
        %----------------------------------------------------------------------
        % EEG marker --> TMS pulse begins
        if parameters.TMS
            MarkStim('t', 168); % 128 for TMS + 40 for EEG marker
        end
        %record to the edf file that noise mask is started
        pulseStartTime = GetSecs();
        if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %d/%d /tmsPulse"', trialArray(trial), taskMap.trialNum);
            Eyelink('Message', 'xDAT %d ', 3);
        end
        
%         if parameters.EEG
%             % TMS trigger & EEG marker --> Delay1 begins
%             MarkStim('t', 30);
%         end
        WaitSecs(taskMap.pulseDuration(trial));
        
        pulseDuration = GetSecs - pulseStartTime;
        pulseDurationArray = [pulseDurationArray,pulseDuration];
        
        % Delay2 window
        %----------------------------------------------------------------------
        % EEG marker --> Delay2 begins
        if parameters.TMS
            MarkStim('t', 50);
        end
        %record to the edf file that delay2 is started
        if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %d/%d /delay2"', trialArray(trial), taskMap.trialNum);
            Eyelink('Message', 'xDAT %d ', 4);
        end
        
        delay2StartTime = GetSecs;
        flag = 0;
        while GetSecs-delay2StartTime<=taskMap.delay2(trial)
            if ~flag
                Screen('FillRect', screen.win, screen.white, FixCross');
                Screen('Flip', screen.win);
                flag = 1;
            end
        end
        delay2Duration = GetSecs - delay2StartTime;
        delay2DurationArray = [delay2DurationArray,delay2Duration];
        
        % response cue window
        %----------------------------------------------------------------------
        % EEG marker --> Response cue begins
        if parameters.TMS
            MarkStim('t', 60);
        end
        %record to the edf file that response cue is started
        if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %d/%d /responseCue"', trialArray(trial), taskMap.trialNum);
            Eyelink('Message', 'xDAT %d ', 5);
        end
        
        respCueStartTime = GetSecs;
        flag = 0;
        while GetSecs()-respCueStartTime < parameters.respCueDuration
            if ~flag % to do DarwTexture and Flip only once
                Screen('FillRect', screen.win, [0 256 0], FixCross');
                Screen('Flip', screen.win);
                flag = 1;
            end
        end
        respCueDuration = GetSecs - respCueStartTime;
        respCueDurationArray = [respCueDurationArray,respCueDuration];
        
        % response window
        %----------------------------------------------------------------------
        % EEG marker --> response begins
        if parameters.TMS
            MarkStim('t', 70)
        end
        %record to the edf file that response is started
        saccLoc_VA_x = taskMap.saccLoc_va(trial,1) * cosd(taskMap.saccLoc_va(trial,2));
        saccLoc_VA_y = taskMap.saccLoc_va(trial,1) * sind(taskMap.saccLoc_va(trial,2)); % the angle is +CCW with 0 at horizontal line twoards right.
        if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %d/%d /response"', trialArray(trial), taskMap.trialNum);
            Eyelink('Message', 'xDAT %d ', 6);
            
            Eyelink('command', 'record_status_message "TRIAL %d/%d /saccadeCoords"', trialArray(trial), taskMap.trialNum);
            Eyelink('Message', 'xTar %s ', num2str(saccLoc_VA_x));
            Eyelink('Message', 'yTar %s ', num2str(saccLoc_VA_y));
        end
        
        respStartTime = GetSecs;
        flag = 0;
        while GetSecs-respStartTime<=parameters.respDuration
            if ~flag
                %draw the fixation dot
                Screen('FillRect', screen.win, screen.white, FixCross');
                Screen('Flip', screen.win);
                flag = 1;
            end
        end
        respDuration = GetSecs - respStartTime;
        respDurationArray = [respDurationArray,respDuration];
        
        % feedback window
        %----------------------------------------------------------------------
        % EEG marker --> feedback begins
        if parameters.TMS
            MarkStim('t', 80);
        end
        %record to the edf file that feedback is started
        if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
            Eyelink('command', 'record_status_message "TRIAL %d/%d /feedback"', trialArray(trial), taskMap.trialNum);
            Eyelink('Message', 'xDAT %d ', 7);
        end
        
        feedbackStartTime = GetSecs;
        flag = 0;
        while GetSecs-feedbackStartTime<=parameters.feedbackDuration
            if ~flag
                Screen('FillOval',screen.win,[], ...
                    [Loc_Sacc(1)-parameters.stimDiam, Loc_Sacc(2)-parameters.stimDiam, ...
                    Loc_Sacc(1)+parameters.stimDiam, Loc_Sacc(2)+parameters.stimDiam]);
                %draw the fixation dot
                Screen('FillRect', screen.win, screen.white, FixCross');
                Screen('Flip', screen.win);
                flag = 1;
            end
        end %end of sample window
        feedbackDuration = GetSecs-feedbackStartTime;
        feedbackDurationArray = [feedbackDurationArray,feedbackDuration];
        
    end %end of while
    
    if parameters.dummymode == 0
        Eyelink('Message', 'TRIAL_RESULT  0')
    end
    
    % intertrial window
    %----------------------------------------------------------------------
    % EEG marker --> ITI begins
    if parameters.TMS
        MarkStim('t', 90);
    end
    %record to the edf file that iti is started
    if parameters.dummymode == 0 && Eyelink('NewFloatSampleAvailable') > 0
        Eyelink('command', 'record_status_message "TRIAL %d/%d /iti"', trialArray(trial), taskMap.trialNum);
        Eyelink('Message', 'xDAT %d ', 8);
    end
    
    itiStartTime = GetSecs;
    flag = 0;
    while GetSecs()-itiStartTime < taskMap.ITI(trial)
        if ~flag
            Screen('FillRect', screen.win, screen.white, FixCross');
            Screen('Flip', screen.win);
        end
    end
    itiDuration = GetSecs - itiStartTime;
    itiDurationArray = [itiDurationArray,itiDuration];
    
    trialDuration = GetSecs()-sampleStartTime;
    trialDurationArray = [trialDurationArray;trialDuration];
end %end iterating over current run trials

totalTime = GetSecs()-startExperimentTime;

%% saving and cleanning
% stop eyelink
%--------------------------------------------------------------------------------------------------------------------------------------%
if parameters.dummymode == 0
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    % download data file
    try
        fprintf('Receiving data file ''%s''\n', parameters.edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(parameters.edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', parameters.edfFile, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', parameters.edfFile );
    end
    % Shutdown Eyelink:
    %         Eyelink('Shutdown');
end

% save resoponse and time reports
%--------------------------------------------------------------------------------------------------------------------------------------%
for trialInd = 1:length(sampleDurationArray)
    timeReport(:,trialInd).texDuration =texDurationArray(trialInd);
    timeReport(:,trialInd).sampleDuration =sampleDurationArray(trialInd);
    timeReport(:,trialInd).delay1Duration =delay1DurationArray(trialInd);
    timeReport(:,trialInd).delay2Duration =delay2DurationArray(trialInd);
    timeReport(:,trialInd).pulseDuration =pulseDurationArray(trialInd);
    timeReport(:,trialInd).respCueDuration =respCueDurationArray(trialInd);
    timeReport(:,trialInd).respDuration =respDurationArray(trialInd);
    timeReport(:,trialInd).feedbackDuration =feedbackDurationArray(trialInd);
    timeReport(:,trialInd).itiDuration =itiDurationArray(trialInd);
    timeReport(:,trialInd).trialDuration =trialDurationArray(trialInd);
end
totalTimeData{timeIdx}=timeReport;

timeIdx = timeIdx+1;
ListenChar(0);
%   create keyboard events queue
showEndOfCurrentRun(currentRun);
allRuns(currentRun) = allRuns(currentRun)+1;

if parameters.dummymode == 0
    Eyelink('Shutdown');
end

if parameters.EEG
    MarkStim('x');
end