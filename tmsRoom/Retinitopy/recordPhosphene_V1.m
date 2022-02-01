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

%%
% function recordPhosphene()
sca; clear; close all; clc;
global parameters screen kbx mbx

parameters = loadParameters_trial();
parameters.Puls.Frequency = 30;
parameters.Puls.num = 3;
parameters.Puls.Duration = parameters.Puls.num/parameters.Puls.Frequency;

Screen('Preference','SkipSyncTests', 1) %% mrugank (01/29/2022): To suppress VBL Sync Error by PTB

initScreen(parameters)
initKeyboard()

% fixation cross
FixCross = [screen.xCenter-1, screen.yCenter-4, screen.xCenter+1, screen.yCenter+4;...
    screen.xCenter-4, screen.yCenter-1, screen.xCenter+4, screen.yCenter+1];
Screen('FillRect', screen.win, [0,0,128], FixCross');
Screen('Flip', screen.win);
KbStrokeWait;
trialInd = 0;
%%
while 1
    ListenChar(-1);
    
    % wait fot "g" key to be pressed
    [keyIsDown, keyCode] = KbQueueCheck(kbx);
    keyName = KbName(keyCode);
    
    % fixation cross
    Screen('FillRect', screen.win, [0,0,128], FixCross');
    Screen('Flip', screen.win);
    
    if keyIsDown
        keyName = KbName(keyCode);
        
        if strcmp(keyName,'g')
            beep
            trialInd = trialInd+1;
            strtTime.trial(trialInd) = GetSecs;
            %%%%%%%%%%%%%%%%%%%
            display('ready for puls')
            strtTime.puls(trialInd) = GetSecs;
            % send a signal to the a USB to trigger the TMS puls
            
            WaitSecs(parameters.Puls.Duration);
            display('puls sent to ... port to trigger the TMS puls')
            %%%%%%%%%%%%%%%%%%%
            
            % wait for subject's response:
            %           right click: not seen a phosphene, go to next trial
            %           left click: start drawing
            
            while 1
                
                strtTime.preResp(trialInd) = GetSecs;
                % show the mouse location and wait for subject's click
                KbQueueStart(mbx);
                [mouseKlick, clickCode]=KbQueueCheck(mbx);
                [x0,y0,mousButton1]=GetMouse(screen.win);
                while ~any(clickCode)
                    [mouseKlick, clickCode]=KbQueueCheck(mbx);
                    [x,y,mousButton]=GetMouse(screen.win);
                    mouse.x = x-x0 + screen.xCenter;
                    mouse.y = y-y0 + screen.yCenter;
                    
                    Screen('FillRect', screen.win, [0,0,128], FixCross');
                    Screen('FillOval',screen.win,[screen.white],[mouse.x-2 mouse.y-2 mouse.x+2 mouse.y+2] );
                    Screen('Flip', screen.win);
                end
                KbQueueStop(mbx);
                duration.preResp(trialInd) = GetSecs - strtTime.preResp(trialInd); 
                % abort trial after subject's right click
                if clickCode(2)
                    TimeStmp.DetectionResp(trialInd) = GetSecs;
                    Response.Detection(trialInd) = 0;
                    duration.drawing(trialInd) = nan;
                    display('subject reported "no phosphene" ')
                    break
                % start drawing after a left click   
                elseif clickCode(1)
                    TimeStmp.DetectionResp(trialInd) = GetSecs;
                    strtTime.drawing(trialInd) = GetSecs;
                    Response.Detection(trialInd) = 1;
                    i = 1;
                    clear dots
                    
                    KbQueueStart(mbx);
                    [mouseKlick, clickCode]=KbQueueCheck(mbx);
                    
                    while ~clickCode(1) % end drawing if left click pressed
                        [mouseKlick, clickCode]=KbQueueCheck(mbx);
                        [x,y,mousButton]=GetMouse(screen.win);
                        dots.delta_xy(1,i) = x-x0;
                        dots.delta_xy(2,i) = y-y0;
                        dots.xy(1,i) = dots.delta_xy(1,i) + screen.xCenter;
                        dots.xy(2,i) = dots.delta_xy(2,i) + screen.yCenter;
                        
                        Screen('FillRect', screen.win, [0,0,128], FixCross');
                        Screen('DrawDots', screen.win, dots.xy,4 ,[screen.white]);
                        Screen('Flip', screen.win);
                        i = i+1;
                    end
                    duration.drawing(trialInd) = GetSecs - strtTime.drawing(trialInd);
                    KbQueueStop(mbx);
                    break
                    %%%%%%%%%%%%%%%%%% record a report of the drawing,
                    %%%%%%%%%%%%%%%%%% trial, etc
                    
                end
            end
            duration.trial(trialInd) = GetSecs - strtTime.trial(trialInd);
            
        elseif strcmp(keyName,'q') % quit the task if "q" is pressed
            TimeStmp.ProgramTermination = GetSecs;
            display('program terminated by the experimenter')
            break
        end
        
    end
    
end
ListenChar(0);
sca
