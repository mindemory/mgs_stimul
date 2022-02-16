function [runVersion, startCurrentRunSession, currentRun, runRepeated] = enterRunToStart(allRuns, currentRun, runVersion)
    global parameters;
    global task;
    
    runRepeated = 0;
    listing = dir([pwd,'/SubjectData/',num2str(parameters.subject), '/Results' ,'/*.mat']); 
    runsArray = [];
    runVersionsArray = [];
    if ~isempty(listing)
        for k = 1:size(listing,1)
            C = strsplit(listing(k,:).name,'_');
            runsArray =[runsArray, str2num(C{2})];
            runVersionsArray = [runVersionsArray, str2num(C{3})];
        end
    end
    
    runIdx = find(runsArray==currentRun);
    if ~isempty(runIdx)
        runVersionIdx = find(runVersionsArray(runIdx) == runVersion);
 
        startCurrentRunSession=input(['You were already running run # ', num2str(currentRun),'  ',num2str(length(runVersionsArray(runIdx))), ' times. Please enter 1 if you want to run it once more, 0 otherwise: ']);

        while (startCurrentRunSession~=1 && startCurrentRunSession~=0)
            startCurrentRunSession=input(['Invalid input. Please enter 1 if you want to run it once more, 0 otherwise: ']);
        end

        if startCurrentRunSession == 0
            currentRun = uint8(input('Please enter the run number : '));
            while (currentRun<1 || currentRun>parameters.numberOfRuns)
                currentRun = input('Invalid input. Please enter the run number: ');
            end
            [runVersion,startCurrentRunSession,currentRun] = enterRunToStart(allRuns,currentRun,runVersion);
             runVersion = max(runVersionsArray(runIdx))+1;
        else
            runVersion = max(runVersionsArray(runIdx))+1;
            runRepeated = 1;
        end

    else
        runVersion = allRuns(currentRun);
        startCurrentRunSession = 1;
        runRepeated = 0;
    end

end