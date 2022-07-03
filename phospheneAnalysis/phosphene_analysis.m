function phosphene_analysis(subjID, session)
clearvars -except subjID session; close all; clc;
% NOTE: This code can only run on Syndrome
warning('off','all')

subjID = num2str(subjID, "%02d");
session = num2str(session, "%02d");
curr_dir = pwd;
filesepinds = strfind(curr_dir,filesep);
master_dir = curr_dir(1:(filesepinds(end-1)-1));
data_path = [master_dir '/data/phosphene_data/sub' subjID];
figures_path = [master_dir '/Figures/phosphene_data/sub' subjID];

%% Compute Overlapping Phosphene Area and Target Locations
calcPhospheneArea(subjID, session, data_path, figures_path);