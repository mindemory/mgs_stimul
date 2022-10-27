function S01_eyedata_to_iisess(subjID, day, end_block)
%% Initialization
clearvars -except subjID day end_block; close all; clc;
ifgFile = 'p_1000hz.ifg';

subjID = num2str(subjID, "%02d");
tmp = pwd; tmp2 = strfind(tmp,filesep);
direct.master = tmp(1:(tmp2(end)-1));
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('hostname');
end
hostname = strtrim(hostname);

if strcmp(hostname, 'syndrome') % If running on Syndrome
    direct.datc = '/d/DATC/datc/MD_TMS_EEG';
else % If running on World's best MacBook
    direct.datc = '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc';
end
direct.data = [direct.datc '/data']; 
direct.analysis = [direct.datc '/analysis'];
direct.iEye = [direct.master '/iEye'];
direct.phosphene = [direct.data '/phosphene_data/sub' subjID];
direct.mgs = [direct.data '/mgs_data/sub' subjID];
direct.day = [direct.mgs '/day' num2str(day, "%02d")];
addpath(genpath(direct.iEye));
%addpath(genpath(phosphene_data_path));
addpath(genpath(direct.data));

taskMapfilename = [direct.phosphene '/taskMap_sub' subjID '_day' num2str(day, "%02d") '_antitype_mirror.mat'];
load(taskMapfilename);
% for ii = 1:length(taskMap)
%     for jj = 1:length(taskMap(ii).stimLocpix)
%         if taskMap(ii).stimLocpix(jj, 1) > 1100
%             taskMap(ii).stimVF(jj) =  1;
%         else
%             taskMap(ii).stimVF(jj) = 0;
%         end
%     end
%     taskMap(ii).stimVF = taskMap(ii).stimVF';
% end
% save(taskMapfilename, 'taskMap')
%% Run iEye
% Saving stuff
%Create a directory to save all files with their times
tic
direct.save = [direct.analysis '/sub' subjID '/day' num2str(day, "%02d")];
if ~exist(direct.save, 'dir')
    mkdir(direct.save);
end

saveNamepro = [direct.save '/ii_sess_pro_sub' subjID '_day' num2str(day, "%02d")];
saveNameanti = [direct.save '/ii_sess_anti_sub' subjID '_day' num2str(day, "%02d")];
saveNamepromat = [saveNamepro '.mat'];
saveNameantimat = [saveNameanti '.mat'];
if exist(saveNamepromat, 'file') == 2 && exist(saveNameantimat, 'file') == 2
    disp('Loading existing ii_sess files.')
    load(saveNamepromat);
    load(saveNameantimat);
else
    disp('ii_sess files do not exist. running ieye')
    [ii_sess_pro, ii_sess_anti] = run_iEye(direct, taskMap, end_block);
    save(saveNamepro,'ii_sess_pro')
    save(saveNameanti,'ii_sess_anti')
end
toc
end