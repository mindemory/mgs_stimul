function parameters = loadParameters(subjID, session)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% program basic settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.TMS = 1; % set to 0 if there is no TMS stimulation
parameters.transparency = 0.7; % transparency for debug mode
parameters.viewingDistance = 55; % viewDist in cm
parameters.waitBeforePulse = 2.00; % seconds
parameters.pointerSize = 5; % in pixels
parameters.fixationCrossSizeDeg = 0.6; % degrees of visual angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% study parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.currentStudy = 'MGS_TMS_VisualCortex';
parameters.currentStudyVersion = '01';
parameters.session = session;
parameters.subject = subjID;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TMS Pulse parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.PulseFrequency = 30; % in Hz
parameters.Pulsenum = 7;
parameters.PulseDuration = parameters.Pulsenum/parameters.PulseFrequency; % in seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prompt parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parameters.font_size = 30;
parameters.text_color = [128 0 0];
parameters.fixation_color = [128 0 0];
parameters.pointer_color = [0 0 128];
parameters.instructions = ['During the task you will be constantly seeing a black screen. \n' ...
    'Whenever there is a red fixation cross at the center of the screen, make sure to fixate on it.\n' ...
    'The prompts will guide you through the task. Use 1, 2, 3 keys on numpads on the right-side of the keyboard. \n' ...
    'Whenever you see a phosphene after the TMS pulse, use mouse to draw the phosphene.\n To begin drawing ' ...
    'make a left click and hold and drag the mouse to create the shape.\n Make a second mouse click to finish drawing. '...
    'If, however, you do not see a phosphene,\n make a right click and wait for the next prompt.\n' ...
    'Press any key to continue!'];
parameters.first_msg = '\n2: new coil location.\n3: terminate this run!\n2/3?: ';
parameters.second_msg = '1: new trial.\n2: new coil location.\n3: terminate this run!\n1/2/3: ';
parameters.no_phosph_msg = 'subject reported no phosphene';
parameters.new_coil_msg = 'new coil location requested';
parameters.quit_msg = 'program terminated by the experimenter!';
end
