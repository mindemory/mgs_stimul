clear; close all; clc;

%% Initialization
subjID = '01';
day = 1;
tmp = pwd; tmp2 = strfind(tmp,filesep);
direct.master = tmp(1:(tmp2(end-1)-1));
direct.datc = '/datc/MD_TMS_EEG';
direct.data = [direct.datc '/data'];
direct.analysis = [direct.datc '/analysis'];
direct.iEye = [direct.master '/iEye'];
direct.phosphene = [direct.data '/phosphene_data/sub' subjID];
direct.mgs = [direct.data '/mgs_data/sub' subjID];
direct.day = [direct.mgs '/day' num2str(day, "%02d") '_real'];
addpath(genpath(direct.iEye));
%addpath(genpath(phosphene_data_path));
addpath(genpath(direct.data));

taskMapfilename = [direct.phosphene '/taskMap_sub' subjID '_day' num2str(day, "%02d") '.mat'];
load(taskMapfilename);

%% Run iEye
% Saving stuff
%Create a directory to save all files with their times
direct.save = [direct.analysis '/sub' subjID '/day' num2str(day, "%02d")];% ...
% filesep datestr(now, 'mm_dd_yy_HH_MM_SS')];
if ~exist(direct.save, 'dir')
    mkdir(direct.save);
end

saveNamepro = [direct.save '/ii_sess_pro_sub' subjID '_day' num2str(day, "%02d")];
saveNameanti = [direct.save '/ii_sess_anti_sub' subjID '_day' num2str(day, "%02d")];
saveNamepromat = [saveNamepro '.mat'];
saveNameantimat = [saveNameanti '.mat'];
if exist(saveNamepromat, 'file') == 2 && exist(saveNameantimat, 'file') == 2
    load(saveNamepromat);
    load(saveNameantimat);
else
    [ii_sess_pro, ii_sess_anti] = run_iEye(direct, taskMap);
    save(saveNamepro,'ii_sess_pro')
    save(saveNameanti,'ii_sess_anti')
end

%% Run EEG preprocessing
direct.EEG = [direct.datc '/EEGData/sub' subjID];
EEGfile = 'sub01_day01_concat.vhdr';
prointoVF_idx = find(ii_sess_pro.saccloc == 1);
prooutVF_idx = find(ii_sess_pro.saccloc == 0);
antiintoVF_idx = find(ii_sess_anti.saccloc == 1);
antioutVF_idx = find(ii_sess_anti.saccloc == 0);
[task_prointoVF, task_prooutVF, task_antiintoVF, task_antioutVF] = ...
    eeg_pipeline(direct, EEGfile, prointoVF_idx, prooutVF_idx, ...
    antiintoVF_idx, antioutVF_idx)