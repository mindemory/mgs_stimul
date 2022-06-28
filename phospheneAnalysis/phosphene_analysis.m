clear; close all; clc;% clear mex;
% NOTE: This code can only run on Syndrome

%% Initialization
%global parameters;
subjID = '20';
session = '02';
curr_dir = pwd;
%phsph_map_dir = curr_dir(1:end-27);
mgs_dir = curr_dir(1:end-18);
master_dir = mgs_dir(1:end-11);
data_path = [master_dir filesep 'data/phosphene_data/sub' subjID];

%% Compute Overlapping Phosphene Area and Target Locations
calcPhospheneArea(subjID, session, data_path);