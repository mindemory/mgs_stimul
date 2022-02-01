function reInitSubjectInfo(currentRun, runVersion)

    global parameters;

    currentStudy = parameters.currentStudy;
    currentStudyVersion = parameters.currentStudyVersion;
    subNum = parameters.subject;
    
    % Create all necessary directiries (a directory for each subject, containg Results and TaskMaps)
    %--------------------------------------------------------------------------------------------------------------------------------------%
    % specify the directories to be used
    CWD = [pwd '/']; %current working dir
    ALL_SUB = [CWD 'SubjectData/']; % create "SubjectData" dir that will contain all the data for all subjects
    SUB_DIR = [ALL_SUB 'sub' int2strz(parameters.subject,2) '/' 'sess' int2strz(parameters.session,2) '/' parameters.task '/']; % create a "SubNum" dir inside the "SubjectData" dir
    TASK_MAPS = [SUB_DIR 'TaskMaps/'];  % create a "TaskMaps" dir inside the "SubNum" dir
    RUN_TASK_MAPS = [SUB_DIR 'RunTaskMaps/'];  % create a "TaskMaps" dir inside the "SubNum" dir
    RESULTS_DIR = [SUB_DIR 'Results/']; % create a "Results" dir inside the "SubNum" dir
    EYE_DIR = [SUB_DIR 'EyeData/']; % create a "EyeData" dir inside the "SubNum" dir
    
    createDirectories(subNum, ALL_SUB,SUB_DIR,RESULTS_DIR,TASK_MAPS,EYE_DIR);
    
    % Initialize the files to write in
    %--------------------------------------------------------------------------------------------------------------------------------------%
    %specify naming format for the data file
    currentDateVector = clock;
    currentYear = currentDateVector(1)-2000;
    currentMonth =currentDateVector(2);
    currentDay = currentDateVector(3);
    currentHour = currentDateVector(4);
    currentMin = currentDateVector(5);
    
    dateStr = [num2str(currentYear) int2strz(currentMonth,2) int2strz(currentDay,2)]; 
    timestamp= [num2str(currentHour) int2strz(currentMin,2)]; 

	subNumStr=int2strz(subNum,2);
    sessionNumStr = int2strz(parameters.session,2);
	runNumberStr = int2strz(currentRun,2);
    task = parameters.task;
    runVersionStr = int2strz(runVersion,2);

    datafile = [RESULTS_DIR currentStudy num2str(currentStudyVersion) subNumStr  sessionNumStr '_' runNumberStr '_' task '_' runVersionStr '_' dateStr '_' timestamp '.csv'];
    matfile = [RESULTS_DIR currentStudy num2str(currentStudyVersion) subNumStr  sessionNumStr '_' runNumberStr '_' task '_' runVersionStr '_' dateStr '_' timestamp '.mat']; 
  
    parameters.datafile = datafile;
    parameters.matfile = matfile;

end