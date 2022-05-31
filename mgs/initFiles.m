function initFiles()
    global parameters

    % Create all necessary directiries (a directory for each subject, containg Results and TaskMaps)
    %--------------------------------------------------------------------------------------------------------------------------------------%
    % specify the directories to be used
    CWD = [pwd '/']; %current working dir
    ALL_SUB_DIR = [CWD 'SubjectData/' ]; % create "SubjectData" dir that will contain all the data for all subjects
    SUB_DIR = [ALL_SUB_DIR 'sub' parameters.subject '/' 'sess' ...
        parameters.session '/' parameters.task '/']; % create a "SubNum" dir inside the "SubjectData" dir
    TASK_MAPS_DIR = [SUB_DIR 'TaskMaps/'];  % create a "TaskMaps" dir inside the "SubNum" dir
    RESULTS_DIR = [SUB_DIR 'Results/']; % create a "Results" dir inside the "SubNum" dir
    EYE_DIR = [SUB_DIR 'EyeData/']; % create a "EyeData" dir inside the "SubNum" dir

    createDirectories(parameters.subject,ALL_SUB_DIR,SUB_DIR,RESULTS_DIR,TASK_MAPS_DIR,EYE_DIR);
    parameters.subjectDIR = SUB_DIR;
    % Initialize the files to write in
    %--------------------------------------------------------------------------------------------------------------------------------------%
    %specify naming format for the data file
    currentDateVector = clock;
    currentYear = currentDateVector(1);%-2000;
    currentMonth = currentDateVector(2);
    currentDay = currentDateVector(3);
    currentHour = currentDateVector(4);
    currentMin = currentDateVector(5);

    dateStr = [num2str(currentYear) num2str(currentMonth, '%02d') num2str(currentDay,'%02d')];
    timestamp = [num2str(currentHour, '%02d') num2str(currentMin,'%02d')];

    %subNumStr = parameters.subject;
    %task = parameters.task;
    %coilLocStr = parameters.coilLocInd; 
    %sessionNumStr = parameters.session;
    taskMapFile = [TASK_MAPS_DIR parameters.currentStudy '_' ...
        parameters.currentStudyVersion '_sub' parameters.subject ...
        '_sess' parameters.session '_' parameters.task '_coilLoc'...
        num2str(parameters.coilLocInd, '%02d') '_' ...
        dateStr '_' timestamp '_taskMap.mat'];
    %edfFile = [parameters.subject parameters.session '.edf'];% can only be 4 characters long
    edfFile = [EYE_DIR parameters.subject '_' parameters.session '_' ...
        num2str(parameters.runNumber, '%02d') '_' ...
        num2str(parameters.runVersion, '%02d') '_' parameters.task '.edf'];
    datafile = [RESULTS_DIR parameters.currentStudy  '_' ...
        parameters.currentStudyVersion '_' parameters.subject ...
        '_' parameters.session '_' num2str(parameters.runNumber, '%02d')...
        '_' parameters.task '_' num2str(parameters.runVersion, '%02d') ...
        '_' dateStr '_' timestamp '.csv'];
    matfile = [RESULTS_DIR parameters.currentStudy '_' ...
        parameters.currentStudyVersion '_' parameters.subject ...
        '_' parameters.session '_' num2str(parameters.runNumber, '%02d')...
        '_' parameters.task '_' num2str(parameters.runVersion, '%02d') ...
        '_' dateStr '_' timestamp '.mat']; 
  
    parameters.taskMapFile = taskMapFile;
    parameters.edfFile = edfFile;

    parameters.datafile = datafile;
    parameters.matfile = matfile;
end