function create_TFplots(p, data)
%% Create time-frequency plots
%close all;

if str2num(p.subjID)               == 1 % All done
    selected_hemi                  = 'left';
    flag_chan_control              = {};
    flag_trial_control_prointoVF   = [61 62 63 65 81 83 84 85 87 99];
    flag_trial_control_prooutVF    = [2 43 61 62 63 69 81 82 84 94];
    flag_chan_TMS                  = {'PO3'};
    flag_trial_TMS1_prointoVF      = [86 87 94];
    flag_trial_TMS2_prointoVF      = [81 85 87];
    flag_trial_TMS1_prooutVF       = [6 42 61];
    flag_trial_TMS2_prooutVF       = [70];
elseif str2num(p.subjID)           == 3 % Not sure what is done, must redo this subject
    selected_hemi                  = 'right';
    flag_chan_control              = {'O2', 'PO4'};
    flag_trial_control_prointoVF   = [8 41 56 97 98 99];
    flag_trial_control_prooutVF    = [41 66 68 69 74 77 78 79 80 81];
    flag_chan_TMS                  = {'P2', 'O2', 'PO4'};
    flag_trial_TMS1_prointoVF      = [7 21 26 28 29 31 74 84];
    flag_trial_TMS2_prointoVF      = [13 81 83];
    flag_trial_TMS1_prooutVF       = [];
    flag_trial_TMS2_prooutVF       = [];
elseif str2num(p.subjID)           == 6 % Done with both for No TMS, only intoVF for TMS
    selected_hemi                  = 'right';
    flag_chan_control              = {'O1'};
    flag_trial_control_prointoVF   = [41 45 47];
    flag_trial_control_prooutVF    = [19 24 41];
    flag_chan_TMS                  = {'O2', 'PO4', 'P2', 'PO7'};
    flag_trial_TMS1_prointoVF      = [21];
    flag_trial_TMS2_prointoVF      = [7 21 22 23 24 25 26 99 100];
    flag_trial_TMS1_prooutVF       = [];
    flag_trial_TMS2_prooutVF       = [];
elseif str2num(p.subjID)           == 8 % Done with both for No TMS, only intoVF for TMS
    selected_hemi                  = 'right';
    flag_chan_control              = {};
    flag_trial_control_prointoVF   = [9 14 15 60 64 74 82 84 85 90];
    flag_trial_control_prooutVF    = [2 59 69 73 80 85 87 88 93 96];
    flag_chan_TMS                  = {'PO4', 'O2', 'PO7'};
    flag_trial_TMS1_prointoVF      = [4 6 14 15 21 23 25 26 27 41 57 58 59 ...
                                      69 70 71 72 73 74 75 76 77 78 79 80 82 ...
                                      93 95 96 97 98 99 100];
    flag_trial_TMS2_prointoVF      = [3 5 14 15 16 17 37 53 63 64 74 79];
    flag_trial_TMS1_prooutVF       = [];
    flag_trial_TMS2_prooutVF       = [];
elseif str2num(p.subjID)           == 12 % Done with both for No TMS, only intoVF for TMS
    selected_hemi                  = 'left';
    flag_chan_control              = {'O1', 'PO7', 'PO3', 'PO4', 'O2'};
    flag_trial_control_prointoVF   = [5 10 11 16 23 28 30 37 41 60 90 98];
    flag_trial_control_prooutVF    = [14 22 50 65 66 83 96 99];
    flag_chan_TMS                  = {'PO7', 'O2', 'O1', 'P8',}; % 'PO3'
    flag_trial_TMS1_prointoVF      = [3 4 16 21 27 30 33 35 37 41 42 49 55 ...
                                      57 60 65 66 67 69 79 81 83];
    flag_trial_TMS2_prointoVF      = [7 21 39 43 51 73 86];
    flag_trial_TMS1_prooutVF       = [];
    flag_trial_TMS2_prooutVF       = [];
elseif str2num(p.subjID)           == 13 % Done with both for No TMS, only intoVF for TMS, this subject had bad occipital, probably best to eliminate from analysis for now
    selected_hemi                  = 'left';
    flag_chan_control              = {'O2', 'PO4', 'PO8', 'PO7', 'O1', 'P3', ...
                                      'PO3', 'P8'};
    flag_trial_control_prointoVF   = [5 9 11 37 42 44 49 56 59 62 78 80 85 ...
                                      86 89 92];
    flag_trial_control_prooutVF    = [10 11 13 20 23 28 30 37 39 40 42 48 54 ...
                                      58 59 71 73 76 80 83 84 86 93];
    flag_chan_TMS                  = {'P3', 'O1', 'PO7', 'PO3', 'P7', 'PO4', ...
                                      'PO8', 'O2'};
    flag_trial_TMS1_prointoVF      = [18 19 21 46 54 70 72];
    flag_trial_TMS2_prointoVF      = [1 37 54 68 69 72 78 79 82 83 92 100];
    flag_trial_TMS1_prooutVF       = [];
    flag_trial_TMS2_prooutVF       = [];
elseif str2num(p.subjID)           == 14 % Done with both for No TMS, only intoVF for TMS
    selected_hemi                  = 'right';
    flag_chan_control              = {'P4', 'PO8'};
    flag_trial_control_prointoVF   = [33 34 35 36 39 40 47 53 54 60 66 69 73 ...
                                      74 75 76 77 83 84 85 86 87 89 91 92 94 ...
                                      95 98];
    flag_trial_control_prooutVF    = [32 45 50 59 60 69 70 71 72 73 77 79 80 ...
                                      81 85 86 87 88 89 92 94 95 96 97];
    flag_chan_TMS                  = {'O2', 'PO4', 'P2', 'P7'};
    flag_trial_TMS1_prointoVF      = [29 30 31 32 36 37 38 39 40 54 55 56 59 ...
                                      60 75 78 80 99 100];
    flag_trial_TMS2_prointoVF      = [61 62];
    flag_trial_TMS1_prooutVF       = [];
    flag_trial_TMS2_prooutVF       = [];
elseif str2num(p.subjID)           == 15 % Done with both for No TMS, only intoVF for TMS
    selected_hemi                  = 'right';
    flag_chan_control              = {'O2', 'PO4', 'P2'};
    flag_trial_control_prointoVF   = [14 21 22 39 61 66 72 73 83 86 94 100];
    flag_trial_control_prooutVF    = [1 19 22 23 60 72 85 88];
    flag_chan_TMS                  = {'O2', 'PO4', 'P1', 'P2'};
    flag_trial_TMS1_prointoVF      = [18 19 20 80 83 85 86 87 88 89 90 91 92 ...
                                      93 94 95 96 97 98 99 100];
    flag_trial_TMS2_prointoVF      = [3 13 21 22 41 51 63 67 96];
    flag_trial_TMS1_prooutVF       = [];
    flag_trial_TMS2_prooutVF       = [];
elseif str2num(p.subjID)           == 16 % Done with both for No TMS, only intoVF for TMS
    selected_hemi                  = 'left';
    flag_chan_control              = {'O2', 'P1', 'P3'};
    flag_trial_control_prointoVF   = [55 58 61 74 78 92 95 99];
    flag_trial_control_prooutVF    = [1 16 19 25 32 41 42 60 61 62 65 67 70 ...
                                      76 88 91];
    flag_chan_TMS                  = {'PO8', 'P3', 'P1', 'O1'};
    flag_trial_TMS1_prointoVF      = [1 2 3 7 16 27 28 32 36 38 41 43 52 59 ...
                                      61 62 63 64 65 66 67 68 74 80 81 82 83 ...
                                      84 85 86];
    flag_trial_TMS2_prointoVF      = [6 21 22 29 36 37 41 42 45 52 58 60 69 ...
                                      77 79 80 81 95];
    flag_trial_TMS1_prooutVF       = [];
    flag_trial_TMS2_prooutVF       = [];
end

right_elecs                        = {'P2', 'P4', 'P6', 'P8', 'PO4', 'PO8', 'O2'};
left_elecs                         = {'P1', 'P3', 'P5', 'P7', 'PO3', 'PO7', 'O1'};
flag_trial_TMS_prointoVF           = [flag_trial_TMS1_prointoVF 100+flag_trial_TMS2_prointoVF];
% flag_trial_TMS_prooutVF            = [flag_trial_TMS1_prooutVF 100+flag_trial_TMS2_prooutVF];

%% Run time-frequency analysis for No TMS
cfg                                = [];
cfg.trials                         = setdiff(1:length(data.control.trialinfo), ...
                                     flag_trial_control_prointoVF);
cfg.avgoverchan                    = 'yes';

if strcmp(selected_hemi, 'left')
    cfg.channel                    = right_elecs(~ismember(right_elecs, flag_chan_control));
    control_ipsi                   = ft_selectdata(cfg, data.control);
    control_ipsi.label             = {'occ'};
    cfg.channel                    = left_elecs(~ismember(left_elecs, flag_chan_control));
    control_contra                 = ft_selectdata(cfg, data.control);
    control_contra.label           = {'occ'};
elseif strcmp(selected_hemi, 'right')
    cfg.channel                    = left_elecs(~ismember(left_elecs, flag_chan_control));
    control_ipsi                   = ft_selectdata(cfg, data.control);
    control_ipsi.label             = {'occ'};
    cfg.channel                    = right_elecs(~ismember(right_elecs, flag_chan_control));
    control_contra                 = ft_selectdata(cfg, data.control);
    control_contra.label           = {'occ'};
end

cfg                        = [];
cfg.output                 = 'pow';
cfg.method                 = 'wavelet';
cfg.taper                  = 'hanning';
cfg.foilim                 = [4 40];
cfg.toi                    = 0:0.05:4.7;
cfg.keeptrials             = 'yes';
cfg.pad                    = 'nextpow2';
TFR_control_ipsi           = ft_freqanalysis(cfg, control_ipsi);
TFR_control_contra         = ft_freqanalysis(cfg, control_contra);

cfg                        = [];
cfg.parameter              = 'powspctrm'; 
cfg.operation              = 'subtract';
TFR_control_diff           = ft_math(cfg, TFR_control_contra, TFR_control_ipsi);

%% Run time-frequency analysis for TMS
cfg                                = [];
cfg.trials                         = setdiff(1:length(data.TMS.trialinfo), ...
                                     flag_trial_TMS_prointoVF);
cfg.avgoverchan                    = 'yes';

if strcmp(selected_hemi, 'left')
    cfg.channel                    = right_elecs(~ismember(right_elecs, flag_chan_TMS));
    TMS_ipsi                       = ft_selectdata(cfg, data.TMS);
    TMS_ipsi.label                 = {'occ'};
    cfg.channel                    = left_elecs(~ismember(left_elecs, flag_chan_TMS));
    TMS_contra                     = ft_selectdata(cfg, data.TMS);
    TMS_contra.label               = {'occ'};
elseif strcmp(selected_hemi, 'right')
    cfg.channel                    = left_elecs(~ismember(left_elecs, flag_chan_TMS));
    TMS_ipsi                       = ft_selectdata(cfg, data.TMS);
    TMS_ipsi.label                 = {'occ'};
    cfg.channel                    = right_elecs(~ismember(right_elecs, flag_chan_TMS));
    TMS_contra                     = ft_selectdata(cfg, data.TMS);
    TMS_contra.label               = {'occ'};
end

cfg                        = [];
cfg.output                 = 'pow';
cfg.method                 = 'wavelet';
cfg.taper                  = 'hanning';
cfg.foilim                 = [4 40];
cfg.toi                    = 0:0.05:4.7;
cfg.keeptrials             = 'yes';
cfg.pad                    = 'nextpow2';
TFR_TMS_ipsi               = ft_freqanalysis(cfg, TMS_ipsi);
TFR_TMS_contra             = ft_freqanalysis(cfg, TMS_contra);
TFR_TMS_ipsi.powspctrm(:, :, :, 45:61) = min(TFR_TMS_ipsi.powspctrm, [], 'all');
TFR_TMS_contra.powspctrm(:, :, :, 45:61) = min(TFR_TMS_contra.powspctrm, [], 'all');

cfg                        = [];
cfg.parameter              = 'powspctrm'; 
cfg.operation              = 'subtract';
TFR_TMS_diff               = ft_math(cfg, TFR_TMS_contra, TFR_TMS_ipsi);

% TFR_TMS_ipsi.powspctrm(:, :, :, 47:59) = min(TFR_TMS_ipsi.powspctrm, [], 'all');
% TFR_TMS_contra.powspctrm(:, :, :, 47:59) = min(TFR_TMS_contra.powspctrm, [], 'all');
% TFR_TMS_diff.powspctrm(:, :, :, 47:59) = min(TFR_TMS_diff.powspctrm, [], 'all');

%% Plot the TFA results
figure('Position', [100, 100, 1200, 600]);
sgtitle(['subject: ' num2str(p.subjID)])
subplot(2, 3, 1)
imagesc(TFR_control_ipsi.time, TFR_control_ipsi.freq, squeeze(mean(TFR_control_ipsi.powspctrm, 1)));
title('No TMS Ipsi')
axis xy; colorbar;

subplot(2, 3, 2)
imagesc(TFR_control_contra.time, TFR_control_contra.freq, squeeze(mean(TFR_control_contra.powspctrm, 1)));
title('No TMS Contra')
axis xy; colorbar; 

subplot(2, 3, 3)
imagesc(TFR_control_diff.time, TFR_control_diff.freq, squeeze(mean(TFR_control_diff.powspctrm, 1)));
title('No TMS (Ipsi - Contra)')
axis xy; colorbar; 

subplot(2, 3, 4)
imagesc(TFR_TMS_ipsi.time, TFR_TMS_ipsi.freq, squeeze(mean(TFR_TMS_ipsi.powspctrm, 1)));
title('TMS Ipsi')
axis xy; colorbar; caxis([0 45]);

subplot(2, 3, 5)
imagesc(TFR_TMS_contra.time, TFR_TMS_contra.freq, squeeze(mean(TFR_TMS_contra.powspctrm, 1)));
title('TMS Contra')
axis xy; colorbar;  caxis([0 45]);

subplot(2, 3, 6)
imagesc(TFR_TMS_diff.time, TFR_TMS_diff.freq, squeeze(mean(TFR_TMS_diff.powspctrm, 1)));
title('TMS (Ipsi - Contra)')
axis xy; colorbar; caxis([0 45]);
%%
end
% %% Time-frequency plots using imagesc
% figure;
% trls_good = setdiff(1:length(TFR_control_prointoVF.trialinfo), flag_trial_control_prointoVF);
% chans_good = right_elecs(~ismember(right_elecs, flag_chan_control));
% [~, indices] = ismember(chans_good, TFR_control_prointoVF.label);
% %subplot(1, 3, 1)
% ft_singleplotTFR(mean(TFR_control_prointoVF.powspctrm(trls_good, indices, :, :), [1, 2]))
% colorbar
% %set(gca, 'YDir', 'reverse');
%
%
% %%
% % figure;
% % ft_topoplotTFR(cfg, TFR_prointoVF);
% % figure;
% % ft_topoplotTFR(cfg, TFR_prooutVF);
% % figure;
% % ft_topoplotTFR(cfg, TFR_antiintoVF);
% % figure;
% % ft_topoplotTFR(cfg, TFR_antioutVF);
%
% cfg = [];
% cfg.xlim = [0:0.5:4.5];
% cfg.ylim = [8 12];
% cfg.operation = 'subtract';
% cfg.parameter = 'powspctrm';
% cfg.baseline = [-1 0];
% cfg.baselinetype = 'absolute';
% difference = ft_math(cfg, TFR_control_prointoVF, TFR_control_prooutVF);
% figure();
% cfg.layout       = 'acticap-64_md.mat';
% cfg.colormap = '*RdBu';
% ft_topoplotTFR(cfg, difference); colorbar;
%
%
% cfg = [];
% cfg.xlim = [0:0.5:4.5];
% cfg.ylim = [8 12];
% cfg.operation = 'subtract';
% cfg.parameter = 'powspctrm';
% cfg.baseline = [-1 0];
% cfg.baselinetype = 'absolute';
% difference = ft_math(cfg, TFR_TMS_prointoVF, TFR_TMS_prooutVF);
% figure();
% cfg.layout       = 'acticap-64_md.mat';
% cfg.colormap = '*RdBu';
% ft_topoplotTFR(cfg, difference); colorbar;
%
%
%
% cfg = [];
% %cfg.baseline     = [-1.5 0];
% %cfg.baselinetype = 'absolute';
% cfg.maskstyle    = 'saturation';
% %cfg.xlim = [0 2];
% cfg.xlim = [3.2 5];
% cfg.zlim         = [0 55];
% cfg.channel      = {'P2', 'P4', 'P6', 'P8', 'PO4', 'PO8', 'O2'};
% %cfg.channel      = {'P1', 'P3', 'P5', 'P7', 'PO3', 'PO7', 'O1'};
%
% cfg.layout       = 'acticap-64_md.mat';
% figure
% ft_singleplotTFR(cfg, TFR_TMS_late_prointoVF);
% %
% cfg = [];
% cfg.parameter = 'powspctrm';
% cfg.trials = 'all';
% cfg.channel = 'all';
% %cfg.zlim = [0, 10^4]
% ft_singleplotTFR(cfg,TFR_prointoVF_contra);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
%
% cfg = [];
% cfg.output = 'pow';
% cfg.channel = {'P2', 'P4', 'P6', 'P8', 'PO4', 'PO8'};
% cfg.method = 'mtmconvol';
% cfg.taper = 'hanning';
% cfg.foi = 2:2:40;
% cfg.toi = [-1.5:0.1:6];
% cfg.t_ftimwin = 10./cfg.foi;
% cfg.trials = 'all';
% cfg.keeptrials = 'yes';
% TFR_prointoVF_ipsi = ft_freqanalysis(cfg, data_eeg_prointoVF);
%
% cfg = [];
% cfg.parameter = 'powspctrm';
% cfg.trials = 'all';
% cfg.channel = 'all';
% %cfg.zlim = [0, 10^4]
% ft_singleplotTFR(cfg,TFR_prointoVF_ipsi);pbaspect([1 1 1]);xlabel('Time (s)');ylabel('Frequency (Hz)')
%
