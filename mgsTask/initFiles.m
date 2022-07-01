function parameters = initFiles(parameters, screen, data_path, kbx, block)
    % Create all necessary directiries (a directory for each subject, containg Results and TaskMaps)
    %--------------------------------------------------------------------------------------------------------------------------------------%
    % specify the directories to be used
    BLOCK_DIR = [data_path '/block' num2str(block, "%02d")];
    
    %% Create directories and sub-directories
    if exist(data_path,'dir')~=7 %if the "subNum" directory doesn't exist, create one
        mkdir(data_path);
    end
    
    if exist(BLOCK_DIR,'dir')==7
        KbQueueFlush(kbx);
        [keyIsDown, ~] = KbQueueCheck(kbx);
        while ~keyIsDown
            showprompts(screen, 'BlockExists', block);
            [keyIsDown, keyCode] = KbQueueCheck(kbx);
            cmndKey = KbName(keyCode)
        end
        while 1
            if strcmp(cmndKey, parameters.space_key)
                continue;
            elseif strcmp(cmndKey, parameters.exit_key)
                return;
            end
            break;
        end
    else
        mkdir(BLOCK_DIR);
    end
    if exist(BLOCK_DIR,'dir')~=7 %if the "Results" directory doesn't exist, create one
        mkdir(BLOCK_DIR);
    end
    
    %% Initialize the files to write in
    date_time = datestr(now, 'mmddyy_HHMM');
    edfFile = [BLOCK_DIR '/subj' parameters.subject '_block' parameters.block '_' date_time '.edf'];
    eegFile = [BLOCK_DIR '/subj' parameters.subject '_block' parameters.block '_' date_time '.edf'];
    datafile = [BLOCK_DIR '/subj' parameters.subject '_block' parameters.block '_' date_time '.csv'];
    matFile = [BLOCK_DIR '/subj' parameters.subject '_block' parameters.block '.mat'];
  
    parameters.edfFile = edfFile;
    parameters.eegFile = eegFile;
    parameters.datafile = datafile;
    parameters.matFile = matFile;
end