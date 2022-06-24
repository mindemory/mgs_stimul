% Clear the workspace and the screen
sca;
close all;
clear;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% The avaliable keys to press
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Make a base Rect of 200 by 200 pixels
baseRect = [0 0 200 200];

% Set the color of the rect to red
rectColor = [1 0 0];

% Set the intial position of the square to be in the centre of the screen
squareX = xCenter;
squareY = yCenter;

% Set the amount we want our square to move on each button press
pixelsPerPress = 10;

% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% This is the cue which determines whether we exit the demo
exitDemo = false;

% Loop the animation until the escape key is pressed
while exitDemo == false

    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;

    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey)
        exitDemo = true;
    elseif keyCode(leftKey)
        squareX = squareX - pixelsPerPress;
    elseif keyCode(rightKey)
        squareX = squareX + pixelsPerPress;
    elseif keyCode(upKey)
        squareY = squareY - pixelsPerPress;
    elseif keyCode(downKey)
        squareY = squareY + pixelsPerPress;
    end

    % We set bounds to make sure our square doesn't go completely off of
    % the screen
    if squareX < 0
        squareX = 0;
    elseif squareX > screenXpixels
        squareX = screenXpixels;
    end

    if squareY < 0
        squareY = 0;
    elseif squareY > screenYpixels
        squareY = screenYpixels;
    end

    % Center the rectangle on the centre of the screen
    centeredRect = CenterRectOnPointd(baseRect, squareX, squareY);

    % Draw the rect to the screen
    Screen('FillRect', window, rectColor, centeredRect);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

end

% Clear the screen
sca;