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

matFile = [mgs_data_path '/block' num2str(block,"%02d") '/subj' subjID '_block' block '.mat'];
load(matFile);
parameters = matFile.parameters;
screen = matFile.screen;
timeReport = matFile.timeReport;

edfFileUbuntuPath = parameters.edfFile;
filesepinds = strfind(edfFileUbuntuPath,filesep);
edfFileName = edfFileUbuntuPath(filesepinds(end):end);
edfFile = [mgs_data_path '/block' num2str(block,"%02d") edfFileName];
ifgFile = 'p_1000hz.ifg';
ii_params = ii_loadparams; % load default set of analysis parameters, only change what we have to
ii_params.valid_epochs =[1 2 3 4 5 6 7 8];
ii_params.trial_end_value = 8;   % XDAT value for trial end
ii_params.drift_epoch = [1 2 3 4 5 6]; % XDAT values for drift correction
ii_params.calibrate_epoch = 7;   % XDAT value for when we calibrate (feedback stim)
ii_params.calibrate_select_mode = 'last'; % how do we select fixation with which to calibrate?
ii_params.calibrate_mode = 'scale'; % scale: trial-by-trial, rescale each trial; 'run' - run-wise polynomial fit
ii_params.blink_window = [200 200]; % how long before/after blink (ms) to drop?
ii_params.plot_epoch = [2 3 4 5 6 7];  % what epochs do we plot for preprocessing?
ii_params.calibrate_limits = [2.5]; % when amount of adj exceeds this, don't actually calibrate (trial-wise); ignore trial for polynomial fitting (run)

preproc_fn = edfFile(1:end-4);
    
    
% run preprocessing!
[ii_data, ii_cfg, ii_sacc] = ii_preproc(edfFile,ifgFile,preproc_fn,ii_params);
    