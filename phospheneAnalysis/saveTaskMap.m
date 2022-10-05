function saveTaskMap(subjID, session, coilLocInd, anti_type)
clearvars -except subjID session coilLocInd anti_type; close all; clc;
if nargin < 4
    anti_type = 'mirror';
end
% Choose a session and coilLocInd that needs to be used for a given subject
%%% Adding all necessary paths
subjID = num2str(subjID, "%02d");
session = num2str(session, "%02d");

%%% Check the system name to ensure correct paths are added.
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

if strcmp(hostname, 'syndrome')
    master_dir = '/d/DATC/datc/MD_TMS_EEG/';
else
    master_dir = '/Users/mrugankdake/remote/datc/MD_TMS_EEG/';
end

phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];

addpath(genpath(phosphene_data_path));

load([phosphene_data_path '/PhospheneReport_sub' subjID '_sess' session '_antitype_' anti_type])
for day = 1:3
    taskMap = PhosphReport(coilLocInd).taskMap(day, :);
    saveName_taskMap = [phosphene_data_path '/taskMap_sub' subjID '_day' num2str(day,"%02d") '_antitype_' anti_type];
    save(saveName_taskMap,'taskMap')
end
taskMapPractice = PhosphReport(coilLocInd).taskMapPractice;
%% Save results
saveName_taskMapPractice = [phosphene_data_path '/taskMapPractice_sub' subjID '_antitype_' anti_type];
save(saveName_taskMapPractice,'taskMapPractice')
end