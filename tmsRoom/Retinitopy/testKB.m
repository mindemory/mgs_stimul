%% Edits by Mrugank (01/29/2022)
% Suppressed VBL Sync Error by PTB, added sca, clear; close all;

%% Check the system name to ensure correct paths are added.
[ret, hostname] = system('hostname');   
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

%% Load PTB and toolboxes
if strcmp(hostname, 'syndrome')
    % Location of PTB on Syndrome
    addpath(genpath('/Users/Shared/Psychtoolbox')) %% mrugank (01/28/2022): load PTB
elseif strcmp(hostname, 'tmsstim.cbi.fas.nyu.edu')
    % Location of toolboxes on TMS Stimul Mac
    addpath(genpath('/Users/curtislab/TMS_Priority/exp_materials/'))
    rmpath(genpath('/Users/curtislab/matlab/mgl'));
    addpath(genpath('/Users/curtislab/Documents/MATLAB/mgl2'));
end

sca; clear; close all; clc;
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

