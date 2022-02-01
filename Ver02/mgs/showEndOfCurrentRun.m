function showEndOfCurrentRun(currentRun)
    global screen;
    global parameters;
    
    white = screen.white;
   
    text=(sprintf('Run # %d is over. Please get ready for the next run.',currentRun));
   
    Screen('TextSize', screen.win, 40);
    DrawFormattedText(screen.win, text, 'center', 'center',white);
    Screen('Flip', screen.win);
end