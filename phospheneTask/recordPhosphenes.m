function recordPhosphenes(subjID, session)
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

%% Initialization
%%% Edits by Mrugank (01/29/2022)
% Suppressed VBL Sync Error by PTB
clearvars -except subjID session; close all; clc;% clear mex;
subjID = num2str(subjID, '%02d');
session = num2str(session, '%02d');

% Check the system name to ensure correct paths are added.
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

curr_dir = pwd;
filesepinds = strfind(curr_dir,filesep);
master_dir = curr_dir(1:(filesepinds(end-1)-1));
markstim_path = [master_dir filesep 'markstim-master'];
data_path = [master_dir filesep 'data/phosphene_data'];
addpath(genpath(markstim_path));
addpath(genpath(data_path));

% Load PTB and toolboxes
if strcmp(hostname, 'syndrome')
    % Syndrome Mac
    addpath(genpath('/Users/Shared/Psychtoolbox'))
elseif strcmp(hostname, 'tmsubuntu')
    % Ubuntu Stimulus Display
    addpath(genpath('/usr/share/psychtoolbox-3'))
else
    disp('Running on unknown device. Psychtoolbox might not be added correctly!')
end

sca;
Screen('Preference','SkipSyncTests', 1) %% mrugank (01/29/2022): To suppress VBL Sync Error by PTB

% initialize parameters, screen parameters and detect peripherals
parameters = loadParameters(subjID, session);
screen = initScreen(parameters);
[kbx, mbx, parameters] = initPeripherals(parameters, hostname);

% store screen and subject parameters in tmsRtnTpy
tmsRtnTpy.Params.ID = ['sub' subjID '_sess' session];
tmsRtnTpy.Params.screen = screen;
tmsRtnTpy.Params.taskParams = parameters;

%% TEENSY CHECK!
% detect the TeensyTrigger and perform handshake make sure that the orange 
% light is turned on! If not, press the black button on Teensy Trigger.
if parameters.TMS
    % Checks for possible identifiers of TeensyTrigger
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

% initialize trial and coil indices, incrementally increased on each run
trialInd = 0;
coilLocInd = 0;
ListenChar(-1) % prevent inputs from keyboard and mouse on main screen

%% Instructions for the subject
while 1
    KbQueueStart(kbx);
    [keyIsDown, ~]=KbQueueCheck(kbx);
    while ~keyIsDown
        showprompts(parameters, screen, 'WelcomeWindow')
        [keyIsDown, ~]=KbQueueCheck(kbx);
    end
    break;
end

%% Run the task
while 1
    % check for any keypresses
    KbQueueStart(kbx);
    [keyIsDown, ~] = KbQueueCheck(kbx);
    % Check for new or old coil location
    while ~keyIsDown
        showprompts(parameters, screen, 'FirstMessage')
        [keyIsDown, keyCode] = KbQueueCheck(kbx);
        cmndKey = KbName(keyCode);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % New coil location
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(cmndKey, parameters.newloc_key)
        display(sprintf('\n---------------------------------------------'));
        display(sprintf('\n\tnew coil location initiated.'));
        coilLocInd = coilLocInd+1;
        while 1
            KbQueueStart(kbx);
            [keyIsDown, ~] = KbQueueCheck(kbx);
            while ~keyIsDown
                showprompts(parameters, screen, 'SecondMessage')
                [keyIsDown, keyCode] = KbQueueCheck(kbx);
                cmndKey = KbName(keyCode);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % New trial
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(cmndKey, parameters.trial_key)                
                drawTextures(parameters, screen, 'FixationCross');
                trialInd = trialInd+1;
                display(sprintf('\n\tready for puls'));
                % send a signal to the a USB to trigger the TMS pulse
                pause(parameters.waitBeforePulse);
                if parameters.TMS
                    MarkStim('t', 128);
                end
                WaitSecs(parameters.PulseDuration);
                display(sprintf('\n\ttrigger pulse sent to the TMS machine'));
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % wait for subject's response:
                % right click: not seen a phosphene, go to next trial
                % first left click: start drawing
                % second left click: end drawing
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                while 1
                    % show the mouse location and wait for subject's click
                    KbQueueStart(mbx);
                    [~, clickCode] = KbQueueCheck(mbx);
                    SetMouse(screen.xCenter, screen.yCenter, screen.win);
                    HideCursor(screen.win);
                    while ~any(clickCode)
                        [~, clickCode] = KbQueueCheck(mbx);
                        [x,y,~]=GetMouse(screen.win);
                        drawTextures(parameters, screen, 'MousePointer', x, y);
                    end
                    KbQueueStop(mbx);
                    Response.CoilLocation(trialInd) = coilLocInd;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Abort Trial
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if clickCode(parameters.right_key)
                        Response.Detection(trialInd) = 0;
                        Response.Drawing{trialInd} = nan;
                        showprompts(parameters, screen, 'NoPhosphene');
                        WaitSecs(2);
                        break
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Start Drawing
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    elseif clickCode(parameters.left_key)
                        Response.Detection(trialInd) = 1;
                        KbQueueStart(mbx);
                        [~, clickCode] = KbQueueCheck(mbx);
                        [x, y, ~] = GetMouse(screen.win);
                        XY = [x y];
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Finish Drawing
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        while ~clickCode(parameters.left_key)
                            [~, clickCode] = KbQueueCheck(mbx);
                            [x, y, ~] = GetMouse(screen.win);
                            XY = [XY; x y];
                            % Generate phosphene drawing
                            if XY(end,1) ~= XY(end-1,1) || XY(end,2) ~= XY(end-1,2)
                                drawTextures(parameters, screen, 'PhospheneDrawing', x, y, XY);
                            end
                            Screen('Flip', screen.win,[],1);
                        end
                        Response.Drawing{trialInd} = round(XY);
                        KbQueueStop(mbx);
                        break
                    end % end of recording the drawing process
                end
                Screen('Flip', screen.win); % clear Flip buffer
                drawTextures(parameters, screen, 'FixationCross');
                tmsRtnTpy.Response = Response;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % New coil location
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif strcmp(cmndKey, parameters.newloc_key) % get ready fo the next coil location if "n" is pressed
                showprompts(parameters, screen, 'NewLocation');
                break
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % End run
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif strcmp(cmndKey, parameters.quit_key) % quit the task if "q" is pressed
                break
            end
            drawTextures(parameters, screen, 'FixationCross');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % End run
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(cmndKey, parameters.quit_key) % quit the task if "q" is pressed
            showprompts(parameters, screen, 'Quit');
            WaitSecs(2);
            break
        end   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End run
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(cmndKey, parameters.quit_key)
        showprompts(parameters, screen, 'Quit');
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
saveDIR_auto = [data_path filesep 'Results_Auto/sub' subjID '/sess' session ...
    filesep datestr(now, 'mm_dd_yy_HH_MM_SS')];
if exist('saveDIR_auto', 'dir') ~= 7
    mkdir(saveDIR_auto);
end

saveName = [saveDIR_auto '/tmsRtnTpy_sub' subjID '_sess' session];
save(saveName,'tmsRtnTpy')

%%% save results
saveData = input(sprintf('\nsave results[y/n]?:  '),'s');
if strcmp(saveData,'y')
    saveDIR = [data_path filesep 'sub' subjID];
    if exist('saveDIR', 'dir') ~= 7
        mkdir(saveDIR);
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
end