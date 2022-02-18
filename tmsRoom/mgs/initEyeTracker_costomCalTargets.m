
global parameters;
global screen;
% Eyelink('SetAddress','192.168.1.5') % for the scanner room

    
%%

%INITIALIZE EYE TRACKER & RUN CALIBRATION
%run without eye tracker if dummymode set to 1
if parameters.dummymode == 0
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    parameters.eyeTrackerOn = 1;
    el=EyelinkInitDefaults(screen.win);
    
    el.backgroundcolour = screen.grey;%BlackIndex(el.window);
    el.msgfontcolour    = BlackIndex(el.window);
    el.imgtitlecolour = WhiteIndex(el.window);
    el.targetbeep = 0;
    el.calibrationtargetcolour= WhiteIndex(el.window);
    el.calibrationtargetsize= 0.5;
    el.calibrationtargetwidth=0.15;
    el.displayCalResults = 1;
    el.eyeimgsize=30;
    EyelinkUpdateDefaults(el);

    %Initialization of the connection with the Eyelink Gazetracker.
    %exit program if this fails.
    if ~EyelinkInit(parameters.dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % set calibration type.
    %%%%%%%%%%%%%%%%%%%%%%%
    width = screen.screenXpixels;
    height = screen.screenYpixels;
    
    Eyelink('command', 'calibration_type = HV9');
    % you must send this command with value NO for custom calibration
    % you must also reset it to YES for subsequent experiments
    Eyelink('command', 'generate_default_targets = NO');
    
    %  modify calibration and validation target locations
    Eyelink('command','calibration_samples = 10');
    Eyelink('command','calibration_sequence = 0,1,2,3,4,5,6,7,8');
    Eyelink('command','calibration_targets = %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d',...
        width/2,height/2, width/2,height*0.2, width/2,height-height*0.2, width*0.2,height/2, width-width*0.2,height/2, width*0.2,height*0.2, width-width*0.2,height*0.2,  width*0.2,height-height*0.2, width-width*0.2,height-height*0.2);
    Eyelink('command','validation_samples = 10');
    Eyelink('command','validation_sequence = 0,1,2,3,4,5,6,7,8');
    Eyelink('command','validation_targets = %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d',...
        width/2,height/2, width/2,height*0.2, width/2,height-height*0.2, width*0.2,height/2, width-width*0.2,height/2, width*0.2,height*0.2,  width-width*0.2,height*0.2, width*0.2,height-height*0.2, width-width*0.2,height-height*0.2);
    
    %%%%%%%%%%%%%%%%%%%%%%%
    
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );

    % make sure that we get event data from the Eyelink
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE,BUTTON');

    % open file to record data to
    %edfFile= [resultsFile '.edf'];
    Eyelink('Openfile', parameters.edfFile);

    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);

    %  do a final check of calibration using driftcorrection
%    EyelinkDoDriftCorrection(el);

    WaitSecs(0.1);
%     Eyelink('StartRecording');

    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR; % if both eyes are tracked
       eye_used = el.LEFT_EYE; % use left eye
    end
end