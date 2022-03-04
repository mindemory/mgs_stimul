%function [prop] = E11_phospheneMapping(subjectID)
%% Instructions:
% OPENS UP A BLACK SCREEN WITH FIXATION CROSS
% PRESS AND HOLD THE MOUSE TO DRAW THE SHAPE OF A PHOSPHENE
% PLEASE FIXATE ON THE DARK BLUE FIXATION CROSS

% input subject initials and session number i.e. AF_1
% last edited: Antonio 06/12/19
%addpath(genpath('/home/antonio/Documents/Psychtoolbox'));
Screen('Preference', 'SkipSyncTests', 1);
%subjectID = [subjectID,'_',datestr(now,'yymmddTHHMM')];
try
    % Open up a window on the screen and clear it.
    whichScreen = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'UseVirtualFramebuffer');
    [theWindow,scr.resolution] = PsychImaging('OpenWindow', whichScreen, 0);
    %set screen params
    scr.dist = 57;
    scr.width = 53;
    % Move the cursor to the center of the screen
    theX = scr.resolution(RectRight)/2;
    theY = scr.resolution(RectBottom)/2;
    SetMouse(theX,theY,whichScreen);
    cx=theX;cy=theY;
    %draw fixation cross  
    blue = [0,0,255*0.3];
    fixCrossDimPix = 8;
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    % Set the line width for our fixation cross
    lineWidthPix = 2.5;
    Screen('DrawLines', theWindow, allCoords,lineWidthPix, blue, [theX theY]);
    % Wait for a click and hide the cursor
    Screen(theWindow,'TextSize',24);
    Screen('Flip', theWindow);
    disp('Test1')
    while (1)
        disp('Test2')
        [x,y,buttons] = GetMouse(theWindow);
        if buttons(1)
            disp('Test3')
          break;
        end
    end
    Screen('DrawLines', theWindow, allCoords,lineWidthPix, blue, [theX theY]);

    HideCursor;

    % Loop and track the mouse, drawing the contour
    [theX,theY] = GetMouse(theWindow);
    drawingXY = [theX theY];
    Screen(theWindow,'DrawLine',255,theX,theY,theX,theY);
    Screen('Flip', theWindow, 0, 1);
    disp('Test4')
    while (1)
        disp('Test5')
    
        [x,y,buttons] = GetMouse(theWindow);	
        if ~buttons(1)
            break;
        end
        
        if (x ~= theX || y ~= theY)
            disp('Test6')
    
            drawingXY = [drawingXY ; x y]; 
            [numPoints, two]=size(drawingXY);
            Screen(theWindow,'DrawLine',128,drawingXY(numPoints-1,1),drawingXY(numPoints-1,2),drawingXY(numPoints,1),drawingXY(numPoints,2));
            Screen('Flip', theWindow, 0, 1);
            theX = x; theY = y;
        end
    end

    % Close up
    Screen(theWindow,'DrawText','Click mouse to finish',50,50,255);
    ShowCursor;
    Screen(theWindow,'Close');
    
    % plot the phosphene
    scr.resolution = scr.resolution([3,4]);
    %prop = E12_plotPhospheneMap(subjectID,drawingXY,scr,[cx,cy]);
    
catch
    Screen('CloseAll')
    ShowCursor;
    psychrethrow(psychlasterror);
end 