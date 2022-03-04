function initKeyboard()

% First try running LoadPsychHID on Ubuntu and see if that works
global kbx mbx hostname
%     LoadPsychHID; %ry to get PsychHID linked and loaded on MS-Windows, no matter what.

%   Enable unified mode of KbName, so KbName accepts identical key names on
%   all operating systems:
KbName('UnifyKeyNames');
%TeensyTrigger('i', '/dev/cu.usbmodem12341')
%   get keyboard pointer
if strcmp(hostname, 'syndrome')
    devices = PsychHID('Devices');
    %devices_mouse = PsychHID('Devices');
    devIdx(1) = find([devices(:).usageValue] == 6);
    devIdx(2) = find([devices(:).usageValue] == 2);

    %  Initialize keyboard
    if ~isempty(devIdx(1))
        kbx = devIdx(1);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
    else
        kbx = 0;
    end

    %  Initialize mouse
    if ~isempty(devIdx(2))
        mbx = devIdx(2);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
    else
        mbx = 0;
    end

elseif strcmp(hostname, 'tmsstim.cbi.fas.nyu.edu')
    disp("Never worked on this!")
elseif strcmp(hostname, 'tmsubuntu')
    devices_keyboard = PsychHID('Devices', 4);
    devices_mouse = PsychHID('Devices', 3);
    devIdx(1) = find(strcmp({devices_keyboard(:).product},'Mitsumi Electric Apple Extended USB Keyboard System Control') == 1);
    devIdx(2) = find(strcmp({devices_mouse(:).product},'PixArt Dell MS116 USB Optical Mouse') == 1);

    %  Initialize keyboard
    if ~isempty(devIdx(1))
        kbx = devIdx(1);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
    else
        kbx = 0;
    end

    %  Initialize mouse
    if ~isempty(devIdx(2))
        mbx = devIdx(2);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
    else
        mbx = 0;
    end

else
    disp('Running on unknown device. Psychtoolbox might not be added correctly!')
end


%   create keyboard events queue
KbQueueCreate(kbx);
KbQueueCreate(mbx);
end