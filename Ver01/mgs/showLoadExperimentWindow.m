%   Start of experiment window
function showLoadExperimentWindow()
    global screen;
    white = screen.white;
    text = 'Loading the experiment, please wait...';
    Screen('TextSize', screen.win, 40);
    DrawFormattedText(screen.win, text, 'center', 'center',white);
    Screen('Flip', screen.win);
end
