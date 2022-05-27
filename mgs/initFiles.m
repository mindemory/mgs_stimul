function initFiles()
    global parameters

    % Create all necessary directiries (a directory for each subject, containg Results and TaskMaps)
    %--------------------------------------------------------------------------------------------------------------------------------------%
    % specify the directories to be used
    CWD = [pwd '/']; %current working dir
    ALL_SUB = [CWD 'SubjectData/' ]; % create "SubjectData" dir that will contain all the data for all subjects
    SUB_DIR = [ALL_SUB 'sub' parameters.subject '/' 'sess' parameters.session '/' parameters.task '/']; % create a "SubNum" dir inside the "SubjectData" dir
    TASK_MAPS = [SUB_DIR 'TaskMaps/'];  % create a "TaskMaps" dir inside the "SubNum" dir
    RESULTS_DIR = [SUB_DIR 'Results/']; % create a "Results" dir inside the "SubNum" dir
    EYE_DIR = [SUB_DIR 'EyeData/']; % create a "EyeData" dir inside the "SubNum" dir

    createDirectories(parameters.subject, ALL_SUB,SUB_DIR,RESULTS_DIR,TASK_MAPS,EYE_DIR);
    parameters.subjectDIR = SUB_DIR;
    % Initialize the files to write in
    %--------------------------------------------------------------------------------------------------------------------------------------%
    %specify naming format for the data file
    currentDateVector = clock;
    currentYear = currentDateVector(1)-2000;
    currentMonth = currentDateVector(2);
    currentDay = currentDateVector(3);
    currentHour = currentDateVector(4);
    currentMin = currentDateVector(5);

    dateStr = [num2str(currentYear) num2str(currentMonth, '%02d') num2str(currentDay,'%02d')];
    timestamp = [num2str(currentHour) num2str(currentMin,'%02d')];

    subNumStr = parameters.subject;
    task = parameters.task;
    coilLocStr = parameters.coilLocInd; 
    sessionNumStr = parameters.session;
    taskMapFile = [TASK_MAPS parameters.currentStudy parameters.currentStudyVersion...
        '_sub' subNumStr '_sess' sessionNumStr '_' task '_coilLoc'...
        coilLocStr '_' dateStr '_' timestamp '_taskMap.mat'];
    edfFile = [subNumStr  sessionNumStr '.edf'];% can only be 4 characters long

    parameters.taskMapFile = taskMapFile;
    parameters.edfFile = edfFile;
end