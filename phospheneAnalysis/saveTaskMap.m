function saveTaskMap(subjID, session, coilLocInd)
% Choose a session and coilLocInd that needs to be used for a given subject
%%% Adding all necessary paths
curr_dir = pwd;
filesepinds = strfind(curr_dir,filesep);
master_dir = curr_dir(1:(filesepinds(end-1)-1));
phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];

addpath(genpath(phosphene_data_path));

load([phosphene_data_path '/PhospheneReport_sub' subjID '_sess' session])
taskMap = PhosphReport(coilLocInd).taskMap;
%% Save results
saveName_taskMap = [phosphene_data_path '/taskMap_sub' subjID];
save(saveName_taskMap,'taskMap')
end