function showprompts(screen, prompt_name)
font_size = 30;
text_color = [128 0 0];
switch prompt_name
    case 'WelcomeWindow'
        text = ['Welcome to the task.\n' ...
            'Press any key to continue!'];
    case 'FirstMessage'
        text = '\n2: new coil location.\n3: terminate this run!\n2/3?: ';
    case 'SecondMessage'
        text = '1: new trial.\n2: new coil location.\n3: terminate this run!\n1/2/3: ';
    case 'NewLocation'
        text = 'new coil location requested';
        text_color = screen.black;
    case 'NoPhosphene'
        text = 'subject reported no phosphene';
    case 'Quit'
        text = 'program terminated by the experimenter!';
end
Screen('TextSize', screen.win, font_size);
DrawFormattedText(screen.win, text, 'center', 'center', text_color);
Screen('Flip', screen.win);
end