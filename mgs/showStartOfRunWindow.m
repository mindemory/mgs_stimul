%   Start of experiment window
function showStartOfRunWindow()
    global screen;
    global parameters;
    
    white = screen.white;
    text = parameters.startOfRunMsg;
    Screen('TextSize', screen.win, 40);
    DrawFormattedText(screen.win, text, 'center', 'center',white);
    Screen('Flip', screen.win);
    WaitSecs(1);
end