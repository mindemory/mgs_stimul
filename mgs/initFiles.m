function initFiles(data_path)
    global parameters

    % Create all necessary directiries (a directory for each subject, containg Results and TaskMaps)
    %--------------------------------------------------------------------------------------------------------------------------------------%
    % specify the directories to be used
    TASK_MAPS_DIR = [data_path filesep 'TaskMaps/'];  % create a "TaskMaps" dir inside the "SubNum" dir
    RESULTS_DIR = [data_path filesep 'Results/']; % create a "Results" dir inside the "SubNum" dir
    EYE_DIR = [data_path filesep 'EyeData/']; % create a "EyeData" dir inside the "SubNum" dir
    
    %% Create directories and sub-directories
    if exist(data_path,'dir')~=7 %if the "subNum" directory doesn't exist, create one
        mkdir(data_path);
    end
    if exist(RESULTS_DIR,'dir')~=7 %if the "Results" directory doesn't exist, create one
        mkdir(RESULTS_DIR);
        fprintf('making new results directory for subject')
    end
    if exist(TASK_MAPS_DIR,'dir')~=7 %if the "TaskMaps" directory doesn't exist, create one
        mkdir(TASK_MAPS_DIR);
        fprintf('making new task map directory for subject')
    end
    if exist(EYE_DIR,'dir')~=7 %if the "TaskMaps" directory doesn't exist, create one
        mkdir(EYE_DIR);
        fprintf('making new log file directory for subject')
    end
    
    parameters.subjectDIR = data_path;
    
    %% Initialize the files to write in
    date_time = datestr(now, 'mm_dd_yy_HH_MM_SS');
    
    taskMapFile = [TASK_MAPS_DIR parameters.currentStudy '_' ...
        parameters.currentStudyVersion '_sub' parameters.subject ...
        '_sess' parameters.session '_' parameters.task '_coilLoc'...
        num2str(parameters.coilLocInd, '%02d') '_' ...
        date_time '_taskMap.mat'];
    %edfFile = [parameters.subject parameters.session '.edf'];% can only be 4 characters long
    edfFile = [EYE_DIR parameters.subject '_' parameters.session '_' ...
        num2str(parameters.runNumber, '%02d') '_' ...
        num2str(parameters.runVersion, '%02d') '_' parameters.task '.edf'];
    datafile = [RESULTS_DIR parameters.currentStudy  '_' ...
        parameters.currentStudyVersion '_' parameters.subject ...
        '_' parameters.session '_' num2str(parameters.runNumber, '%02d')...
        '_' parameters.task '_' num2str(parameters.runVersion, '%02d') ...
        '_' date_time '.csv'];
    matfile = [RESULTS_DIR parameters.currentStudy '_' ...
        parameters.currentStudyVersion '_' parameters.subject ...
        '_' parameters.session '_' num2str(parameters.runNumber, '%02d')...
        '_' parameters.task '_' num2str(parameters.runVersion, '%02d') ...
        '_' date_time '.mat']; 
  
    parameters.taskMapFile = taskMapFile;
    parameters.edfFile = edfFile;

    parameters.datafile = datafile;
    parameters.matfile = matfile;
end