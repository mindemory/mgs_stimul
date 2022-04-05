%   Start of experiment window
function showSoeWindow()
    global screen;
    global parameters;
    
    white = screen.white;
    text = parameters.welcomeMsg;
    Screen('TextSize', screen.win, 40);
    DrawFormattedText(screen.win, text, 'center', 'center',white);
    Screen('Flip', screen.win);
end



