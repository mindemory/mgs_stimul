function saveTaskMap(subjID, session, coilLocInd)
% Choose a session and coilLocInd that needs to be used for a given subject
%%% Adding all necessary paths
subjID = num2str(subjID, "%02d");
session = num2str(session, "%02d");

master_dir = '/d/DATC/datc/MD_TMS_EEG/';
phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];

addpath(genpath(phosphene_data_path));

load([phosphene_data_path '/PhospheneReport_sub' subjID '_sess' session])
for day = 1:3
    taskMap = PhosphReport(coilLocInd).taskMap(day, :);
    saveName_taskMap = [phosphene_data_path '/taskMap_sub' subjID '_day' num2str(day,"%02d")];
    save(saveName_taskMap,'taskMap')
end
taskMapPractice = PhosphReport(coilLocInd).taskMapPractice;
%% Save results
%saveName_taskMap = [phosphene_data_path '/taskMap_sub' subjID];
%save(saveName_taskMap,'taskMap')
saveName_taskMapPractice = [phosphene_data_path '/taskMapPractice_sub' subjID];
save(saveName_taskMapPractice,'taskMapPractice')
end