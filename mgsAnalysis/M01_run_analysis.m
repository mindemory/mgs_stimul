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

tmstatus = taskMap(1).TMScond; %0 if off, 1 if on

for blurb = 1:length(taskMap)
    if strcmp(taskMap(blurb).condition, 'pro')
        if ~exist('protrialNum', 'var')
            protrialNum = (blurb-1)*40+1:blurb*40;
        else
            protrialNum = [protrialNum;(blurb-1)*40+1:blurb*40];
        end
    elseif strcmp(taskMap(blurb).condition, 'anti')
        if ~exist('antitrialNum', 'var')
            antitrialNum = (blurb-1)*40+1:blurb*40;
        else
            antitrialNum = [antitrialNum;(blurb-1)*40+1:blurb*40];
        end
    end
end
protrialNum = reshape(protrialNum, [], 1);
antitrialNum = reshape(antitrialNum, [], 1);
%% Load ii_sess files
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
    disp('ii_sess files do not exist. Run S01_eyedata_to_mat.')
end
toc

%% Run EEG preprocessing
prointoVF_idx = find(ii_sess_pro.stimVF == 1);
prooutVF_idx = find(ii_sess_pro.stimVF == 0);
antiintoVF_idx = find(ii_sess_anti.stimVF == 0);
antioutVF_idx = find(ii_sess_anti.stimVF == 1);
prointoVF_idx_EEG = protrialNum(prointoVF_idx);
prooutVF_idx_EEG = protrialNum(prooutVF_idx);
antiintoVF_idx_EEG = antitrialNum(antiintoVF_idx);
antioutVF_idx_EEG = antitrialNum(antioutVF_idx);

if strcmp(hostname, 'syndrome') % If running on Syndrome
    direct.EEG = [direct.datc '/EEGData/sub' subjID '/day' num2str(day, "%02d")];
else
    direct.EEG = [direct.datc '/EEGData/sub' subjID];
end

direct.saveEEG = [direct.datc '/EEGfiles/sub' subjID];
if ~exist(direct.saveEEG, 'dir')
    mkdir(direct.saveEEG)
end
EEGfile = ['sub' num2str(subjID, "%02d") '_day' num2str(day, "%02d") '_concat.vhdr'];
% saccloc = 1 refers to stimulus in VF

%[task_prointoVF, task_prooutVF, task_antiintoVF, task_antioutVF] = ...
%    eeg_pipeline(direct, EEGfile, prointoVF_idx, prooutVF_idx, ...
%    antiintoVF_idx, antioutVF_idx);