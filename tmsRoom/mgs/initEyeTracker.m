
%INITIALIZE EYE TRACKER & RUN CALIBRATION
%run without eye tracker if dummymode set to 1
if parameters.dummymode == 0
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    parameters.eyeTrackerOn = 1;
    el=EyelinkInitDefaults(screen.win);

    %Initialization of the connection with the Eyelink Gazetracker.
    %exit program if this fails.
    if ~EyelinkInit(parameters.dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end


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
    EyelinkDoDriftCorrection(el);

    WaitSecs(0.1);
%     Eyelink('StartRecording');

    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR % if both eyes are tracked
       eye_used = el.LEFT_EYE; % use left eye
    end
end
