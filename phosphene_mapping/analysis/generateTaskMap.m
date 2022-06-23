function generateTaskMap(subjID, session, data_dir, coilLocInd)
global parameters;
fileName = ['PhospheneReport_sub' subjID '_sess' session];
stimuli_report_path = [data_dir '/' fileName];
load(stimuli_report_path);

tmsRtnTpy_path = [data_dir '/tmsRtnTpy_sub' subjID '_sess' session];
load(tmsRtnTpy_path);

% coilHemField --> 1: Right visual filed , 2: Left visual field
% conditions: 1: Pulse/In , 2: Pulse/Out 
trial.stimLoc = PhosphReport(coilLocInd).StimuliSampleSpace;
trial.coilHem = PhosphReport(coilLocInd).coilHemField;
%trial.coilLoc = coilLocInd;

% stimulus inside the tms FOV / TMS
inds = randi(length(trial.stimLoc),[parameters.numTrials.In parameters.numBlocks]);
stimLocSet_In = trial.stimLoc(inds,:);
coilHem_In = repmat(trial.coilHem,[parameters.numTrials.In parameters.numBlocks]);
cond_In = 1*ones(length(inds),1);

% stimulus outside the tms FOV / TMS
stimLocSet_Out = [screen.screenXpixels screen.screenYpixels] - stimLocSet_In; % mirror diagonally
coilHem_Out = repmat(trial.coilHem,[parameters.numTrials.Out parameters.numBlocks]);
cond_Out = 2*ones(length(inds),1);

% concat all conditions
stimLocSet_pix = [stimLocSet_In ; stimLocSet_Out];
%[stimLocSet_va_ecc,stimLocSet_va_theta] = pixel2va(stimLocSet_pix(:,1),stimLocSet_pix(:,2),'ul');

if strcmp(parameters.task,'pro')
    saccLocSet_pix = stimLocSet_pix;
elseif strcmp(parameters.task,'anti')
    saccLocSet_pix = [screen.screenXpixels screen.screenYpixels] - stimLocSet_pix;
end

%[saccLocSet_va_ecc,saccLocSet_va_theta] = pixel2va(saccLocSet_pix(:,1),saccLocSet_pix(:,2),'ul');

coilHem = [coilHem_In ; coilHem_Out];
conditions = [cond_In ; cond_Out];

% Set taskMap
trialInds = randperm(size(stimLocSet_pix,1));

taskMap.condition = conditions(trialInds);
taskMap.stimLoc_pix = stimLocSet_pix(trialInds,:);
taskMap.saccLoc_pix = saccLocSet_pix(trialInds,:);
% taskMap.stimLoc_va = [stimLocSet_va_ecc(trialInds) stimLocSet_va_theta(trialInds)];
% taskMap.saccLoc_va = [saccLocSet_va_ecc(trialInds) saccLocSet_va_theta(trialInds)];
taskMap.coilHemifield = coilHem(trialInds);

taskMap.trialNum = length(stimLocSet_pix);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(parameters.taskMapFile, 'taskMap');
% writetable(struct2table(taskMap),'taskMapWM.csv');
end