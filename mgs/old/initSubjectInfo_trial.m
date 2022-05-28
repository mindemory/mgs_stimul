%% mrugank (01/31/2022): Created to not enter subject details at each run.
%% Only for debugging purposes.
function initSubjectInfo_trial()
    global parameters;

    currentStudy = parameters.currentStudy;
    currentStudyVersion = parameters.currentStudyVersion;

    % Why double do it? mrugank: 02 15 2022
    subNum = 01; %input('Please type subject number: ');
    session = 01; %input('Please type session number: ');
    run = 01; %input('Please type run number: ');
    task = 'pro'; %input('Please type task[pro/anti]: ','s');
    coilLocInd = 01; %input('Please type coil location index: ');

    parameters.subject = subNum;
    parameters.session = session;
    parameters.run = run;
    parameters.task = task;
    parameters.coilLocInd = coilLocInd;

%     % check if the inserted coil location has been already tested or not
%     listing = dir([pwd,'/SubjectData/',['sub' int2strz(parameters.subject,2)],'/',[ 'sess' int2strz(parameters.session,2)],'/', task ,'/TaskMaps' ,'/*.mat']);
%     while 1
%         repCoilLoc = nan;
%         i = 1;
%         while i < length(listing)+1
%             if strfind(listing(i).name,['coilLoc' int2strz(parameters.coilLocInd,2)])
%                 display(sprintf('\n%s',['Coil location index: '  int2strz(parameters.coilLocInd,2)]));
%                 display(sprintf('\n%s','You already have tested this coil location!'));
%                 repCoilLoc = input(sprintf('\n\t%s',['Repeate coil location ' int2strz(parameters.coilLocInd,2) '?[y/n] : ']),'s');
%                 break
%             end
%             i = i+1;
%         end
%         if isnan(repCoilLoc)
%             break;
%         end
%         if strcmp(repCoilLoc,'n') % mrugank (02/15/2022): can it be elif instead?
%             coilLocInd = input(sprintf('\n\t%s','Please type new coil location index: '),'s');
%             parameters.coilLocInd = str2num(coilLocInd);
%         else
%             break
%         end
%     end
    
    % Create all necessary directories (a directory for each subject, containg Results and TaskMaps)
    %--------------------------------------------------------------------------------------------------------------------------------------%
    % specify the directories to be used
    CWD = [pwd '/']; %current working dir
    ALL_SUB = [CWD 'SubjectData/' ]; % create "SubjectData" dir that will contain all the data for all subjects
    SUB_DIR = [ALL_SUB 'sub' int2strz(parameters.subject,2) '/' 'sess' int2strz(parameters.session,2) '/' task '/']; % create a "SubNum" dir inside the "SubjectData" dir
    TASK_MAPS = [SUB_DIR 'TaskMaps/'];  % create a "TaskMaps" dir inside the "SubNum" dir
    RESULTS_DIR = [SUB_DIR 'Results/']; % create a "Results" dir inside the "SubNum" dir
    EYE_DIR = [SUB_DIR 'EyeData/']; % create a "EyeData" dir inside the "SubNum" dir
    createDirectories(subNum, ALL_SUB, SUB_DIR, RESULTS_DIR, TASK_MAPS, EYE_DIR);

    parameters.subjectDIR = SUB_DIR;
end