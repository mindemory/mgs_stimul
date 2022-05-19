clear; close all; clc;% clear mex;

%% Initialization
global parameters;
subjID = '03';
session = '01';
parameters = loadParameters(subjID, session);

[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);

if ~strcmp(hostname, 'syndrome')
    disp('This code should only be run on Syndrome.')
end

%% Copy Files to DATA
data_dir = ['/d/DATA/hyper/experiments/Mrugank/TMS/data/phosphene_data/sub' subjID];
fname = [data_dir, '/tmsRtnTpy_sub' subjID '_sess' session '.mat'];
if ~exist(fname, 'file')
    copyfiles(subjID, session, data_dir);
end

%% Compute Overlapping Phosphene Area
calcPhospheneArea(subjID,session,parameters.overlapThreshold, data_dir);

%% Compute Stimulus Locations
calcStimLocations(subjID,session, data_dir);

