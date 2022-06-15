function showprompts(type)
% Created by mrugank (02/17/2022):
% Currently in temporary state. Has not yet been implemented in the code.
% It is produced by merging the individual showxxxx functions to avoid
% redundancy. Further testing is needed before implementing in the main
% code.

global screen;
global parameters;
global fixCrossData;
global taskMap;
global exitProgram;
white = screen.white;

switch type
    case 'EoeWindow'
        Screen('TextSize', screen.win, 40);
        DrawFormattedText(screen.win, parameters.thankYouMsg, 'center', 'center',white);
        Screen('Flip', screen.win);
        WaitSecs(5);
        sca;
        
    case 'EndOfCurrentRun' % make sure to consider the input "currentRun"
        text=(sprintf('Run # %d is over. Please get ready for the next run.',currentRun));
        Screen('TextSize', screen.win, 40);
        DrawFormattedText(screen.win, text, 'center', 'center',white);
        Screen('Flip', screen.win);
        
    case 'IntertrialWindow' % make sure to consider the input "tc"       
        %draw the fixation dot
        drawFixationCross(fixCrossData);
        Screen('Flip', screen.win);
        WaitSecs(taskMap(:,tc).iti);
        
    case 'LoadExperimentWindow'
        text = parameters.welcomeMsg;
        Screen('TextSize', screen.win, 40);
        DrawFormattedText(screen.win, text, 'center', 'center', white);
        Screen('Flip', screen.win);
        
    case 'StartOfRunWindow'
        text = parameters.startOfRunMsg;
        Screen('TextSize', screen.win, 40);
        DrawFormattedText(screen.win, text, 'center', 'center',white);
        Screen('Flip', screen.win);
        WaitSecs(1);
        
    case 'TTLWindow'
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