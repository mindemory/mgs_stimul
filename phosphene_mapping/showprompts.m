function showprompts(prompt_name)
% Created by mrugank (02/17/2022):
% Currently in temporary state. Has not yet been implemented in the code.
% It is produced by merging the individual showxxxx functions to avoid
% redundancy. Further testing is needed before implementing in the main
% code.

global screen parameters;


switch prompt_name
    case 'WelcomeWindow'
        Screen('TextSize', screen.win, parameters.font_size);
        DrawFormattedText(screen.win, parameters.instructions, 'center', ...
            'center', parameters.text_color);
        Screen('Flip', screen.win);
    case 'FirstMessage'
        Screen('TextSize', screen.win, parameters.font_size);
        DrawFormattedText(screen.win, parameters.first_msg, 'center', ...
            'center', parameters.text_color);
        Screen('Flip', screen.win);
    case 'SecondMessage'
        Screen('TextSize', screen.win, parameters.font_size);
        DrawFormattedText(screen.win, parameters.second_msg, ...
            'center', 'center', parameters.text_color);
        Screen('Flip', screen.win);
    case 'NewLocation'
        Screen('TextSize', screen.win, parameters.font_size);
        DrawFormattedText(screen.win, parameters.new_coil_msg, ...
            'center', 'center', screen.black);
        Screen('Flip', screen.win);
    case 'NoPhosphene'
        Screen('TextSize', screen.win, parameters.font_size);
        DrawFormattedText(screen.win, parameters.no_phosph_msg, ...
            'center', 'center', parameters.text_color);
        Screen('Flip', screen.win);
    case 'Quit'
        Screen('TextSize', screen.win, parameters.font_size);
        DrawFormattedText(screen.win, parameters.quit_msg, 'center', 'center', parameters.text_color);
        Screen('Flip', screen.win);
end