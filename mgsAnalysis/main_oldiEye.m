clear; close all; clc;
subjID = '01';
day = 1;
tmp = mfilename('fullpath'); tmp2 = strfind(tmp,filesep);
master_dir = tmp(1:(tmp2(end-2)-1));
datc_dir = '/datc/MD_TMS_EEG/data';
analysis_dir = '/datc/MD_TMS_EEG/analysis';
%master_dir = mgs_dir(1:end-11);

iEye_path = [master_dir '/iEye'];
phosphene_data_path = [datc_dir '/phosphene_data/sub' subjID];
mgs_data_path = [datc_dir '/mgs_data/sub' subjID];
day_path = [mgs_data_path '/day' num2str(day, "%02d")];
addpath(genpath(iEye_path));
%addpath(genpath(phosphene_data_path));
addpath(genpath(datc_dir));
taskMapfilename = [phosphene_data_path '/taskMap_sub' subjID '_day' num2str(day, "%02d") '.mat'];
load(taskMapfilename);


ifgFile = 'p_1000hz.ifg';
ii_params = ii_loadparams; % load default set of analysis parameters, only change what we have to
ii_params.valid_epochs =[1 2 3 4 5 6 7 8];
ii_params.trial_start_value = 1; %XDAT value for trial start
ii_params.trial_end_value = 8;   % XDAT value for trial end
ii_params.drift_epoch = [1 2 3 4]; % XDAT values for drift correction
ii_params.calibrate_epoch = 7;   % XDAT value for when we calibrate (feedback stim)
ii_params.calibrate_select_mode = 'last'; % how do we select fixation with which to calibrate?
ii_params.calibrate_mode = 'scale'; % scale: trial-by-trial, rescale each trial; 'run' - run-wise polynomial fit
ii_params.blink_window = [200 200]; % how long before/after blink (ms) to drop?
ii_params.plot_epoch = [4 5 6 7];  % what epochs do we plot for preprocessing?
ii_params.calibrate_limits = [2.5]; % when amount of adj exceeds this, don't actually calibrate (trial-wise); ignore trial for polynomial fitting (run)
block_pro = 1;
block_anti = 1;
for block = 1:12
    block_path = [day_path '/block' num2str(block,"%02d")];
    matFile_extract = dir(fullfile(block_path, '*.mat'));
    matFile = [block_path filesep matFile_extract.name];
    load(matFile);
    parameters = matFile.parameters;
    screen = matFile.screen;
    timeReport = matFile.timeReport;
    trialInfo{block} = timeReport;
    eyecond = taskMap(block).condition;
    ii_params.resolution = [screen.screenXpixels screen.screenYpixels];

    %ii_params.viewingDistance = parameters.viewingDistance;
    %ii_params.pixSize = screen.pixSize;
    ii_params.ppd = parameters.viewingDistance * tand(1) / screen.pixSize;
    edfFileName = parameters.edfFile;
    edfFile = [block_path '/EyeData/' edfFileName '.edf'];
    
    % what is the output filename?
    preproc_fn = edfFile(1:end-4);
   
    % run preprocessing!
    [ii_data, ii_cfg, ii_sacc] = eye_preprocess_oldiEye(edfFile, ifgFile, preproc_fn, ii_params);

%     if block == 1
%         % plot some features of the data
%         % (check out the docs for each of these; lots of options...)
%         ii_plottimeseries(ii_data,ii_cfg); % pltos the full timeseries
%         ii_plotalltrials(ii_data,ii_cfg); % plots each trial individually
%         ii_plotalltrials2d(ii_data,ii_cfg); % plots all trials, in 2d, overlaid on one another w/ fixations
%     end
    
    % score trials
    % default parameters should work fine - but see docs for other
    % arguments you can/should give when possible
    if ii_sacc.epoch_start == 5
        ii_sacc.epoch_start = 6;
    end
    
    pt1 = [0 screen.screenYpixels];
    pt2 = [screen.screenXpixels 0];
    if strcmp(eyecond, 'pro')
        saccloc = [];
        for ii=1:length(taskMap(block).stimLocpix)
            d = ((taskMap(block).saccLocpix(ii,1) - pt1(1)) * ...
                (pt2(2) - pt1(2))) - ((taskMap(block).saccLocpix(ii,2) - pt1(2)) * ...
                (pt2(1) - pt1(1)));
            if d > 0
                saccloc = [saccloc, 1];
            elseif d < 0
                saccloc = [saccloc, 0];
            end
%             if taskMap(block).saccLocpix(ii,1)>=screen.xCenter && taskMap(block).saccLocpix(ii,2)>=screen.yCenter
%                 saccloc = [saccloc, 1];
%             elseif taskMap(block).saccLocpix(ii,1)<screen.xCenter && taskMap(block).saccLocpix(ii,2)<screen.yCenter
%                 saccloc = [saccloc, 0];
%             end
        end
        [ii_trial_pro{block_pro},ii_cfg] = ii_scoreMGS(ii_data,ii_cfg,ii_sacc, [], 6);
        ii_trial_pro{block_pro}.saccloc = saccloc';
        block_pro = block_pro+1;
    elseif strcmp(eyecond, 'anti')
        saccloc = [];
        for ii=1:length(taskMap(block).stimLocpix)
            d = ((taskMap(block).saccLocpix(ii,1) - pt1(1)) * ...
                (pt2(2) - pt1(2))) - ((taskMap(block).saccLocpix(ii,2) - pt1(2)) * ...
                (pt2(1) - pt1(1)));
            if d > 0
                saccloc = [saccloc, 1];
            elseif d < 0
                saccloc = [saccloc, 0];
            end
%             if taskMap(block).saccLocpix(ii,1)>=screen.xCenter && taskMap(block).saccLocpix(ii,2)>=screen.yCenter
%                 saccloc = [saccloc, 1];
%             elseif taskMap(block).saccLocpix(ii,1)<screen.xCenter && taskMap(block).saccLocpix(ii,2)<screen.yCenter
%                 saccloc = [saccloc, 0];
%             end
        end
        [ii_trial_anti{block_anti},ii_cfg] = ii_scoreMGS(ii_data,ii_cfg,ii_sacc, [], 6);
        ii_trial_anti{block_anti}.saccloc = saccloc';
        block_anti = block_anti+1;
    end
end
ii_sess_pro = ii_combineruns(ii_trial_pro);
ii_sess_anti = ii_combineruns(ii_trial_anti);

%% Saving stuff
%%%% Create a directory to save all files with their times
saveDIR = [analysis_dir '/sub' subjID '/day' num2str(day, "%02d")];% ...
    % filesep datestr(now, 'mm_dd_yy_HH_MM_SS')];
if exist('saveDIR', 'dir') ~= 7
    mkdir(saveDIR);
end

saveNamepro = [saveDIR '/ii_sess_pro_sub' subjID '_day' num2str(day, "%02d")];
save(saveNamepro,'ii_sess_pro')
saveNameanti = [saveDIR '/ii_sess_anti_sub' subjID '_day' num2str(day, "%02d")];
save(saveNameanti,'ii_sess_anti')

% mean_init_pro = nanmean(ii_sess_pro.i_sacc_err);
% mean_init_anti = nanmean(ii_sess_anti.i_sacc_err);
% mean_final_pro = nanmean(ii_sess_pro.f_sacc_err);
% mean_final_anti = nanmean(ii_sess_anti.f_sacc_err);
% 
% stderr_init_pro = nanstd(ii_sess_pro.i_sacc_err)/sqrt(length(ii_sess_pro.i_sacc_err));
% stderr_init_anti = nanstd(ii_sess_anti.i_sacc_err)/sqrt(length(ii_sess_anti.i_sacc_err));
% stderr_final_pro = nanstd(ii_sess_pro.f_sacc_err)/sqrt(length(ii_sess_pro.f_sacc_err));
% stderr_final_anti = nanstd(ii_sess_anti.f_sacc_err)/sqrt(length(ii_sess_anti.f_sacc_err));
% X = ["initial pro", "initial anti", "final pro", "final anti"];
% Y = [mean_init_pro, mean_init_anti, mean_final_pro, mean_final_anti];
% ERR = [stderr_init_pro, stderr_init_anti, stderr_final_pro, stderr_final_anti];
% figure()
% errorbar(X, Y, ERR);