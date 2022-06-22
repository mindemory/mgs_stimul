clear; close all; clc;% clear mex;

%% Initialization
global parameters;
subjID = '02';
session = '02';
parameters = loadParameters(subjID, session);

[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

if ~strcmp(hostname, 'syndrome')
    disp('This code can only be run on Syndrome.')
    return
end

curr_dir = pwd;
mgs_dir = curr_dir(1:end-18);
master_dir = mgs_dir(1:end-11);
data_path = [master_dir filesep 'data/phosphene_data/sub' subjID];

%% Compute Overlapping Phosphene Area
calcPhospheneArea(subjID, session, data_path);

%% Compute Stimulus Locations
%calcStimLocations(subjID, session, data_path);

choosenCoilLoc = input('Enter choosen coil location: ');
generateTaskMaps(subjID, session, data_path, choosenCoilLoc);