%% Edits by Mrugank (01/29/2022)
% Suppressed VBL Sync Error by PTB, added sca, clear; close all;

%% Check the system name to ensure correct paths are added.
[ret, hostname] = system('hostname');   
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

%% Load PTB and toolboxes
if strcmp(hostname, 'syndrome')
    % Location of PTB on Syndrome
    addpath(genpath('/Users/Shared/Psychtoolbox')) %% mrugank (01/28/2022): load PTB
elseif strcmp(hostname, 'tmsstim.cbi.fas.nyu.edu')
    % Location of toolboxes on TMS Stimul Mac
    addpath(genpath('/Users/curtislab/TMS_Priority/exp_materials/'))
    rmpath(genpath('/Users/curtislab/matlab/mgl'));
    addpath(genpath('/Users/curtislab/Documents/MATLAB/mgl2'));
end

% function recordPhosphene()
sca; clear; close all; clc;
global parameters screen kbx mbx

parameters = loadParameters_trial();
parameters.Puls.Frequency = 30;
parameters.Puls.num = 3;
parameters.Puls.Duration = parameters.Puls.num/parameters.Puls.Frequency;

subjID = int2strz(input(sprintf('\nsubject: ')),2);
session = int2strz(input(sprintf('\nsession: ')),2);

%%%% Create a directory to save all files with their times
saveDIR_auto = ['Results_Auto/sub' subjID '/sess' session '/' datestr(now)];
if ~exist('saveDIR_auto','dir')
    mkdir(saveDIR_auto);
end

Screen('Preference','SkipSyncTests', 1) %% mrugank (01/29/2022): To suppress VBL Sync Error by PTB

initScreen(parameters)
initKeyboard()

% fixation cross
FixCross = [screen.xCenter-1,screen.yCenter-4,screen.xCenter+1,screen.yCenter+4;...
    screen.xCenter-4,screen.yCenter-1,screen.xCenter+4,screen.yCenter+1];
Screen('FillRect', screen.win, [0,0,128], FixCross');
Screen('Flip', screen.win);

tmsRtnTpy.Params.ID = ['sub' subjID '_sess' session];
tmsRtnTpy.Params.screen = screen;
tmsRtnTpy.Params.taskParams = parameters;

trialInd = 0;
coilLocInd = 0;
cmndKey=nan;

while 1
    if ~strcmp(cmndKey,'n') || strcmp(cmndKey,'q')
        clear cmndKey
        cmndKey = input(sprintf('\nn: new coil location.\nq : terminate this run!\nn/q?: '),'s');
    end
    if strcmp(cmndKey,'n')
        display(sprintf('\n---------------------------------------------'));
        display(sprintf('\n\tnew coil location initiated.'));
        coilLocInd = coilLocInd+1;
        
        saveName = [saveDIR_auto '/tmsRtnTpy_sub' subjID '_sess' session];
        save(saveName,'tmsRtnTpy')

        while 1
            
            KbQueueStart(kbx);
            display(sprintf('\ng : new trial.\nn : new coil location.\nq : terminate this run!\ng/n/q: '))
            [keyIsDown, keyCode]=KbQueueCheck(kbx);
            while ~keyIsDown
                [keyIsDown, keyCode]=KbQueueCheck(kbx);
                cmndKey = KbName(keyCode);
            end
            if strcmp(cmndKey,'g')
                ListenChar(-1);
                trialInd = trialInd+1;
                strtTime.trial(trialInd) = GetSecs;
                %%%%%%%%%%%%%%%%%%%
                display(sprintf('\n\tready for puls'));
                strtTime.puls(trialInd) = GetSecs;
                % send a signal to the a USB to trigger the TMS puls
                
%                 daq=DaqDeviceIndex([],0);
%                 err=DaqAOut(daq,0,0);
%                 err2=DaqAOut(daq,0,1);
%                 err=DaqAOut(daq,0,0);
                
                
                WaitSecs(parameters.Puls.Duration);
                display(sprintf('\n\ttrigger pulse sent to the TMS machine'));
                %%%%%%%%%%%%%%%%%%%
                
                % wait for subject's response:
                %           right click: not seen a phosphene, go to next trial
                %           first left click: start drawing
                %           second left click: end drawing 
                while 1
                    
                    strtTime.preResp(trialInd) = GetSecs;
                    % show the mouse location and wait for subject's click
                    KbQueueStart(mbx);
                    [mouseKlick, clickCode]=KbQueueCheck(mbx);
                    
                    SetMouse(screen.xCenter,screen.yCenter,screen.win);
                    HideCursor(screen.win);
                    
                    while ~any(clickCode)
                        [mouseKlick, clickCode]=KbQueueCheck(mbx);
                        [x,y,mousButton]=GetMouse(screen.win);
                        
                        Screen('FillRect', screen.win, [0,0,128], FixCross');
                        Screen('FillOval',screen.win,[screen.white],[x-2 y-2 x+2 y+2] );
                        Screen('Flip', screen.win);
                    end
                    KbQueueStop(mbx);
                    duration.preResp(trialInd) = GetSecs - strtTime.preResp(trialInd);
                    Response.CoilLocation(trialInd) = coilLocInd;
                    % abort trial after subject's right click
                    if clickCode(2)
                        TimeStmp.DetectionResp(trialInd) = GetSecs;
                        Response.Detection(trialInd) = 0;
                        duration.drawing(trialInd) = nan;
                        Response.Drawing.coords{trialInd} = nan;
                        display(sprintf('\n\tsubject reported "no phosphene" '));
                        break
                        
                        % start drawing after a left click
                    elseif clickCode(1)
                        TimeStmp.DetectionResp(trialInd) = GetSecs;
                        strtTime.drawing(trialInd) = GetSecs;
                        Response.Detection(trialInd) = 1;
                        
                        Screen('FillRect', screen.win, [0,0,128], FixCross');
                        
                        KbQueueStart(mbx);
                        [mouseKlick, clickCode]=KbQueueCheck(mbx);
                        
                        [x,y,mousButton]=GetMouse(screen.win);
                        XY = [x y];
                        
                        while ~clickCode(1) % end drawing if left click pressed
                            [mouseKlick, clickCode]=KbQueueCheck(mbx);
                            [x,y,mousButton]=GetMouse(screen.win);
                            XY = [XY; x y];
                            if XY(end,1) ~= XY(end-1,1) || XY(end,2) ~= XY(end-1,2)
                                Screen('DrawLine',screen.win,screen.white,XY(end-1,1),XY(end-1,2),XY(end,1),XY(end,2),1);
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
                Screen('FillRect', screen.win, [0,0,128], FixCross');
                Screen('Flip', screen.win);
                ListenChar(0);
                
                tmsRtnTpy.TimeStmp = TimeStmp;
                tmsRtnTpy.Duration = duration;
                tmsRtnTpy.Response = Response;
                tmsRtnTpy.StrtTime = strtTime;
                
            elseif strcmp(cmndKey,'n') % get ready fo the next coil location if "n" is pressed
                TimeStmp.ThisCoilLocationTermination = GetSecs;
                display(sprintf('\n\ta new coil location requested!'));
                break
            elseif strcmp(cmndKey,'q') % quit the task if "q" is pressed
                break
            end
        end
        
        if strcmp(cmndKey,'q') % quit the task if "q" is pressed
            TimeStmp.ProgramTermination = GetSecs;
            display(sprintf('\n\tprogram terminated by the experimenter!'));
            break
        end
        
    elseif strcmp(cmndKey,'q')
        TimeStmp.ProgramTermination = GetSecs;
        display(sprintf('\n\tprogram terminated by the experimenter!'));
        break
    end
end
KbQueueRelease;
ListenChar(0);
ShowCursor;
sca

saveName = [saveDIR_auto '/tmsRtnTpy_sub' subjID '_sess' session];
save(saveName,'tmsRtnTpy')

%%% save results
saveData = input(sprintf('\nsave results[y/n]?:  '),'s');
if strcmp(saveData,'y')
    saveDIR = ['Results/sub' subjID];
    if ~exist('saveDIR','dir')
        mkdir(saveDIR);
    end
    saveName = [saveDIR '/tmsRtnTpy_sub' subjID '_sess' session];
    save(saveName,'tmsRtnTpy')
end
