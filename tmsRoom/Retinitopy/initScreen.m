function initScreen()
    global parameters;
    global screen;
    %   To make it transparent for working in demo mode
    if parameters.isDemoMode
        PsychDebugWindowConfiguration(0, parameters.transparency);
    end
    % degree of VA to pixel calculation
    screen.viewDist = parameters.viewingDistance; %the distance from the screen, in cm
    screen.id = max(Screen('Screens')); %get the screen 
    [screen.screenXpixels, screen.screenYpixels] = Screen('WindowSize', screen.id); %get x and y pixels of screen
    [screen.screenWidth, screen.screenHeight] = Screen('DisplaySize',screen.id); %get screen width and height in mm
    screen.screenWidth = screen.screenWidth/10; %mm to cm
    screen.screenHeight = screen.screenHeight/10; %mm to cm
    format short
       
    screen.Hperdegree = screen.viewDist * tan(deg2rad(1)); %height for one degree in cm
    screen.Wperdegree = screen.Hperdegree; %width for one degree in cm
    screen.pixWidth = screen.screenWidth/screen.screenXpixels; %cm/pixel
    screen.pixHeight = screen.screenHeight/screen.screenYpixels; %cm/pixel
    screen.xCenter = screen.screenXpixels/2;
    screen.yCenter = screen.screenYpixels/2;

    screen.deg_width = atand(screen.screenWidth/2 / screen.viewDist) * 2;
    screen.deg_height = atand(screen.screenHeight/2 / screen.viewDist) * 2;

    % screen init for PC and MAC
    screen.white = WhiteIndex(screen.id);
    screen.black = -1;
    screen.grey = screen.white*0.5;
    AssertOpenGL;
    % Set blend function for alpha blending

    [screen.win, screen.screenRect] = PsychImaging('OpenWindow', screen.id,screen.black, [], 32, 2, [], [], kPsychNeed32BPCFloat);
    screen.ifi = Screen('GetFlipInterval', screen.win);

    % Retreive the maximum priority number
    topPriorityLevel = MaxPriority(screen.win);
    Screen('BlendFunction', screen.win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    %screen.pixels_per_deg_width = screen.screenXpixels/screen.deg_width; 
    %screen.pixels_per_deg_height = screen.screenYpixels/screen.deg_height;
end