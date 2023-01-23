function [p, taskMap] = initialization(p, analysis_type)

tmp = pwd; tmp2 = strfind(tmp,filesep);
p.master = tmp(1:(tmp2(end)-1));
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
p.hostname = strtrim(hostname);

if strcmp(p.hostname, 'syndrome') || strcmp(p.hostname, 'vader') % If running on Syndrome or Vader
    p.datc = '/datc/MD_TMS_EEG';
    p.EEGData = [p.datc '/EEGData/sub' p.subjID '/day' num2str(p.day, '%02d')];
    p.fieldtrip = '/hyper/software/fieldtrip-20220104/';
else % If running on World's best MacBook
    p.datc = '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/MD_TMS_EEG';
    p.EEGData = [p.datc '/EEGData/sub' p.subjID];
    p.fieldtrip = '/Users/mrugankdake/Documents/MATLAB/fieldtrip-20220104/';
end
p.data = [p.datc '/data'];
addpath(genpath(p.data));

p.analysis = [p.datc '/analysis'];
addpath(genpath(p.analysis));

p.phosphene = [p.data '/phosphene_data/sub' p.subjID];
p.mgs = [p.data '/mgs_data/sub' p.subjID];
p.dayfolder = [p.mgs '/day' num2str(p.day, '%02d')];

%taskMapfilename = [p.phosphene '/taskMap_sub' subjID '_day' num2str(day, '%02d') '_antitype_mirror.mat'];
taskMapfilename = [p.phosphene '/taskMap_sub' p.subjID '_day' num2str(p.day, '%02d') '.mat'];
load(taskMapfilename);

p.tmstatus = taskMap(1).TMScond; %0 if off, 1 if on

% Folder to save analysis data
p.save = [p.analysis '/sub' p.subjID '/day' num2str(p.day, '%02d')];
p.save_eyedata = [p.save '/EyeData'];
if ~exist(p.save, 'dir')
    mkdir(p.save);
end

% Add toolbox to path (either iEye or fieldtrip)
if strcmp(analysis_type, 'eye')
    p.iEye = [p.master '/iEye'];
    addpath(genpath(p.iEye));
elseif strcmp(analysis_type, 'eeg')
    p.saveEEG = [p.datc '/EEGfiles'];
    addpath(p.fieldtrip);
    ft_defaults;
end
end