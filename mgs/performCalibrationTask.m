if dummymode == 0
    grey = evalin('base','grey');
    windowRect=evalin('base','windowRect');
    Screen('FillRect', window, grey,windowRect);
    %clear the event buffer
    FlushEvents;
    %create outputs for debugging without eye tracker
    if dummymode == 1
       avgGazeCenter = 0;
       avgPupilSize = 0;
    end
    %create instructions for the 5 second task
    Screen('TextSize', window, 30);
    DrawFormattedText(window, 'Starting calibration task', 'center', 'center');
    Screen('Flip', window);
    ourKeyPressed = 0;
    continueKey = KbName('space');


    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(window);

    %Initialization of the connection with the Eyelink Gazetracker.
    %exit program if this fails.
    if ~EyelinkInit(dummymode, 1)
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

    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);

    %  do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    WaitSecs(0.1);
    Eyelink('StartRecording');

    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR; % if both eyes are tracked
       eye_used = el.LEFT_EYE; % use left eye
    end



    %create end of the task screen
    Screen('FillRect', window, grey,windowRect);
    Screen('TextSize', window, 40);
    DrawFormattedText(window, 'Thank you. When ready, press key to continue.', 'center', 'center');
    Screen('Flip', window);
    ourKeyPressed = 0;
    continueKey = KbName('space');

    while ~ourKeyPressed
      % Monitor subject's responces
        %---------------------------------------------------------------------------------
        % Monitor subject's responces
        [ pressed, firstPress]=KbQueueCheck(bbx);

        % If the user has pressed a key, then display its code number and name.
        if pressed
            ourKeyPressed = 1;
        end
    end
    FlushEvents; 
end





