KbName('UnifyKeyNames');

%   get keyboard pointer
devices = PsychHID('Devices');
devIdx = find([devices(:).usageValue] == 6);
%  Initialize keyboard
if ~isempty(devIdx)
    kbx = devIdx(1);% MODIFY ACCORDING YOUR COMPUTER SETUP!!!
else
    kbx = 0;
end

%   create keyboard events queue
PsychHID('KbQueueCreate',kbx);
PsychHID('KbQueueStart',kbx);

% while 1
%     [keyIsDown, keyCode ]=PsychHID('KbQueueCheck' ,kbx);
%     if keyIsDown
%         keyName = KbName(keyCode);
%         if strcmp(keyName,'g')
%             display('ready for pulse')
%             break
%         end
%     end
%     
% end
% display('pulse sent')

for tc = 1:20
    display(['tc  ' num2str(tc) '  began' ]);
    PsychHID('KbQueueStart',kbx);
    [keyIsDown, keyCode ]=PsychHID('KbQueueCheck' ,kbx);
    cmndKey = KbName(keyCode);
    if strcmp(cmndKey,'`~')
        cmndKey = nan;
        display('Press backTick to resume')
        PsychHID('KbQueueStart',kbx);
        while ~strcmp(cmndKey,'`~')
            [keyIsDown, keyCode ]=PsychHID('KbQueueCheck' ,kbx);
            cmndKey = KbName(keyCode);
        end
        
    else
        display('waiting ...')
        pause(2);
        display(['tc  ' num2str(tc) '  done' ]);        
        display('----------------------');
    end
end

