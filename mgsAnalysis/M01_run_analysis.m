clear; close all; clc;

%% Initialization
subjID = '01';
day = 2;
end_block = 10;
tmp = pwd; tmp2 = strfind(tmp,filesep);
direct.master = tmp(1:(tmp2(end-1)-1));
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

if strcmp(hostname, 'syndrome') % If running on Syndrome
    direct.datc = '/datc/MD_TMS_EEG';
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

taskMapfilename = [direct.phosphene '/taskMap_sub' subjID '_day' num2str(day, "%02d") '.mat'];
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
    disp('Loading exists ii_sess files.')
    load(saveNamepromat);
    load(saveNameantimat);
else
    disp('ii_sess files do not exist. running ieye')
    [ii_sess_pro, ii_sess_anti] = run_iEye(direct, taskMap, end_block);
    save(saveNamepro,'ii_sess_pro')
    save(saveNameanti,'ii_sess_anti')
end
toc

%% Run EEG preprocessing
prointoVF_idx = find(ii_sess_pro.stimVF == 1);
prooutVF_idx = find(ii_sess_pro.stimVF == 0);
antiintoVF_idx = find(ii_sess_anti.stimVF == 0);
antioutVF_idx = find(ii_sess_anti.stimVF == 1);

direct.EEG = [direct.datc '/EEGData/sub' subjID];
direct.saveEEG = [direct.datc '/EEGfiles/sub' subjID];
if ~exist(direct.saveEEG, 'dir')
    mkdir(direct.saveEEG)
end
EEGfile = ['sub' num2str(subjID, "%02d") '_day' num2str(day, "%02d") '_concat.vhdr'];
% saccloc = 1 refers to stimulus in VF

%[task_prointoVF, task_prooutVF, task_antiintoVF, task_antioutVF] = ...
%    eeg_pipeline(direct, EEGfile, prointoVF_idx, prooutVF_idx, ...
%    antiintoVF_idx, antioutVF_idx);