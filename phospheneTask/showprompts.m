function showprompts(screen, prompt_name)
font_size = 30;
text_color = [128 0 0];
switch prompt_name
    case 'WelcomeWindow'
        text = ['During the task you will be constantly seeing a black screen. \n' ...
            'Whenever there is a red fixation cross at the center of the screen, make sure to fixate on it.\n' ...
            'The prompts will guide you through the task. Use 1, 2, 3 keys on numpads on the right-side of the keyboard. \n' ...
            'Whenever you see a phosphene after the TMS pulse, use mouse to draw the phosphene.\n To begin drawing ' ...
            'make a left click and hold and drag the mouse to create the shape.\n Make a second mouse click to finish drawing. '...
            'If, however, you do not see a phosphene,\n make a right click and wait for the next prompt.\n' ...
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