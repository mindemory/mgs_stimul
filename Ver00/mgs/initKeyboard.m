function initKeyboard()
    global kbx mbx;
%     LoadPsychHID; %ry to get PsychHID linked and loaded on MS-Windows, no matter what.

    %   Enable unified mode of KbName, so KbName accepts identical key names on
    %   all operating systems:
    KbName('UnifyKeyNames');
    
    %   get keyboard pointer   
    devices = PsychHID('Devices');
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
    
     %   create keyboard events queue
    KbQueueCreate(kbx);
    KbQueueCreate(mbx);
%     KbQueueStart(kbx);
%     KbQueueStart(mbx);
end