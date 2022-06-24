function showprompts(prompt_name)
% Created by mrugank (02/17/2022):
% Currently in temporary state. Has not yet been implemented in the code.
% It is produced by merging the individual showxxxx functions to avoid
% redundancy. Further testing is needed before implementing in the main
% code.

global screen parameters;

switch prompt_name
    case 'LoadExperimentWindow'
        text = parameters.welcomeMsg;
        Screen('TextSize', screen.win, 40);
        DrawFormattedText(screen.win, text, 'center', 'center', screen.white);
        Screen('Flip', screen.win);
    case 'EndExperimentWindow' %to be checked
        Screen('TextSize', screen.win, 40);
        DrawFormattedText(screen.win, parameters.thankYouMsg, 'center', 'center',screen.white);
        Screen('Flip', screen.win);
        WaitSecs(5);
        sca;   
    case 'EndOfCurrentRun' %to be checked
        text=(sprintf('Run # %d is over. Please get ready for the next run.',currentRun));
        Screen('TextSize', screen.win, 40);
        DrawFormattedText(screen.win, text, 'center', 'center',screen.white);
        Screen('Flip', screen.win);   
    case 'StartOfRunWindow' %to be checked
        text = parameters.startOfRunMsg;
        Screen('TextSize', screen.win, 40);
        DrawFormattedText(screen.win, text, 'center', 'center',screen.white);
        Screen('Flip', screen.win);
        WaitSecs(1);
end