
clear all
global parameters
global screen

loadParameters()
initScreen()
WaitSecs(.5);
    % wait for a left click
    while 1
        Screen('FillOval',screen.win,[],[screen.xCenter-2 screen.yCenter-2 screen.xCenter+2 screen.yCenter+2] );
        Screen('Flip', screen.win);
        [x0,y0]=GetMouse(screen.win);
        [startClick,x_click,y_click,whichButton] = GetClicks(screen.win,.1);
        if startClick
            Screen('Flip', screen.win);
            break

        end
    end
    
    % start drawing on the screen till the next left click
    x_lastStp = x0;
    y_lastStp = y0;
    
    i = 1;
    clear dots
    while 1
%         WaitSecs(.05);
        [x,y,mousButton]=GetMouse(screen.win);
        dots.delta_xy(1,i) = x-x0;
        dots.delta_xy(2,i) = y-y0;
        dots.xy(1,i) = dots.delta_xy(1,i) + screen.xCenter;
        dots.xy(2,i) = dots.delta_xy(2,i) + screen.yCenter;
        
        Screen('FillOval',screen.win,[],[screen.xCenter-2 screen.yCenter-2 screen.xCenter+2 screen.yCenter+2] );
        Screen('DrawDots', screen.win, dots.xy,4 ,[1 1 1]);% [,center] [,dot_type][, lenient]);
%         Screen('FillOval',screen.win,[],[screen.xCenter+delta_x-2 screen.yCenter+delta_y-2 screen.xCenter+delta_x+2 screen.yCenter+delta_y+2] );
        Screen('Flip', screen.win);
        
        x_lastStp = x;
        y_lastStp = y;
        
        i = i+1;
%         [endClick,x_click,y_click,whichButton] = GetClicks(screen.win,.1);
        if mousButton(1)
            
            break
        end
    end
    
    


