function taskMap = generateTaskMap(Stim,coilLocInd)
    global parameters screen;

    % coilHemField --> 1: Right visual filed , 2: Left visual field
    % conditions: 1: Pulse/In , 2: Pulse/Out , 3: sham/In , 4: sham/Out
    % listing = dir([pwd,'/SubjectData/',['sub' num2str(parameters.subject)],'/',[ 'sess' num2str(parameters.session)],'/TaskMaps' ,'/*.mat']);

    trial.stimLoc = Stim{coilLocInd}.pdfCoords;
    trial.coilHem = Stim{coilLocInd}.coilHemField;
    %trial.coilLoc = coilLocInd;
    
    % stimulus inside the tms FOV / TMS
    inds = randi(length(trial.stimLoc),[parameters.numTrials.In 1]);
    stimLocSet_In = trial.stimLoc(inds,:);
    coilHem_In = repmat(trial.coilHem,[parameters.numTrials.In 1]);
    coilLoc_In = repmat(coilLocInd,[parameters.numTrials.In 1]);
    delay1_In = repmat(parameters.delay1Duration,[parameters.numTrials.In 1]);
    pulseDuration_In = repmat(parameters.Pulse.Duration,[parameters.numTrials.In 1]);
    delay2_In = Shuffle(repmat(parameters.delay2Duration,[1 parameters.numTrials.In/length(parameters.delay2Duration)])');
    iti_In = Shuffle(repmat(parameters.itiDuration,[1 parameters.numTrials.In/length(parameters.itiDuration)])');
    cond_In = 1*ones(length(inds),1);

    % stimulus outside the tms FOV / TMS
    stimLocSet_Out(:,1) = screen.screenXpixels - stimLocSet_In(:,1); % mirror vertically
    stimLocSet_Out(:,2) = stimLocSet_In(:,2);
    coilHem_Out = repmat(trial.coilHem,[parameters.numTrials.Out 1]);
    coilLoc_Out = repmat(coilLocInd,[parameters.numTrials.Out 1]);
    delay1_Out = repmat(parameters.delay1Duration,[parameters.numTrials.Out 1]);
    pulseDuration_Out = repmat(parameters.Pulse.Duration,[parameters.numTrials.Out 1]);
    delay2_Out = Shuffle(repmat(parameters.delay2Duration,[1 parameters.numTrials.Out/length(parameters.delay2Duration)])');
    iti_Out = Shuffle(repmat(parameters.itiDuration,[1 parameters.numTrials.Out/length(parameters.itiDuration)]))';
    cond_Out = 2*ones(length(inds),1);

    % concat all conditions
    stimLocSet_pix = [stimLocSet_In ; stimLocSet_Out];
    [stimLocSet_va_ecc,stimLocSet_va_theta] = pixel2va(screen,stimLocSet_pix(:,1),stimLocSet_pix(:,2),'cntr');

    if strcmp(parameters.task,'pro')
        saccLocSet_pix = stimLocSet_pix;
    elseif strcmp(parameters.task,'anti')
        saccLocSet_pix(:,1) = screen.screenXpixels - stimLocSet_pix(:,1);
        saccLocSet_pix(:,2) = stimLocSet_pix(:,2);
    end
    [saccLocSet_va_ecc,saccLocSet_va_theta] = pixel2va(screen,saccLocSet_pix(:,1),saccLocSet_pix(:,2),'cntr');

    coilHem = [coilHem_In ; coilHem_Out];
    coilLocInd_all = [coilLoc_In ; coilLoc_Out];
    delay1 = [delay1_In ; delay1_Out];
    pulseDuration = [pulseDuration_In ; pulseDuration_Out];
    delay2 = [delay2_In ; delay2_Out];
    ITI = [iti_In ; iti_Out];
    conditions = [cond_In ; cond_Out];

    % Set taskMap
    trialInds = randperm(size(stimLocSet_pix,1));

    taskMap.condition = conditions(trialInds);
    taskMap.stimLoc_pix = stimLocSet_pix(trialInds,:);
    taskMap.saccLoc_pix = saccLocSet_pix(trialInds,:);
    taskMap.stimLoc_va = [stimLocSet_va_ecc(trialInds) stimLocSet_va_theta(trialInds)];
    taskMap.saccLoc_va = [saccLocSet_va_ecc(trialInds) saccLocSet_va_theta(trialInds)];
    taskMap.coilHemifield = coilHem(trialInds);
    taskMap.coilLocInd = coilLocInd_all(trialInds);
    taskMap.delay1 = delay1(trialInds);
    taskMap.pulseDuration = pulseDuration(trialInds);
    taskMap.delay2 = delay2(trialInds);
    taskMap.ITI = ITI(trialInds);

    taskMap.trialNum = length(stimLocSet_pix);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    save(parameters.taskMapFile, 'taskMap');
    % writetable(struct2table(taskMap),'taskMapWM.csv');
end