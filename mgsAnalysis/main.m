clear; close all;
subjID = '20';
block = '01';
curr_dir = pwd;
mgs_dir = curr_dir(1:end-12);
master_dir = mgs_dir(1:end-11);

iEye_path = [master_dir '/iEye'];
phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
mgs_data_path = [master_dir '/data/mgs_data/sub' subjID];
addpath(genpath(iEye_path));
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

matFile = [mgs_data_path '/Results/subj' subjID '_block' block '.mat'];
load(matFile);
parameters = matFile.parameters;
screen = matFile.screen;
timeReport = matFile.timeReport;

edfFile = parameters.edfFile;
ifgFile = [iEye_path '/examples/p_500hz.ifg'];
ii_import_edf(edfFile,cfg_fn,[edf_fn(1:end-4) '_iEye.mat']);