function initKeyboard()

% First try running LoadPsychHID on Ubuntu and see if that works
global kbx mbx
%     LoadPsychHID; %ry to get PsychHID linked and loaded on MS-Windows, no matter what.

%   Enable unified mode of KbName, so KbName accepts identical key names on
%   all operating systems:
KbName('UnifyKeyNames');
%TeensyTrigger('i', '/dev/cu.usbmodem12341')
%   get keyboard pointer
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

%   create keyboard events queue
KbQueueCreate(kbx);
KbQueueCreate(mbx);
end