
function showTextMessage(window, color, text, kbx)
    %Demonstrates given text on current window. Waits until user presses 
    %the SPACE key and moves to another window
    FlushEvents;
    Screen('TextSize', window, 40);
    DrawFormattedText(window, text, 'center', 'center',color);
    Screen('Flip', window);
    ourKeyPressed = 0;

    while ~ourKeyPressed
          [keyIsPressed,secs, keyCode, deltaSecs] = KbCheck(kbx);
          if keyIsPressed
             if      keyCode(KbName('1!'))| keyCode(KbName('1'))|...
                     keyCode(KbName('2@'))| keyCode(KbName('2'))|...
                     keyCode(KbName('3#'))| keyCode(KbName('3'))|...
                     keyCode(KbName('4$'))| keyCode(KbName('4'))
                    ourKeyPressed = 1;
             end
          end
    end
    FlushEvents;
    WaitSecs(0.2); %wait here to allow for key release
end