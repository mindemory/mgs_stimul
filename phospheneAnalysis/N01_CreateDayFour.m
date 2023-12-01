function N01_CreateDayFour(subjID)
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
    master_dir = '/d/DATC/datc/MD_TMS_EEG/';
else
    master_dir = '/Users/mrugankdake/remote/datc/MD_TMS_EEG/';
end

phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];

addpath(genpath(phosphene_data_path));

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
    taskMapMaster(ii).TMScond = 1;
end

% Save the taskMap file as day04
taskMap = taskMapMaster(1:8);
saveName_taskMap = [phosphene_data_path '/taskMap_sub' subjID '_day04_antitype_mirror.mat'];
save(saveName_taskMap,'taskMap')
taskMap = taskMapMaster(8:15);
saveName_taskMap = [phosphene_data_path '/taskMap_sub' subjID '_day05_antitype_mirror.mat'];
save(saveName_taskMap,'taskMap')
end
