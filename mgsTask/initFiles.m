function parameters = initFiles(parameters, screen, data_path, kbx, block)
    % Create all necessary directiries (a directory for each subject, containg Results and TaskMaps)
    %--------------------------------------------------------------------------------------------------------------------------------------%
    % specify the directories to be used
    BLOCK_DIR = [data_path filesep 'block' num2str(block, "%02d")];
    RESULTS_DIR = [BLOCK_DIR filesep 'Results/']; % create a "Results" dir inside the "SubNum" dir
    EYE_DIR = [BLOCK_DIR filesep 'EyeData/']; % create a "EyeData" dir inside the "SubNum" dir
    EEG_DIR = [BLOCK_DIR filesep 'EEGData/'];
    
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
    if exist(RESULTS_DIR,'dir')~=7 %if the "Results" directory doesn't exist, create one
        mkdir(RESULTS_DIR);
    end
    if exist(EYE_DIR,'dir')~=7 %if the "EyeData" directory doesn't exist, create one
        mkdir(EYE_DIR);
    end
    if exist(EEG_DIR,'dir')~=7 %if the "EEGData" directory doesn't exist, create one
        mkdir(EEG_DIR);
    end
    
    %% Initialize the files to write in
    date_time = datestr(now, 'mmddyy_HHMM');
    edfFile = [EYE_DIR 'subj' parameters.subject '_block' parameters.block '_' date_time '.edf'];
    eegFile = [EEG_DIR 'subj' parameters.subject '_block' parameters.block '_' date_time '.edf'];
    datafile = [RESULTS_DIR 'subj' parameters.subject '_block' parameters.block '_' date_time '.csv'];
    matFile = [RESULTS_DIR 'subj' parameters.subject '_block' parameters.block '.mat'];
  
    parameters.edfFile = edfFile;
    parameters.eegFile = eegFile;
    parameters.datafile = datafile;
    parameters.matFile = matFile;
end