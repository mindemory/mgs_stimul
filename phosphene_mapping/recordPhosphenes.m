%% Record Phoshpenes (mrugank: 03/07/2022)
% The code has been originally written by Masih. It has been adapted to
% make changes to suitably adjust to the new display, interact with the TMS
% device using MarkStim trigger and few other changes.

% The code creates a dark stimulus display with a red fixation cross. When
% the TMS parameter is set to 1 in loadParameters(), the code interacts with
% the Teensy trigger to first initiate a handshake. Make sure that the
% orange light is turned on on the TeensyTrigger before running the code.
% If the light is not on, reset the TeensyTrigger by pressing the orange
% button.

% It then asks for a new coil location, followed by whether the coil
% location is new or the trial is new. For a new trial, it will make the
% screen black and interact with the TMS device to send a pulse that is set
% on the TMS machine. It then waits for the subject to report if phosphene
% was seen. A left mouse-click implies a phosphene was seen while a right
% mouse-click implies a phosphene was not seen. If a phosphene was seen, it
% then activates a draw tool for the subject to draw the rough borders to
% report the phosphene seen. The drawing is ended upon second left click.

% The code runs till quit (q) is pressed by the experimenter. 

% TODO (by Masih):
% add eye tracking
%function [saveData] = recordPhosphene(subjID,session)

%% Initialization
%%% Edits by Mrugank (01/29/2022)
% Suppressed VBL Sync Error by PTB

clear; close all; clc;% clear mex;
global parameters screen hostname kbx mbx

subjID = '100';
session = '01';

% Check the system name to ensure correct paths are added.
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

% Load PTB and toolboxes
if strcmp(hostname, 'syndrome')
    % Syndrome Mac
    addpath(genpath('/Users/Shared/Psychtoolbox'))
    addpath(genpath('/d/DATA/hyper/experiments/Mrugank/TMS/mgs_stimul/phosphene_mapping'))
    addpath(genpath('/d/DATA/hyper/experiments/Mrugank/TMS/mgs_stimul/markstim-master'))
elseif strcmp(hostname, 'tmsubuntu')
    % Ubuntu Stimulus Display
    addpath(genpath('/usr/share/psychtoolbox-3'))
    %addpath(genpath('/home/curtislab/Documents/Psychtoolbox'))
    addpath(genpath('/home/curtislab/Desktop/mgs_stimul/phosphene_mapping'))
    addpath(genpath('/home/curtislab/Desktop/mgs_stimul/markstim-master'))
elseif strcmp(hostname, 'mindemory.local')
    addpath(genpath('/Users/mrugankdake/remote/hyper/experiments/Mrugank/TMS/mgs_stimul/phosphene_mapping'))
    addpath(genpath('/Users/mrugankdake/remote/hyper/experiments/Mrugank/TMS/mgs_stimul/markstim-master'))
else
    disp('Running on unknown device. Psychtoolbox might not be added correctly!')
end

sca;
Screen('Preference','SkipSyncTests', 1) %% mrugank (01/29/2022): To suppress VBL Sync Error by PTB

% initialize parameters, screen parameters and detect peripherals
loadParameters(subjID, session);
initScreen()
initPeripherals()

%% TEENSY CHECK!
% detect the TeensyTrigger and perform handshake make sure that the orange 
% light is turned on! If not, press the black button on Teensy Trigger.
if parameters.TMS
    % Checks for possible identifiers of TeensyTrigger
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

%% Create blank screen
% draw fixation cross on a black screen
FixCross = [screen.xCenter-1, screen.yCenter-4, screen.xCenter+1, screen.yCenter+4;...
    screen.xCenter-4, screen.yCenter-1, screen.xCenter+4, screen.yCenter+1];
Screen('FillRect', screen.win, parameters.fixation_color, FixCross');
Screen('Flip', screen.win);

% store screen and subject parameters in tmsRtnTpy
tmsRtnTpy.Params.ID = ['sub' subjID '_sess' session];
tmsRtnTpy.Params.screen = screen;
tmsRtnTpy.Params.taskParams = parameters;

% initialize trial and coil indices, incrementally increased on each run
trialInd = 0;
coilLocInd = 0;
ListenChar(-1) % prevent inputs from keyboard and mouse on main screen

%% Instructions for the subject
while 1
    KbQueueStart(kbx);
    [keyIsDown, keyCode]=KbQueueCheck(kbx);
    while ~keyIsDown
        Screen('TextSize', screen.win, parameters.font_size);
        DrawFormattedText(screen.win, parameters.instructions, 'center', ...
            'center', parameters.text_color);
        Screen('Flip', screen.win);
        
        [keyIsDown, keyCode]=KbQueueCheck(kbx);
        cmndKey = KbName(keyCode);
    end
    break;
end

%% Run the task
while 1
    % check for any keypresses
    KbQueueStart(kbx);
    [keyIsDown, keyCode] = KbQueueCheck(kbx);
    
    % Check for new or old coil location
    while ~keyIsDown
        Screen('TextSize', screen.win, parameters.font_size);
        DrawFormattedText(screen.win, parameters.first_msg, 'center', ...
            'center', parameters.text_color);
        Screen('Flip', screen.win);
        
        [keyIsDown, keyCode] = KbQueueCheck(kbx);
        cmndKey = KbName(keyCode);
        
    end
    
    % New coil location
    if strcmp(cmndKey, parameters.newloc_key)
        display(sprintf('\n---------------------------------------------'));
        display(sprintf('\n\tnew coil location initiated.'));
        
        coilLocInd = coilLocInd+1;
        startFlag = 1;

        while 1
            KbQueueStart(kbx);
            [keyIsDown, keyCode] = KbQueueCheck(kbx);
            while ~keyIsDown
                Screen('TextSize', screen.win, parameters.font_size);
                DrawFormattedText(screen.win, parameters.second_msg, ...
                    'center', 'center', parameters.text_color);
                Screen('Flip', screen.win);

                [keyIsDown, keyCode] = KbQueueCheck(kbx);
                cmndKey = KbName(keyCode);
            end
            
            if strcmp(cmndKey, parameters.trial_key)
                startFlag = 0;
                
                Screen('FillRect', screen.win, screen.black);
                Screen('FillRect', screen.win, parameters.fixation_color, FixCross');
                Screen('Flip', screen.win);
                trialInd = trialInd+1;
                strtTime.trial(trialInd) = GetSecs;
                
                display(sprintf('\n\tready for puls'));
                strtTime.puls(trialInd) = GetSecs;
                % send a signal to the a USB to trigger the TMS pulse
                pause(parameters.waitBeforePulse);
                
                if parameters.TMS
                    MarkStim('t', 128);
                end
                
                WaitSecs(parameters.Pulse.Duration);
                display(sprintf('\n\ttrigger pulse sent to the TMS machine'));
                
                % wait for subject's response:
                % right click: not seen a phosphene, go to next trial
                % first left click: start drawing
                % second left click: end drawing
                while 1
                    strtTime.preResp(trialInd) = GetSecs;
                    % show the mouse location and wait for subject's click
                    KbQueueStart(mbx);
                    [mouseKlick, clickCode] = KbQueueCheck(mbx);
                    
                    [x, y, buttons] = GetMouse(screen.win);
                    
                    SetMouse(screen.xCenter, screen.yCenter, screen.win);
                    HideCursor(screen.win);
                    
                    while ~any(clickCode)
                        [mouseKlick, clickCode] = KbQueueCheck(mbx);
                        [x,y,buttons]=GetMouse(screen.win);
                        
                        Screen('FillRect', screen.win, parameters.fixation_color, FixCross');
                        Screen('FillOval', screen.win, parameters.fixation_color, [x-2 y-2 x+2 y+2]);
                        Screen('Flip', screen.win);
                    end
                    
                    KbQueueStop(mbx);
                    duration.preResp(trialInd) = GetSecs - strtTime.preResp(trialInd);
                    Response.CoilLocation(trialInd) = coilLocInd;
                    
                    % abort trial after subject's right click
                    if clickCode(parameters.right_key)
                        TimeStmp.DetectionResp(trialInd) = GetSecs;
                        Response.Detection(trialInd) = 0;
                        duration.drawing(trialInd) = nan;
                        Response.Drawing.coords{trialInd} = nan;
                        
                        Screen('TextSize', screen.win, parameters.font_size);
                        DrawFormattedText(screen.win, parameters.no_phosph_msg, ...
                            'center', 'center', parameters.text_color);
                        Screen('Flip', screen.win);
                        WaitSecs(2);
                        break
                        
                    % start drawing after a left click
                    elseif clickCode(parameters.left_key)
                        TimeStmp.DetectionResp(trialInd) = GetSecs;
                        strtTime.drawing(trialInd) = GetSecs;
                        Response.Detection(trialInd) = 1;
                        
                        Screen('FillRect', screen.win, parameters.fixation_color, FixCross');
                        
                        KbQueueStart(mbx);
                        [mouseKlick, clickCode] = KbQueueCheck(mbx);
                        
                        [x, y, buttons] = GetMouse(screen.win);
                        XY = [x y];
                        while ~clickCode(parameters.left_key) % end drawing if left click pressed
                            [mouseKlick, clickCode] = KbQueueCheck(mbx);
                            [x, y, buttons] = GetMouse(screen.win);
                            XY = [XY; x y];
                            % Generate phosphene drawing
                            if XY(end,1) ~= XY(end-1,1) || XY(end,2) ~= XY(end-1,2)
                                Screen('DrawLine', screen.win, parameters.fixation_color, ...
                                    XY(end-1,1), XY(end-1,2), XY(end,1), XY(end,2),1);
                            end
                            Screen('Flip', screen.win,[],1);
                        end
                        duration.drawing(trialInd) = GetSecs - strtTime.drawing(trialInd);
                        Response.Drawing.coords{trialInd} = XY;
                        KbQueueStop(mbx);
                        break
                        % end of recording the drawing process
                    end
                end
                duration.trial(trialInd) = GetSecs - strtTime.trial(trialInd);
                Screen('Flip', screen.win); % clear Flip buffer
                Screen('FillRect', screen.win, parameters.fixation_color, FixCross');
                Screen('Flip', screen.win);
                
                tmsRtnTpy.TimeStmp = TimeStmp;
                tmsRtnTpy.Duration = duration;
                tmsRtnTpy.Response = Response;
                tmsRtnTpy.StrtTime = strtTime;
            
            % New coil location
            elseif strcmp(cmndKey, parameters.newloc_key) % get ready fo the next coil location if "n" is pressed
                TimeStmp.ThisCoilLocationTermination = GetSecs;
                
                Screen('TextSize', screen.win, parameters.font_size);
                DrawFormattedText(screen.win, parameters.new_coil_msg, ...
                    'center', 'center', screen.black);
                Screen('Flip', screen.win);
    
                if ~startFlag
                    Screen('FillRect', screen.win, screen.black);
                    Screen('FillRect', screen.win, parameters.fixation_color, FixCross');
                    Screen('Flip', screen.win);
                end
                break
            
            % Terminate the program
            elseif strcmp(cmndKey, parameters.quit_key) % quit the task if "q" is pressed
                break
            end
            
            Screen('FillRect', screen.win,screen.black);
            Screen('FillRect', screen.win, parameters.fixation_color, FixCross');
            Screen('Flip', screen.win);
        end
        
        % Terminate the program
        if strcmp(cmndKey, parameters.quit_key) % quit the task if "q" is pressed
            TimeStmp.ProgramTermination = GetSecs;
            q_msg = 'program terminated by the experimenter!';
            Screen('TextSize', screen.win, parameters.font_size);
            DrawFormattedText(screen.win, parameters.quit_msg, 'center', 'center', parameters.text_color);
            Screen('Flip', screen.win);
            WaitSecs(2);
            break
        end
    
    % Terminate the program
    elseif strcmp(cmndKey, parameters.quit_key)
        TimeStmp.ProgramTermination = GetSecs;
        q_msg = 'program terminated by the experimenter!';
        Screen('TextSize', screen.win, parameters.font_size);
        DrawFormattedText(screen.win, parameters.quit_msg, 'center', 'center', parameters.text_color);
        Screen('Flip', screen.win);
        WaitSecs(2);
        break
    end
end
KbQueueRelease;
ListenChar(0);
sca
ShowCursor;

%% Saving stuff
%%%% Create a directory to save all files with their times
saveDIR_auto = ['Results_Auto/sub' subjID '/sess' session '/' datestr(now)];
if ~exist('saveDIR_auto','dir')
    mkdir(saveDIR_auto);
end

saveName = [saveDIR_auto '/tmsRtnTpy_sub' subjID '_sess' session];
save(saveName,'tmsRtnTpy')

%%% save results
saveData = input(sprintf('\nsave results[y/n]?:  '),'s');
if strcmp(saveData,'y')
    saveDIR = ['Results/sub' subjID];
    if ~exist('saveDIR','dir')
        mkdir(saveDIR);
        mkdir([saveDIR '/Figures']);
    end
    saveName = [saveDIR '/tmsRtnTpy_sub' subjID '_sess' session];
    save(saveName,'tmsRtnTpy')
end

%% Close MarkStim
% This should end the handshake with MarkStim. Orange light should be back
% on.
if parameters.TMS
    MarkStim('x');
end
sca;