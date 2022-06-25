function showprompts(parameters, screen, prompt_name)
% Created by mrugank (02/17/2022):
%global screen parameters;

switch prompt_name
    case 'WelcomeWindow'
        text =  parameters.instructions;
        text_color = parameters.text_color;
    case 'FirstMessage'
        text =  parameters.first_msg;
        text_color = parameters.text_color;
    case 'SecondMessage'
        text =  parameters.second_msg;
        text_color = parameters.text_color;
    case 'NewLocation'
        text =  parameters.new_coil_msg;
        text_color = screen.black;
    case 'NoPhosphene'
        text = parameters.no_phosph_msg;
        text_color = parameters.text_color;
    case 'Quit'
        text = parameters.quit_msg;
        text_color = parameters.text_color;
end
Screen('TextSize', screen.win, parameters.font_size);
DrawFormattedText(screen.win, text, 'center', 'center', text_color);
Screen('Flip', screen.win);
end