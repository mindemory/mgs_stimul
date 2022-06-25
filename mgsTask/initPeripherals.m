function [kbx, parameters] = initPeripherals(parameters, hostname)
    % Detects peripherals: mouse and keyboard and runs KbQueueCreate on
    % each of them. Code is adapted for Mac and Ubuntu.
    KbName('UnifyKeyNames');
    
    %% Mac Optimized
    if strcmp(hostname, 'syndrome')
        % get keyboard and mouse pointers for the current setup
        devices = PsychHID('Devices');
        devIdx(1) = find([devices(:).usageValue] == 6);
        
        parameters.space_key = 'space';
        parameters.exit_key = 'ESCAPE';
    
    %% Ubuntu Optimized
    elseif strcmp(hostname, 'tmsubuntu')
        % Ubuntu does not support PsychHID. Instead GetKeyboardIndices and
        % GetGamepadIndices is used.
        % get keyboard and mouse pointers for the current setup
        [~, ~, kboards] = GetKeyboardIndices();
        for i = 1:length(kboards)
            if strcmp(kboards{1, i}.product, 'Mitsumi Electric Apple Extended USB Keyboard')
                devIdx(1) = kboards{1, i}.index;
            end
        end

        parameters.space_key = '1';
        parameters.exit_key = '2';
    
    %% Undetected device
    else
        disp('Running on unknown device. Psychtoolbox might not be added correctly!')
    end
    
    %% Initialize peripherals %%
    % Initialize keyboard
    if ~isempty(devIdx(1))
        kbx = devIdx(1);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
    else
        error('External Keyboard not found')
    end
        
    % create keyboard and mouse events queue
    KbQueueCreate(kbx);
end