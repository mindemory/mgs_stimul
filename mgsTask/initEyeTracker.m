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
    [~, version]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', version);
    Eyelink('command', 'sample_rate = 1000');
    Eyelink('command', 'calibration_type = HV9');
    Eyelink('command', 'generate_default_targets = NO');
    width = screen.screenXpixels;
    height = screen.screenYpixels;
    Eyelink('command', 'calibration_sequence = 0,1,2,3,4,5,6,7,8');
    Eyelink('command', 'calibration_targets = %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d', ...
        width/2,height/2, width/2,height*0.2, width/2,height-height*0.2, width*0.2,height/2, ...
        width-width*0.2,height/2, width*0.2,height*0.2, width-width*0.2,height*0.2, ...
        width*0.2,height-height*0.2, width-width*0.2,height-height*0.2);
    Eyelink('command', 'validation_sequence = 0,1,2,3,4,5,6,7,8');
    Eyelink('command', 'validation_targets = %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d', ...
        width/2,height/2, width/2,height*0.2, width/2,height-height*0.2, width*0.2,height/2, ...
        width-width*0.2,height/2, width*0.2,height*0.2, width-width*0.2,height*0.2, ...
        width*0.2,height-height*0.2, width-width*0.2,height-height*0.2);
    
    % make sure that we get event data from the Eyelink
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'file_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,STATUS');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,BUTTON');
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY');
    
    % open file to record data to
    Eyelink('Openfile', 'temp.edf');
    
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR % if both eyes are tracked
        eye_used = el.RIGHT_EYE; % use left eye
    end
end
end