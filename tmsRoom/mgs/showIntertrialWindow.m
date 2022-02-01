function showIntertrialWindow(tc)

    global fixCrossData;
    global screen;
    global taskMap;
    
    %draw the fixation dot
    drawFixationCross(fixCrossData);
    Screen('Flip', screen.win);
    WaitSecs(taskMap(:,tc).iti);
end