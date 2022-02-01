% Questions: 1- intermix conditions or not?

function taskMap = generateTaskMap(Stim,tmsRtnTpy,coilLocInd)
global parameters;
global screen;

% coilHemField --> 1: Right visual filed , 2: Left visual field
% conditions: 1: Pulse/In , 2: Pulse/Out , 3: sham/In , 4: sham/Out

screen = tmsRtnTpy.Params.screen;

% listing = dir([pwd,'/SubjectData/',['sub' num2str(parameters.subject)],'/',[ 'sess' num2str(parameters.session)],'/TaskMaps' ,'/*.mat']);


trial.stimLoc = Stim{coilLocInd}.pdfCoords;
trial.coilHem = Stim{coilLocInd}.coilHemField;
trial.coilLoc = coilLocInd;
% stimulus inside the tms FOV / TMS
inds = randi(length(trial.stimLoc),[parameters.numTrials.In 1]);
stimLocSet_In = trial.stimLoc(inds,:);
coilHem_In = repmat(trial.coilHem,[parameters.numTrials.In 1]);
coilLoc_In = repmat(trial.coilLoc,[parameters.numTrials.In 1]);
delay1_In = repmat(parameters.delay1Duration,[parameters.numTrials.In 1]);
pulseDuration_In = repmat(parameters.Pulse.Duration,[parameters.numTrials.In 1]);
delay2_In = Shuffle(repmat(parameters.delay2Duration,[1 parameters.numTrials.In/length(parameters.delay2Duration)])');
iti_In = Shuffle(repmat(parameters.itiDuration,[1 parameters.numTrials.In/length(parameters.itiDuration)])');
cond_In = 1*ones(length(inds),1);

% stimulus outside the tms FOV / TMS
%     inds = randi(length(trial.stimLoc),[parameters.numTrials.Out 1]);
stimLocSet_Out(:,1) = screen.screenXpixels - stimLocSet_In(:,1); % mirror vertically
stimLocSet_Out(:,2) = stimLocSet_In(:,2);
coilHem_Out = repmat(trial.coilHem,[parameters.numTrials.Out 1]);
coilLoc_Out = repmat(trial.coilLoc,[parameters.numTrials.Out 1]);
delay1_Out = repmat(parameters.delay1Duration,[parameters.numTrials.Out 1]);
pulseDuration_Out = repmat(parameters.Pulse.Duration,[parameters.numTrials.Out 1]);
delay2_Out = Shuffle(repmat(parameters.delay2Duration,[1 parameters.numTrials.Out/length(parameters.delay2Duration)])');
iti_Out = Shuffle(repmat(parameters.itiDuration,[1 parameters.numTrials.Out/length(parameters.itiDuration)]))';
cond_Out = 2*ones(length(inds),1);

% stimulus inside the tms FOV / sham
inds = randi(length(trial.stimLoc),[parameters.numTrials.shamIn 1]);
stimLocSet_shamIn = trial.stimLoc(inds,:);
coilHem_shamIn = repmat(trial.coilHem,[parameters.numTrials.shamIn 1]);
coilLoc_shamIn = repmat(trial.coilLoc,[parameters.numTrials.shamIn 1]);
delay1_shamIn = repmat(parameters.delay1Duration,[parameters.numTrials.shamIn 1]);
pulseDuration_shamIn = repmat(parameters.Pulse.Duration,[parameters.numTrials.shamIn 1]);
delay2_shamIn = repmat(parameters.delay2Duration,[1 parameters.numTrials.shamIn])';
delay2_shamIn = Shuffle(delay2_shamIn(1:parameters.numTrials.shamIn));
iti_shamIn = repmat(parameters.itiDuration,[1 parameters.numTrials.shamIn])';
iti_shamIn = Shuffle(iti_shamIn(1:parameters.numTrials.shamIn));
cond_shamIn = 3*ones(length(inds),1);

% stimulus outside the tms FOV / sham
inds = randi(length(trial.stimLoc),[parameters.numTrials.shamOut 1]);
stimLocSet_shamOut = trial.stimLoc(inds,:);
stimLocSet_shamOut(:,1) = screen.screenXpixels - stimLocSet_shamOut(:,1); % mirror vertically
coilHem_shamOut = repmat(trial.coilHem,[parameters.numTrials.shamOut 1]);
coilLoc_shamOut = repmat(trial.coilLoc,[parameters.numTrials.shamOut 1]);
delay1_shamOut = repmat(parameters.delay1Duration,[parameters.numTrials.shamOut 1]);
pulseDuration_shamOut = repmat(parameters.Pulse.Duration,[parameters.numTrials.shamOut 1]);
delay2_shamOut = repmat(parameters.delay2Duration,[1 parameters.numTrials.shamOut])';
delay2_shamOut = Shuffle(delay2_shamOut(1:parameters.numTrials.shamOut));
iti_shamOut = repmat(parameters.itiDuration,[1 parameters.numTrials.shamOut])';
iti_shamOut = Shuffle(iti_shamOut(1:parameters.numTrials.shamOut));
cond_shamOut = 4*ones(length(inds),1);

% concat all conditiosn
stimLocSet_pix = [stimLocSet_In ; stimLocSet_Out ; stimLocSet_shamIn ; stimLocSet_shamOut];
[stimLocSet_va_ecc,stimLocSet_va_theta] = pixel2va(screen,stimLocSet_pix(:,1),stimLocSet_pix(:,2),'ul');

if strcmp(parameters.task,'pro');
    saccLocSet_pix = stimLocSet_pix;
elseif strcmp(parameters.task,'anti')
    saccLocSet_pix(:,1) = screen.screenXpixels - stimLocSet_pix(:,1);
    saccLocSet_pix(:,2) = stimLocSet_pix(:,2);
end
[saccLocSet_va_ecc,saccLocSet_va_theta] = pixel2va(screen,saccLocSet_pix(:,1),saccLocSet_pix(:,2),'ul');

coilHem = [coilHem_In ; coilHem_Out ; coilHem_shamIn ; coilHem_shamOut];
coilLocInd_all = [coilLoc_In ; coilLoc_Out ; coilLoc_shamIn ; coilLoc_shamOut];
delay1 = [delay1_In ; delay1_Out ; delay1_shamIn ; delay1_shamOut];
pulseDuration = [pulseDuration_In ; pulseDuration_Out ; pulseDuration_shamIn ; pulseDuration_shamOut];
delay2 = [delay2_In ; delay2_Out ; delay2_shamIn ; delay2_shamOut];
ITI = [iti_In ; iti_Out ; iti_shamIn ; iti_shamOut];
conditions = [cond_In ; cond_Out ; cond_shamIn ; cond_shamOut];

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

save(parameters.taskMapFile,'taskMap');
% writetable(struct2table(taskMap),'taskMapWM.csv');


end