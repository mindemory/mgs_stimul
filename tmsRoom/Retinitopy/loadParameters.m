%% mrugank (01/31/2022): Created to not enter subject details at each run. 
%% Only for debugging purposes.
%   loads experimental parameters
function parameters = loadParameters(subjID, session)
    global parameters;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % program basic settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.TMS = 1; % set to 0 if there is no EEG recording
    parameters.dummymode = 1; % set to 0 if you want to use eyetracker
    parameters.isDemoMode = false; %set to true if you want the screen to be transparent
    parameters.transparency = 0.6;
    parameters.viewingDistance = 55;%viewDist
    parameters.waitBeforePulse = 3.00; % seconds
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % study parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    parameters.currentStudy = 'TMS_vCortex';
    parameters.session = session;
    parameters.subject = subjID;
    parameters.setTime = datestr(now);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % file parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    parameters.datafile = 'unitled.csv';
    parameters.matfile = 'untitled.mat';
    parameters.taskMapFile = 'untitled_taskMap.mat';
    parameters.edfFile = 'untd.edf'; % can only be 4 characters long
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TMS Pulsee parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.Pulse.Frequency = 30;
    parameters.Pulse.num = 3;
    parameters.Pulse.Duration = parameters.Pulse.num/parameters.Pulse.Frequency;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % prompt parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.font_size = 30;
    parameters.text_color = [128 0 0];
    parameters.fixation_color = [128 0 0];
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  geometry parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parameters.greyFactor = 0.5; % to make screen background darker or lighter
    parameters.overlapThreshold = 2; % count an area phosphened if in more than "overlapThreshold" number of trials the subject reports it.
    
end
