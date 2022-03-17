function initPeripherals()

    global parameters kbx mbx hostname

    % Enable unified mode of KbName, so KbName accepts identical key names on
    % all operating systems:
    KbName('UnifyKeyNames');
    %   get keyboard pointer
    if strcmp(hostname, 'syndrome')
        devices = PsychHID('Devices');
        devIdx(1) = find([devices(:).usageValue] == 6);
        devIdx(2) = find([devices(:).usageValue] == 2);

        %  Initialize keyboard
        if ~isempty(devIdx(1))
            kbx = devIdx(1);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
        else
            error('External Keyboard not found')
        end

        %  Initialize mouse
        if ~isempty(devIdx(2))
            mbx = devIdx(2);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
        else
            error('External Mouse not found')
        end

        parameters.left_key = 1;
        parameters.right_key = 2;
        
        parameters.trial_key = '1';
        parameters.newloc_key = '2';
        parameters.quit_key = '3';

    elseif strcmp(hostname, 'tmsstim.cbi.fas.nyu.edu')
        disp("Never worked on this!")
        
    elseif strcmp(hostname, 'tmsubuntu')
        [~, ~, kboards] = GetKeyboardIndices();
        [~, ~, gpads] = GetGamepadIndices();
        for i = 1:length(kboards)
            if strcmp(kboards{1, i}.product, 'Mitsumi Electric Apple Extended USB Keyboard')
                devIdx(1) = kboards{1, i}.index;
            end
        end


        for i = 1:length(gpads)
            if strcmp(gpads{1, i}.product, 'PixArt Dell MS116 USB Optical Mouse')
                devIdx(2) = gpads{1, i}.index;
            end
        end

        %  Initialize keyboard
        if ~isempty(devIdx(1))
            kbx = devIdx(1);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
        else
            error('External Keyboard not found')
        end

        %  Initialize mouse
        if ~isempty(devIdx(2))
            mbx = devIdx(2);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
        else
            error('External Mouse not found')
        end

        parameters.left_key = 1;
        parameters.right_key = 3;
        
        parameters.trial_key = '1';
        parameters.newloc_key = '2';
        parameters.quit_key = '3';
    else
        disp('Running on unknown device. Psychtoolbox might not be added correctly!')
    end

    %   create keyboard events queue
    KbQueueCreate(kbx);
    KbQueueCreate(mbx);
end