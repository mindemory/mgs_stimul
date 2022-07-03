function parameters = initFiles(parameters, screen, data_path, kbx, block)
% Create all necessary directiries (a directory for each subject, containg Results and TaskMaps)
%--------------------------------------------------------------------------------------------------------------------------------------%
% specify the directories to be used
block_dir = [data_path '/block' num2str(block, "%02d")];

%% Create directories and sub-directories
if exist(data_path,'dir')~=7 %if the "subNum" directory doesn't exist, create one
    mkdir(data_path);
end

if exist(block_dir, 'dir')==7
    KbQueueStart(kbx);
    [~, keyCode]=KbQueueCheck(kbx);
    cmndKey = KbName(keyCode);
    while ~strcmp(cmndKey, parameters.space_key)
        showprompts(screen, 'BlockExists', block)
         [~, keyCode]=KbQueueCheck(kbx);
        cmndKey = KbName(keyCode);
        if strcmp(cmndKey, parameters.exit_key)
            sca;
            break;
        end
    end
else
    mkdir(block_dir);
end

%% Initialize the files to write in
date_time = datestr(now, 'mmddyy_HHMM');
edfFile = [parameters.subject parameters.block date_time(1:4)];
eegFile = ['subj' parameters.subject '_block' parameters.block '_' date_time '.edf'];
matFile = ['subj' parameters.subject '_block' parameters.block '.mat'];

parameters.block_dir = block_dir;
parameters.edfFile = edfFile;
parameters.eegFile = eegFile;
parameters.matFile = matFile;
end