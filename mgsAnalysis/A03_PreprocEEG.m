function A03_PreprocEEG(subjID, steps)
%clearvars -except subjID day; close all; clc;

NoTMSdict = {
    1, 2;
    3, 2;
    5, 1;
    6, 2;
    7, 1;
    8, 3;
    12, 2;
    13, 3;
    14, 2;
    15, 3;
    16, 3;
    17, 2;
    18, 1;
    22, 3;
    23, 1;
    24, 2};
NoTMSdict = cell2struct(NoTMSdict, {'key', 'value'}, 2);

if nargin < 3
    steps = {'concat'};%, 'raweeg', 'bandpass', 'epoch', 'TFRfull'};
end
tms_day_counter = 1;

for day = 1:3
    p.subjID = num2str(subjID,'%02d');
    p.day = day;

    [p, taskMap] = initialization(p, 'eeg', 0);

    %EEGfile = ['sub' num2str(p.subjID, '%02d') '_day' num2str(p.day, '%02d') '_concat.vhdr'];

    % List of files to be saved
    % Step 1: Loading data 'subXX_dayXX_raweeg.mat'
    % Step 2: Remove low frequency drifts 'subXX_dayXX_highpass.mat'
    % Step 3: Epoch data 'subXX_dayXX_epoched.mat'

    % File names
    fName.folder = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/day' num2str(p.day, '%02d')];
    if ~exist(fName.folder, 'dir')
        mkdir(fName.folder)
    end
    fName.general = [fName.folder '/sub' num2str(p.subjID, '%02d') '_day' num2str(p.day, '%02d')];
    fName.concat = [fName.general '.vhdr'];
    fName.load = [fName.general '_raweeg.mat'];
    fName.bandpass = [fName.general '_bandpass.mat'];
    fName.epoched_prointoVF = [fName.general '_epoched_prointoVF.mat'];
    fName.epoched_prooutVF = [fName.general '_epoched_prooutVF.mat'];
    fName.epoched_antiintoVF = [fName.general '_epoched_antiintoVF.mat'];
    fName.epoched_antioutVF = [fName.general '_epoched_antioutVF.mat'];

    %% Concatenate EEG data
    if any(strcmp(steps, 'concat'))
        if ~exist(fName.concat, 'file')
            disp('Concatenated file does not exist. Concatenating EEG data.')
            tic
            ConcatEEG(p, fName);
            toc
        else
            disp('Concatenated file exists. Skipping this step.')
        end
    end

    %% Creating mat file from EEG data
    if any(strcmp(steps, 'raweeg'))
        if ~exist(fName.load, 'file')
            % Importing data
            disp('Raw file does not exist. Creating mat file.')
            tic
            cfg = [];
            cfg.dataset = fName.concat;
            cfg.demean = 'no';
            % cfg.derivative = 'yes';
            cfg.continuous = 'yes';
            data_eeg = ft_preprocessing(cfg);
            toc
            % Check data
            % figure(); plot(data_eeg.time{1}, data_eeg.trial{1}(1:10, :))
            save(fName.load, 'data_eeg', '-v7.3')
        else
            if ~exist(fName.bandpass, 'file') && ~exist(fName.epoched_prointoVF, 'file')
                disp('Raw file exists, importing mat file.')
                load(fName.load)
            else
                disp('Raw file exists, but not loading it.')
            end
        end
    end

    %% Bandpass filter
    if any(strcmp(steps, 'bandpass'))
        if ~exist(fName.bandpass, 'file')
            disp('Bandpass filtered data does not exist. Applying band pass filter.')
            tic
            cfg = [];
            cfg.reref = 'yes';
            cfg.refchannel = {'TP9', 'TP10'};
            cfg.hpfreq = 1;
            cfg.hpfilter = 'yes';
            cfg.lpfreq = 70;
            cfg.lpfilter = 'yes';
            data_eeg = ft_preprocessing(cfg, data_eeg);
            toc
            save(fName.bandpass, 'data_eeg', '-v7.3')
        else
            if ~exist(fName.epoched_prointoVF, 'file')
                disp('Highpass file exists, importing mat file.')
                load(fName.bandpass)
            else
                disp('Highpass file exists, but not loading it.')
            end
        end
    end

    %cfg = []; cfg.viewmode = 'butterfly'; ft_databrowser(cfg, data_eeg_reref)
    %% Epoch
    if any(strcmp(steps, 'epoch'))
        if ~exist(fName.epoched_prointoVF, 'file') || ~exist(fName.epoched_prooutVF, 'file') %|| ...
            %~exist(fName.epoched_antiintoVF, 'file') || ~exist(fName.epoched_antioutVF, 'file')
            disp('Epoching the data.')
            tic
            cfg_epoch = [];
            cfg_epoch.dataset = fName.concat;
            cfg_epoch.trialfun = 'ft_trialfun_general';
            cfg_epoch.trialdef.eventtype = 'Stimulus';
            cfg_epoch.trialdef.prestim = 1;
            cfg_epoch.trialdef.poststim = 6.5;

            cfg_epoch.trialdef.eventvalue = {'S 11'};
            cfg = ft_definetrial(cfg_epoch);
            data_eeg_prointoVF = ft_redefinetrial(cfg, data_eeg);

            cfg_epoch.trialdef.eventvalue = {'S 12'};
            cfg = ft_definetrial(cfg_epoch);
            data_eeg_prooutVF = ft_redefinetrial(cfg, data_eeg);

            %         cfg_epoch.trialdef.eventvalue = {'S 13'};
            %         cfg = ft_definetrial(cfg_epoch);
            %         data_eeg_antioutVF = ft_redefinetrial(cfg, data_eeg);
            %
            %         cfg_epoch.trialdef.eventvalue = {'S 14'};
            %         cfg = ft_definetrial(cfg_epoch);
            %         data_eeg_antiintoVF = ft_redefinetrial(cfg, data_eeg);
            toc
            save(fName.epoched_prointoVF, 'data_eeg_prointoVF', '-v7.3')
            save(fName.epoched_prooutVF, 'data_eeg_prooutVF', '-v7.3')
            %         save(fName.epoched_antiintoVF, 'data_eeg_antioutVF', '-v7.3')
            %         save(fName.epoched_antioutVF, 'data_eeg_antiintoVF', '-v7.3')
        else
            disp('Epoched files exist, importing mat files.')
            load(fName.epoched_prointoVF)
            load(fName.epoched_prooutVF)
            %         load(fName.epoched_antiintoVF)
            %         load(fName.epoched_antioutVF)
        end
    end
%     if day == NoTMSdays
%         data_eeg_control_prointoVF = data_eeg_prointoVF;
%         data_eeg_control_prooutVF = data_eeg_prooutVF;
%     else
%         data_eeg_TMS_prointoVF_holder(tms_day_counter) = data_eeg_prointoVF;
%         data_eeg_TMS_prooutVF_holder(tms_day_counter) = data_eeg_prooutVF;
%         tms_day_counter = tms_day_counter + 1;
%     end

end
% end_sample_prointoVF1 = data_eeg_TMS_prointoVF_holder(1).sampleinfo(end, 2);
% end_sample_prooutVF1 = data_eeg_TMS_prooutVF_holder(1).sampleinfo(end, 2);
% end_sample_1 = max(end_sample_prointoVF1, end_sample_prooutVF1);
% data_eeg_TMS_prointoVF_holder(2).sampleinfo = data_eeg_TMS_prointoVF_holder(2).sampleinfo + end_sample_1;
% data_eeg_TMS_prooutVF_holder(2).sampleinfo = data_eeg_TMS_prooutVF_holder(2).sampleinfo + end_sample_1;


% cfg = [];
% cfg.keepsampleinfo = 'no';
% data_eeg_TMS_prointoVF = ft_appenddata(cfg, data_eeg_TMS_prointoVF_holder(1), data_eeg_TMS_prointoVF_holder(2));
% data_eeg_TMS_prooutVF = ft_appenddata(cfg, data_eeg_TMS_prooutVF_holder(1), data_eeg_TMS_prooutVF_holder(2));
% 
% fName.TFR_control_early_prointoVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_control_early_prointoVF.mat'];
% fName.TFR_control_early_prooutVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_control_early_prooutVF.mat'];
% fName.TFR_TMS_early_prointoVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_TMS_early_prointoVF.mat'];
% fName.TFR_TMS_early_prooutVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_TMS_early_prooutVF.mat'];
% fName.TFR_control_late_prointoVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_control_late_prointoVF.mat'];
% fName.TFR_control_late_prooutVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_control_late_prooutVF.mat'];
% fName.TFR_TMS_late_prointoVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_TMS_late_prointoVF.mat'];
% fName.TFR_TMS_late_prooutVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_TMS_late_prooutVF.mat'];
% 
% if any(strcmp(steps, 'TFR'))
%     if ~exist(fName.TFR_control_early_prointoVF, 'file') || ~exist(fName.TFR_control_early_prooutVF, 'file') || ...
%             ~exist(fName.TFR_TMS_early_prointoVF, 'file') || ~exist(fName.TFR_TMS_early_prooutVF, 'file') || ...
%             ~exist(fName.TFR_control_late_prointoVF, 'file') || ~exist(fName.TFR_control_late_prooutVF, 'file') || ...
%             ~exist(fName.TFR_TMS_late_prointoVF, 'file') || ~exist(fName.TFR_TMS_late_prooutVF, 'file')
%         tic
%         cfg = [];
% 
%         cfg.output = 'pow';
%         cfg.channel = 'all';
%         cfg.method = 'wavelet';
%         cfg.taper = 'hanning';
%         cfg.foilim = [4 40];
%         cfg.toi = 0:0.1:2.3;
%         cfg.trials = 'all';
%         cfg.keeptrials = 'yes';
%         TFR_control_early_prointoVF = ft_freqanalysis(cfg, data_eeg_control_prointoVF);
%         TFR_control_early_prooutVF = ft_freqanalysis(cfg, data_eeg_control_prooutVF);
%         TFR_TMS_early_prointoVF = ft_freqanalysis(cfg, data_eeg_TMS_prointoVF);
%         TFR_TMS_early_prooutVF = ft_freqanalysis(cfg, data_eeg_TMS_prooutVF);
% 
% 
%         cfg = [];
%         cfg.output = 'pow';
%         cfg.channel = 'all';
%         cfg.method = 'wavelet';
%         cfg.taper = 'hanning';
%         cfg.foilim = [4 40];
%         cfg.toi = 2.8:0.1:5.0;
%         cfg.trials = 'all';
%         cfg.keeptrials = 'yes';
%         TFR_control_late_prointoVF = ft_freqanalysis(cfg, data_eeg_control_prointoVF);
%         TFR_control_late_prooutVF = ft_freqanalysis(cfg, data_eeg_control_prooutVF);
%         TFR_TMS_late_prointoVF = ft_freqanalysis(cfg, data_eeg_TMS_prointoVF);
%         TFR_TMS_late_prooutVF = ft_freqanalysis(cfg, data_eeg_TMS_prooutVF);
%         toc
% 
%         save(fName.TFR_control_early_prointoVF, 'TFR_control_early_prointoVF', '-v7.3')
%         save(fName.TFR_control_early_prooutVF, 'TFR_control_early_prooutVF', '-v7.3')
%         save(fName.TFR_TMS_early_prointoVF, 'TFR_TMS_early_prointoVF', '-v7.3')
%         save(fName.TFR_TMS_early_prooutVF, 'TFR_TMS_early_prooutVF', '-v7.3')
%         save(fName.TFR_control_late_prointoVF, 'TFR_control_late_prointoVF', '-v7.3')
%         save(fName.TFR_control_late_prooutVF, 'TFR_control_late_prooutVF', '-v7.3')
%         save(fName.TFR_TMS_late_prointoVF, 'TFR_TMS_late_prointoVF', '-v7.3')
%         save(fName.TFR_TMS_late_prooutVF, 'TFR_TMS_late_prooutVF', '-v7.3')
%     else
%         disp('TFRs exist, importing mat files.')
%         load(fName.TFR_control_early_prointoVF)
%         load(fName.TFR_control_early_prooutVF)
%         load(fName.TFR_TMS_early_prointoVF)
%         load(fName.TFR_TMS_early_prooutVF)
%         load(fName.TFR_control_late_prointoVF)
%         load(fName.TFR_control_late_prooutVF)
%         load(fName.TFR_TMS_late_prointoVF)
%         load(fName.TFR_TMS_late_prooutVF)
%     end
% end
% 
% 
% fName.TFR_control_prointoVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_control_prointoVF.mat'];
% fName.TFR_control_prooutVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_control_prooutVF.mat'];
% fName.TFR_TMS_prointoVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_TMS_prointoVF.mat'];
% fName.TFR_TMS_prooutVF = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/sub' num2str(p.subjID, '%02d') '_TFR_TMS_prooutVF.mat'];
% 
% if any(strcmp(steps, 'TFRfull'))
%     if ~exist(fName.TFR_control_prointoVF, 'file') || ~exist(fName.TFR_control_prooutVF, 'file') || ...
%             ~exist(fName.TFR_TMS_prointoVF, 'file') || ~exist(fName.TFR_TMS_prooutVF, 'file')
%         tic
% 
%         cfg                        = [];
%         cfg.output                 = 'pow';
%         cfg.channel                = 'all';
%         cfg.method                 = 'wavelet';
%         cfg.taper                  = 'hanning';
%         cfg.foilim                 = [4 40];
%         cfg.toi                    = 0:0.1:6;
%         cfg.trials                 = 'all';
%         cfg.keeptrials             = 'yes';
%         cfg.pad                    = 'nextpow2';
%         TFR_control_prointoVF      = ft_freqanalysis(cfg, data_eeg_control_prointoVF);
%         TFR_control_prooutVF       = ft_freqanalysis(cfg, data_eeg_control_prooutVF);
%         TFR_TMS_prointoVF          = ft_freqanalysis(cfg, data_eeg_TMS_prointoVF);
%         TFR_TMS_prooutVF           = ft_freqanalysis(cfg, data_eeg_TMS_prooutVF);
%         toc
% 
%         save(fName.TFR_control_prointoVF, 'TFR_control_prointoVF', '-v7.3')
%         save(fName.TFR_control_prooutVF, 'TFR_control_prooutVF', '-v7.3')
%         save(fName.TFR_TMS_prointoVF, 'TFR_TMS_prointoVF', '-v7.3')
%         save(fName.TFR_TMS_prooutVF, 'TFR_TMS_prooutVF', '-v7.3')
%     else
%         disp('TFRs exist, importing mat files.')
%         load(fName.TFR_control_prointoVF)
%         load(fName.TFR_control_prooutVF)
%         load(fName.TFR_TMS_prointoVF)
%         load(fName.TFR_TMS_prooutVF)
%     end
% end
% %%
% % if any(strcmp(steps, 'TFR'))
% %     if ~exist(fName.TFR_prointoVF, 'file') || ~exist(fName.TFR_prooutVF, 'file') %|| ...
% %            % ~exist(fName.TFR_antiintoVF, 'file') || ~exist(fName.TFR_antioutVF, 'file')
% %         disp('Creating TFR.')
% %         tic
% %         cfg = [];
% %         cfg.output = 'pow';
% %         cfg.channel = 'all';
% %         cfg.method = 'wavelet';
% %         cfg.taper = 'hanning';
% %         cfg.foilim = [4 40];
% %         cfg.toi = 0:0.1:6;
% %         cfg.trials = 'all';
% %         cfg.keeptrials = 'yes';
% %         TFR_prointoVF = ft_freqanalysis(cfg, data_eeg_prointoVF);
% %         TFR_prooutVF = ft_freqanalysis(cfg, data_eeg_prooutVF);
% %         %TFR_antiintoVF = ft_freqanalysis(cfg, data_eeg_antiintoVF);
% %         %TFR_antioutVF = ft_freqanalysis(cfg, data_eeg_antioutVF);
% %         toc
% %         save(fName.TFR_prointoVF, 'TFR_prointoVF', '-v7.3')
% %         save(fName.TFR_prooutVF, 'TFR_prooutVF', '-v7.3')
% %         %save(fName.TFR_antiintoVF, 'TFR_antiintoVF', '-v7.3')
% %         %save(fName.TFR_antioutVF, 'TFR_antioutVF', '-v7.3')
% %     else
% %         disp('TFR files exist, importing mat files.')
% %         load(fName.TFR_prointoVF)
% %         load(fName.TFR_prooutVF)
% %         %load(fName.TFR_antiintoVF)
% %         %load(fName.TFR_antioutVF)
% %     end
% % end
% disp('We are done! Woosh, that was some work.')
% end
% 
% % cfg = [];
% % cfg.
% %
% % % Temp time-lock analysis
% % cfg = [];
% % cfg.preproc.demean = 'yes';
% % cfg.preproc.baseline = [-1.5 -0.5];
% % data_tms_avg = ft_timelockanalysis(cfg, data_eeg);
% %
% % close all;
% % for i=1:numel(data_tms_avg.label)                   % Loop through all channels
% %     figure;
% %     plot(data_tms_avg.time, data_tms_avg.avg(i,:)); % Plot this channel versus time
% %     %xlim([-0.1 0.6]);     % Here we can specify the limits of what to plot on the x-axis
% %     ylim([-23 15]);       % Here we can specify the limits of what to plot on the y-axis
% %     title(['Channel ' data_tms_avg.label{i}]);
% %     ylabel('Amplitude (uV)')
% %     xlabel('Time (s)');
% % end
% %
% % channel = 'O2';
% %
% % figure;
% % channel_idx = find(strcmp(channel, data_tms_avg.label));
% % plot(data_tms_avg.time, data_tms_avg.avg(channel_idx,:));  % Plot all data
% % xlim([3.5 3.9]);    % Here we can specify the limits of what to plot on the x-axis
% % ylim([-23 15]);     % Here we can specify the limits of what to plot on the y-axis
% % title(['Channel ' data_tms_avg.label{channel_idx}]);
% % ylabel('Amplitude (uV)')
% % xlabel('Time (s)');
% %
% % hold on; % Plotting new data does not remove old plot
% %
% % % Specify time-ranges to higlight
% % ringing  = [-0.0002 0.0044];
% % muscle   = [ 0.0044 0.015 ];
% % decay    = [ 0.015  0.200 ];
% % recharge = [ 0.4994 0.5112];
% %
% % colors = 'rgcm';
% % labels = {'ringing','muscle','decay','recharge'};
% % artifacts = [ringing; muscle; decay; recharge];
% %
% % for i=1:numel(labels)
% %   highlight_idx = [nearest(data_tms_avg.time,artifacts(i,1)) nearest(data_tms_avg.time,artifacts(i,2)) ];
% %   plot(data_tms_avg.time(highlight_idx(1):highlight_idx(2)), data_tms_avg.avg(channel_idx,highlight_idx(1):highlight_idx(2)),colors(i));
% % end
% % legend(['raw data', labels]);
% %
% % % %% Plot trials (first pass)
% % cfg = [];
% % cfg.viewmode = 'butterfly';
% % ft_databrowser(cfg, data_eeg)
% %
% % cfg = [];
% % test_data = ft_rejectvisual(cfg, data_eeg)
% 
% %% Removing line noise
% % NOTE: RUN AFTER LOOKING AT EPOCHED DATA!
% % tic
% % cfg = [];
% % cfg.dftfilter = 'yes';
% % cfg.dftfreq = [50 100];
% % data_eeg = ft_preprocessing(cfg, data_eeg);
% % toc
% %
% % %% Divide data by conditions
% % data_eeg_prointoVF = block_data(data_eeg, prointoVF_idx_EEG);
% % data_eeg_prooutVF = block_data(data_eeg, prooutVF_idx_EEG);
% % data_eeg_antiintoVF = block_data(data_eeg, antiintoVF_idx_EEG);
% % data_eeg_antioutVF = block_data(data_eeg, antioutVF_idx_EEG);
% % %% Rejecting trials
% % cfg = [];
% % cfg.method = 'summary';
% % cfg.layout = 'acticap-64_md.mat';
% % cfg.channel = 'all';
% % data_eeg_prointoVF = ft_rejectvisual(cfg, data_eeg_prointoVF);
% % data_eeg_prooutVF = ft_rejectvisual(cfg, data_eeg_prooutVF);
% % data_eeg_antiintoVF = ft_rejectvisual(cfg, data_eeg_antiintoVF);
% % data_eeg_antioutVF = ft_rejectvisual(cfg, data_eeg_antioutVF);
% %
% % %% Time-frequency analysis
% % cfg = [];
% % cfg.output = 'pow';
% % cfg.channel = 'all';
% % cfg.method = 'wavelet';
% % cfg.taper = 'hanning';
% % cfg.toi = -0.7:0.2:7.5;
% % cfg.foilim = [4, 30];
% % cfg.trials = 'all';
% % saveName = [direct.saveEEG '/sub' num2str(subjID, '%02d') '_day' num2str(day, '%02d') '_TFR.mat'];
% %
% % if ~exist(saveName, 'file')
% %     disp('TFR file does not exist. Creating mat file.')
% %     TFR_prointoVF = ft_freqanalysis(cfg, data_eeg_prointoVF);
% %     TFR_prooutVF = ft_freqanalysis(cfg, data_eeg_prooutVF);
% %     TFR_antiintoVF = ft_freqanalysis(cfg, data_eeg_antiintoVF);
% %     TFR_antioutVF = ft_freqanalysis(cfg, data_eeg_antioutVF);
% %     save(saveName, 'TFR_prointoVF', 'TFR_prooutVF', 'TFR_antiintoVF', 'TFR_antioutVF', '-v7.3')
% % else
% %     disp('TFR file exists, importing mat file.')
% %     load(saveName)
% % end
% %
% % %% Topoplot
% % cfg = [];
% % cfg.baseline = 'no';%[-0.5 -0.1];
% % cfg.baselinetype = 'relative';
% % cfg.xlim = [1, 5];
% % cfg.ylim = [8 12];
% % %cfg.zlim =
% % cfg.marker = 'on';
% % cfg.layout = 'acticap-64_md.mat';
% % cfg.colorbar = 'yes';
% % figure(); ft_topoplotTFR(cfg, TFR_prointoVF)
% % figure(); ft_topoplotTFR(cfg, TFR_prooutVF)
% % figure(); ft_topoplotTFR(cfg, TFR_antiintoVF)
% % figure(); ft_topoplotTFR(cfg, TFR_antioutVF)
% %
% % %% Multiplot
% % cfg = [];
% % cfg.baseline = 'no';%[-0.5 -0.1];
% % cfg.baselinetype = 'absolute';
% % cfg.showlabels = 'yes';
% % cfg.layout = 'acticap-64_md.mat';
% % cfg.colorbar = 'yes';
% % cfg.zlim = [0 10^4];
% % figure(); ft_multiplotTFR(cfg, TFR_prointoVF)
% % figure(); ft_multiplotTFR(cfg, TFR_prooutVF)
% % figure(); ft_multiplotTFR(cfg, TFR_antiintoVF)
% % figure(); ft_multiplotTFR(cfg, TFR_antioutVF)
% %
% % %% Removing LM and RM electrodes
% % cfg = [];
% % cfg.channel = setdiff(1:66, [64, 65]);
% % data_eeg = ft_selectdata(cfg, data_eeg);
% % %% Referencing to Mastoids
% % cfg = [];
% % cfg.channel = 'all';
% % cfg.reref = 'yes';
% % cfg.implicitref = 'Cz';
% % cfg.refchannel = {'FT9', 'FT10'};
% % data_eeg = ft_preprocessing(cfg, data_eeg);
% % %% ERP analysis
% % cfg = [];
% % cfg.trials = prointoVF_idx;
% % ERP_prointoVF = ft_timelockanalysis(cfg, data_eeg_prointoVF);
% % cfg.trials = prooutVF_idx;
% % ERP_prooutVF = ft_timelockanalysis(cfg, data_eeg_prooutVF);
% % cfg.trials = antiintoVF_idx;
% % ERP_antiintoVF = ft_timelockanalysis(cfg, data_eeg_antiintoVF);
% % cfg.trials = antioutVF_idx;
% % ERP_antioutVF = ft_timelockanalysis(cfg, data_eeg_antioutVF);
% %
% % cfg = [];
% % cfg.parameter = 'powspctrm';
% % cfg.trials = 'all';
% % cfg.channel = {'PO7', 'PO3', 'O1'};
% % cfg.zlim = [0, 10^4]
% % ft_singleplotTFR(cfg,TFR_prointoVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
% % ft_singleplotTFR(cfg,TFR_prooutVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
% % ft_singleplotTFR(cfg,TFR_antiintoVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
% % ft_singleplotTFR(cfg,TFR_antioutVF);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
% %
% % cfg.channel = 'all';%{'PO4', 'PO8', 'O2'};
% % ft_singleplotTFR(cfg,TFR_prointoVF);pbaspect([1 1 1]);
% %
% %
% % ft_singleplotTFR(cfg,TFR_prooutVF);pbaspect([1 1 1]);
% % ft_singleplotTFR(cfg,TFR_antiintoVF);pbaspect([1 1 1]);
% % ft_singleplotTFR(cfg,TFR_antioutVF);pbaspect([1 1 1]);
% %
% % %figure();
% % %plot(data_eeg.time{1}, data_eeg.trial{1});
% % %hold on;
% % %plot(data_eeg.time{1}, data_eeg.trial{1}(12, :), 'g');
% % % blurb =  NaN(9, 400);
% % % for ii = 1:size(cfg.event, 2)
% % %     for evenum = 1:9
% % %         flag_sent = ['S  '  num2str(evenum)];
% % %         if strcmp(cfg.event(ii).value, flag_sent)
% % %             blurb(evenum, ii) = 1;
% % %         end
% % %     end
% % % end
% % % for evenum = 1:9
% % %     evenum
% % %     nansum(blurb(evenum, :))
% % % end