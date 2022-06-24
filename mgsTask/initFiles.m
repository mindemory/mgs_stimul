function initFiles(data_path)
    global parameters

    % Create all necessary directiries (a directory for each subject, containg Results and TaskMaps)
    %--------------------------------------------------------------------------------------------------------------------------------------%
    % specify the directories to be used
    RESULTS_DIR = [data_path filesep 'Results/']; % create a "Results" dir inside the "SubNum" dir
    EYE_DIR = [data_path filesep 'EyeData/']; % create a "EyeData" dir inside the "SubNum" dir
    EEG_DIR = [data_path filesep 'EEGData/'];
    
    %% Create directories and sub-directories
    if exist(data_path,'dir')~=7 %if the "subNum" directory doesn't exist, create one
        mkdir(data_path);
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
    date_time = datestr(now, 'mm_dd_yy_HH_MM_SS');
    %edfFile = [parameters.subject parameters.session '.edf'];% can only be 4 characters long
    edfFile = [EYE_DIR parameters.subject '_' parameters.block '.edf'];
    eegFile = [EEG_DIR parameters.subject '_' parameters.block '.edf'];
    datafile = [RESULTS_DIR parameters.currentStudy  '_' ...
        parameters.currentStudyVersion '_' parameters.subject ...
        '_' parameters.block '_' date_time '.csv'];
    matfile = [RESULTS_DIR parameters.currentStudy '_' ...
        parameters.currentStudyVersion '_' parameters.subject ...
        '_' parameters.block '_' date_time '.mat']; 
  
    parameters.edfFile = edfFile;
    parameters.eegFile = eegFile;
    parameters.datafile = datafile;
    parameters.matfile = matfile;
end