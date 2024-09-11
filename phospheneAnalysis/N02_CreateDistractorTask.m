function N02_CreateDistractorTask(subjID)
clearvars -except subjID;
% This function is written to create a control task on day04 of the study
% by extracting pro blocks from the three days of the study

subjID = num2str(subjID, "%02d");
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

if strcmp(hostname, 'zod.psych.nyu.edu') || strcmp(hostname, 'zod')
    master_dir = '/d/DATD/datd/MD_TMS_EEG/';
else
    master_dir = '/Users/mrugankdake/remote/datd/MD_TMS_EEG/';
end

phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
addpath(genpath(phosphene_data_path));


load([phosphene_data_path '/tmsRtnTpy_sub' subjID '_sess01.mat']);

% Compute all possible points on the screen
xMax = tmsRtnTpy.Params.screen.screenXpixels;
yMax = tmsRtnTpy.Params.screen.screenYpixels;
XX = 1:xMax; YY = 1:yMax;
XY = [repelem(XX(:), numel(YY), 1) ...
      repmat(YY(:), numel(XX), 1)];

% remove invalid trials and corresponding coil locations
tmsRtnTpy = remove_invalid_trials(tmsRtnTpy);

if strcmp(subjID, num2str(1,'%02d'))
    locSelected = 1;
end

phsphTrials = find(tmsRtnTpy.Response.CoilLocation == locSelected & tmsRtnTpy.Response.Detection == 1);
TFin = NaN(length(phsphTrials), yMax, xMax);
TFout = NaN(length(phsphTrials), yMax, xMax);
% compute area and border for each drawing for given CoilLocation
for trial = 1:length(phsphTrials)
    trialInd = phsphTrials(trial);
    drawing = tmsRtnTpy.Response.Drawing{trialInd};
    polyPhosph = rmholes(polyshape(drawing));
    TFin_temp = isinterior(polyPhosph, XY);
    TFin_temp = reshape(TFin_temp, yMax, xMax);
    TFout_temp = fliplr(TFin_temp);
    TFin(trial, :, :) = TFin_temp;
    TFout(trial, :, :) = TFout_temp;
end 

% Extracting pro blocks from day1
load([phosphene_data_path '/taskMap_sub' subjID '_day01_antitype_mirror.mat'])
tMap1 = taskMap; clearvars taskMap;
row1_pro = arrayfun(@(x) strcmp(x.condition, 'pro'), tMap1);
tMap1_pro = tMap1(row1_pro);

% Extracting pro blocks from day 2
load([phosphene_data_path '/taskMap_sub' subjID '_day02_antitype_mirror.mat'])
tMap2 = taskMap; clearvars taskMap;
row2_pro = arrayfun(@(x) strcmp(x.condition, 'pro'), tMap2);
tMap2_pro = tMap2(row2_pro);

% Extracting pro blocks from day 3
load([phosphene_data_path '/taskMap_sub' subjID '_day03_antitype_mirror.mat'])
tMap3 = taskMap;
row3_pro = arrayfun(@(x) strcmp(x.condition, 'pro'), tMap3);
tMap3_pro = tMap3(row3_pro);

% Combining the 3 tMaps into a common structure for day 4
taskMapMaster = [tMap1_pro, tMap2_pro, tMap3_pro];
for ii = 1:15
    taskMapMaster(ii).TMScond = 0;
end

% % Load polyshape of the phosphenes reported
% load([phosphene_data_path '/PhospheneReport_sub' subjID '_sess01_antitype_mirror']);
% if strcmp(subjID, num2str(1,'%02d'))
%     locSelected = 1;
% end
% polyPhosph = PhosphReport(locSelected).overlapPolyshape;


% Add distractor hemifield and shape of the overlap to taskMap
taskMap = taskMapMaster;
for i = 1:length(taskMap)
    nTrls = length(taskMap(i).stimVF);
    distractorHemi = randi([0, 1], nTrls, 1);
    taskMap(i).distractorHemi = distractorHemi; % 0 is outPF and 1 is inPF
    taskMap(i).TFin = TFin;
    taskMap(i).TFout = TFout;
end

% Save the taskMap file as day06
saveName_taskMap = [phosphene_data_path '/taskMap_sub' subjID '_day06_antitype_mirror.mat'];
if ~exist(saveName_taskMap, 'file')
    save(saveName_taskMap,'taskMap')
else
    disp('TaskMap exists, delete it first!')
end
end
