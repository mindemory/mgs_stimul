clear; close all; clc;% clear mex;
global parameters;
subjID = '27';
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

data_dir = copyfiles(subjID, session);
calcPhospheneArea(subjID,session,parameters.overlapThreshold, data_dir);
calcStimLocations(subjID,session, data_dir);

