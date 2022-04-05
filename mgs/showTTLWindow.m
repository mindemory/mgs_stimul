function showTTLWindow()
    global screen;
    global exitProgram;
    global parameters;
    
    white = screen.white;
    text = parameters.ttlMsg;

    %Demonstrates given text on current window. Waits until user presses 
    %the SPACE key and moves to another window
    
    Screen('TextSize', screen.win, 40);
    DrawFormattedText(screen.win, text, 'center', 'center',white);
    Screen('Flip', screen.win);
    
    
    while true
      [keyIsPressed,secs, keyCode, deltaSecs] = KbCheck();
      if keyIsPressed
         if keyCode(KbName(sprintf('%s%s','`','~'))) | keyCode(KbName('5%')) %remove the last one
                break;
         end
      end
    end
end