clear; close all; clc;% clear mex;
global parameters;
subjID = '03';
session = '01';
parameters = loadParameters(subjID, session);
calcPhospheneArea(subjID,session,parameters.overlapThreshold);
calcStimLocations(subjID,session);

