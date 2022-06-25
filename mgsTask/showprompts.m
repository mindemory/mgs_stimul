function showprompts(screen, prompt_name, num, cond)
% Created by mrugank (02/17/2022):
%global screen parameters;

switch prompt_name
    case 'WelcomeWindow'
        text =  ['Welcome to the task.\n The task is arranged in blocks.\n'...
            'A block can either be "pro" or "anti" signaled by a black or white dot respectively, at the start of the block.\n'...
            'Each block consists of 42 trials which have a stimulus (a white dot) displayed at a location on the screen\n'...
            'which disappears for 4 seconds delay. Your task is to remember the location of the dot while fixating on the\n'...
            'central fixation cross. The fixation cross will turn green at the end of the delay which is the signal to make saccade.\n'...
            'In a "pro" block, correct saccade is the one made to the stimulus location, while in an "anti" block, correct\n'...
            'saccade is the one made to the direction opposite to the stimulus location. After each trial, feedback will be\n'...
            'provided by a green dot. Press any key to continue ...'];
    case 'BlockExists'
        text = ['Block ' num2str(num) ' already exists. Press space if you still want to continue.'];
    case 'BlockStart'
        text = ['Block = ' num2str(num) '\nBlock type = ' cond];
    case 'TrialCount'
        text = ['Trial = ' num2str(num)];
    case 'BlockEnd'
        text = ['End of block ' num2str(num) '. Please take a break. Press any key to continue.'];
    case 'EndExperiment'
        text = 'Thank you for your participation!';
end
fontsize = 40;
text_color = screen.white;
Screen('TextSize', screen.win, fontsize);
DrawFormattedText(screen.win, text, 'center', 'center', text_color);
Screen('Flip', screen.win);
end