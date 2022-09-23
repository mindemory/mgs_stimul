function [ii_sess_pro, ii_sess_anti] = run_iEye(direct, taskMap, end_block)

if nargin < 3
    end_block = 10;
end
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
for block = 1:1
    disp(['Running block ' num2str(block, "%02d")])
    direct.block = [direct.day '/block' num2str(block,"%02d")];
    matFile_extract = dir(fullfile(direct.block, '*.mat'));
    matFile = [direct.block filesep matFile_extract.name];
    load(matFile);
    parameters = matFile.parameters;
    screen = matFile.screen;
    timeReport = matFile.timeReport;
    trialInfo{block} = timeReport;
    eyecond = taskMap(block).condition;
    
    ii_params.resolution = [screen.screenXpixels screen.screenYpixels];
    ii_params.ppd = parameters.viewingDistance * tand(1) / screen.pixSize;
    edfFileName = parameters.edfFile;
    edfFile = [direct.block '/EyeData/' edfFileName '.edf'];
    
    % what is the output filename?
    preproc_fn = edfFile(1:end-4);
    
    % run preprocessing!
    [ii_data, ii_cfg, ii_sacc] = eye_preprocess(edfFile, ifgFile, preproc_fn, ii_params);
    
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
%     if block == 5
%         taskMap(block).stimVF = taskMap(block).stimVF(2:end);
%     end
    if strcmp(eyecond, 'pro')
        [ii_trial_pro{block_pro},ii_cfg] = ii_scoreMGS(ii_data,ii_cfg,ii_sacc, [], 6);
        ii_trial_pro{block_pro}.stimVF = taskMap(block).stimVF;
        block_pro = block_pro+1;
    elseif strcmp(eyecond, 'anti')
        [ii_trial_anti{block_anti},ii_cfg] = ii_scoreMGS(ii_data,ii_cfg,ii_sacc, [], 6);
        ii_trial_anti{block_anti}.stimVF = taskMap(block).stimVF;
        block_anti = block_anti+1;
    end
end
%% Combining runs
disp('Combining runs')
% For pro trials
if ~exist("ii_trial_pro", "var")
    ii_sess_pro = [];
else
    ii_sess_pro = ii_combineruns(ii_trial_pro);
    ii_sess_pro.break_fix = zeros(length(ii_sess_pro.excl_trial), 1);
    ii_sess_pro.prim_sacc = ones(length(ii_sess_pro.excl_trial), 1);
    ii_sess_pro.small_sacc = zeros(length(ii_sess_pro.excl_trial), 1);
    ii_sess_pro.large_error = zeros(length(ii_sess_pro.excl_trial), 1);

    for ii = 1:length(ii_sess_pro.excl_trial)
        % Flag trials with fixation breaks
        if sum(ii_sess_pro.excl_trial{ii} == 13) > 0
            ii_sess_pro.break_fix(ii) = 1;
        end
        % Flag trials with no primary saccades
        if sum(ii_sess_pro.excl_trial{ii} == 20) > 0
            ii_sess_pro.prim_sacc(ii) = 0;
        end
        % Flag trials with small or short saccades
        if sum(ii_sess_pro.excl_trial{ii} == 21) > 0
            ii_sess_pro.small_sacc(ii) = 1;
        end
        % Flag trials with large MGS errors
        if sum(ii_sess_pro.excl_trial{ii} == 22) > 0
            ii_sess_pro.large_error(ii) =  1;
        end
    end
end
% For anti trials
if ~exist("ii_trial_anti", "var")
    ii_sess_anti = [];
else
    ii_sess_anti = ii_combineruns(ii_trial_anti);
    ii_sess_anti.break_fix = zeros(length(ii_sess_anti.excl_trial), 1);
    ii_sess_anti.prim_sacc = ones(length(ii_sess_anti.excl_trial), 1);
    ii_sess_anti.small_sacc = zeros(length(ii_sess_anti.excl_trial), 1);
    ii_sess_anti.large_error = zeros(length(ii_sess_anti.excl_trial), 1);

    for ii = 1:length(ii_sess_anti.excl_trial)
        % Flag trials with fixation breaks
        if sum(ii_sess_anti.excl_trial{ii} == 13) > 0
            ii_sess_anti.break_fix(ii) = 1;
        end
        % Flag trials with no primary saccades
        if sum(ii_sess_anti.excl_trial{ii} == 20) > 0
            ii_sess_anti.prim_sacc(ii) = 0;
        end
        % Flag trials with small or short saccades
        if sum(ii_sess_anti.excl_trial{ii} == 21) > 0
            ii_sess_anti.small_sacc(ii) = 1;
        end
        % Flag trials with large MGS errors
        if sum(ii_sess_anti.excl_trial{ii} == 22) > 0
            ii_sess_anti.large_error(ii) =  1;
        end
    end
end
end
