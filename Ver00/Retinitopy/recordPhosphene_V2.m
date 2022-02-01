% function recordPhosphene()
clear all
global parameters screen kbx mbx

parameters.Puls.Frequency = 30;
parameters.Puls.num = 3;
parameters.Puls.Duration = parameters.Puls.num/parameters.Puls.Frequency;
 

loadParameters()
initScreen()
initKeyboard()

% fixation cross
FixCross = [screen.xCenter-1,screen.yCenter-4,screen.xCenter+1,screen.yCenter+4;...
    screen.xCenter-4,screen.yCenter-1,screen.xCenter+4,screen.yCenter+1];
Screen('FillRect', screen.win, [0,0,128], FixCross');
Screen('Flip', screen.win);

trialInd = 0;
while 1
    ListenChar(-1);
    % wait fot "g" key to be pressed
    [keyIsDown, keyCode]=KbQueueCheck(kbx);
    keyName = KbName(keyCode);
    % fixation cross
    Screen('FillRect', screen.win, [0,0,128], FixCross');
    Screen('Flip', screen.win);
    
    if keyIsDown
        keyName = KbName(keyCode);
        if strcmp(keyName,'g')
            
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
                
                % abort trial after subject's right click
                if clickCode(2)
                    TimeStmp.DetectionResp(trialInd) = GetSecs;
                    Response.Detection(trialInd) = 0;
                    duration.drawing(trialInd) = nan;
                    Response.Drawing.coords{trialInd} = nan;
                    display('subject reported "no phosphene" ')
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
            
        elseif strcmp(keyName,'q') % quit the task if "q" is pressed
            TimeStmp.ProgramTermination = GetSecs;
            display('program terminated by the experimenter')
            break
        end
        
    end
    
end
ListenChar(0);
ShowCursor(4,screen.win);
sca
