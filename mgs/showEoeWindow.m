%   End of experiment window
function showEoeWindow()
    global screen;
    global parameters;
    white = screen.white;

    Screen('TextSize', screen.win, 40);
    DrawFormattedText(screen.win, parameters.thankYouMsg, 'center', 'center',white);
    Screen('Flip', screen.win);
    WaitSecs(5);
    sca;
end
