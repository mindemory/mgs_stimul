function [el, eye_used] = initEyeTracker(parameters, screen)
%%
%INITIALIZE EYE TRACKER & RUN CALIBRATION
%run without eye tracker if eyetracker is 0
% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).\
if parameters.eyetracker
    parameters.eyeTrackerOn = 1;
    el=EyelinkInitDefaults(screen.win);
    
    el.backgroundcolour = screen.grey;
    el.msgfontcolour = BlackIndex(el.window);
    el.imgtitlecolour = WhiteIndex(el.window);
    el.targetbeep = 0;
    el.calibrationtargetcolour = BlackIndex(el.window);
    el.calibrationtargetsize = 1;
    el.calibrationtargetwidth = 0.15;
    el.displayCalResults = 1;
    %el.eyeimgsize=30;
    EyelinkUpdateDefaults(el);
    
    %Initialization of the connection with the Eyelink Gazetracker.
    %exit program if this fails.
    if ~EyelinkInit(~parameters.eyetracker, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % set calibration type.
    %%%%%%%%%%%%%%%%%%%%%%%
    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs);
    Eyelink('command', 'sample_rate = 1000');
    Eyelink('command', 'calibration_type = HV9');
    Eyelink('command', 'generate_default_targets = YES');    
    
    % make sure that we get event data from the Eyelink
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,BLINK,SACCADE,BUTTON');
    
    % open file to record data to
    Eyelink('Openfile', 'temp.edf');
    
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR % if both eyes are tracked
        eye_used = el.RIGHT_EYE; % use left eye
    end
end
end