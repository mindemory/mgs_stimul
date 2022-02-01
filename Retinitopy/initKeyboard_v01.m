function initKeyboard_v01()
    global kbx mbx tmsDaq;
%     LoadPsychHID; %ry to get PsychHID linked and loaded on MS-Windows, no matter what.

    %   Enable unified mode of KbName, so KbName accepts identical key names on
    %   all operating systems:
    KbName('UnifyKeyNames');
    
    %   get keyboard pointer   
    devices = PsychHID('Devices');
    devIdx(1) = find([devices(:).usageValue] == 6);
    tmp = find([devices(:).usageValue] == 2); % if more than one mouse
    devIdx(2) = tmp(1);
    tmp = [];
    for i = 1:length(devices) % if more than one daq port availbale
        p =  devices(i).product;
        if strcmp(p,'USB-1208FS')
            tmp = [tmp i];
        end
    end
    devIdx(3) = tmp(1);

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

    tmsDaq = devIdx(3);
end