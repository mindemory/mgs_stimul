clear; close all; clc;% clear mex;
% NOTE: This code can only run on Syndrome
%% Initialization
%global parameters;
subjID = '20';
session = '02';
curr_dir = pwd;
%phsph_map_dir = curr_dir(1:end-27);
mgs_dir = curr_dir(1:end-27);
master_dir = mgs_dir(1:end-11);
data_path = [master_dir filesep 'data/phosphene_data/sub' subjID];
%parameters = loadParameters(subjID, session);




%% Compute Overlapping Phosphene Area
calcPhospheneArea(subjID, session, data_path);

choosenCoilLoc = input('Enter choosen coil location: ');
generateTaskMaps(subjID, session, data_path, choosenCoilLoc);