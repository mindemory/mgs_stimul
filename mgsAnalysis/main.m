clear; close all;
subjID = '20';
curr_dir = pwd;
mgs_dir = curr_dir(1:end-12);
master_dir = mgs_dir(1:end-11);

phosphene_data_path = [master_dir filesep 'data/phosphene_data/sub' subjID];
mgs_data_path = [master_dir filesep 'data/mgs_data/sub' subjID];
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));