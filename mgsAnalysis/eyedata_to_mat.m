ifgFile = 'p_1000hz.ifg';
%direct.day = 1;
ii_init;
subjID = '02';
day = 2;
tmp = pwd; tmp2 = strfind(tmp,filesep);
direct.master = tmp(1:(tmp2(end-1)-1));
direct.datc = '/d/DATC/datc/MD_TMS_EEG/';
direct.data = [direct.datc '/data'];
direct.iEye = [direct.master '/iEye'];
direct.mgs = [direct.data '/mgs_data/sub' subjID];
direct.day = [direct.mgs '/day' num2str(day, "%02d")];
addpath(genpath(direct.iEye));
%addpath(genpath(phosphene_data_path));
addpath(genpath(direct.data));
for block = 1:3
    direct.block = [direct.day '/block' num2str(block,"%02d")];
    matFile_extract = dir(fullfile(direct.block, '*.mat'));
    matFile = [direct.block filesep matFile_extract.name];
    load(matFile);
    parameters = matFile.parameters;
    edfFileName = parameters.edfFile;
    edfFile = [direct.block '/EyeData/' edfFileName '.edf'];
    ii_import_edf(edfFile,ifgFile,[edfFile(1:end-4) '_iEye.mat']);
end