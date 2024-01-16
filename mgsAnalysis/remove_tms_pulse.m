function data  = remove_tms_pulse(fName)
% Load up the raw data
cfg                                    = [];
cfg.dataset                            = fName.concat;
cfg.continuous                         = 'yes';
cfg.channel                            = {'all', '-LM', '-RM', '-TP9', '-TP10'};
data                                   = ft_preprocessing(cfg);

% Get samples around the TMS pulse
cfg.trialdef.prestim                   = -0.03;
cfg.trialdef.poststim                  = 0.25;
cfg.trialdef.eventtype                 = 'Stimulus';
cfg.trialdef.eventvalue                = {'S  3'};
cfg                                    = ft_definetrial(cfg);
trl_samps                              = cfg.trl;
trl_samps                              = trl_samps(:, 1:2);

for i                                  = size(trl_samps, 1):-1:1
    seg                                = trl_samps(i, :);
    data.trial{1}(:,seg(1):seg(2))     = NaN;
end

cfg                                    = [];
cfg.method                             = 'pchip';
cfg.prewindow                          = 0.1;
cfg.postwindow                         = 0.1;
data                                   = ft_interpolatenan(cfg, data);

cfg = [];
cfg.dataset                            = fName.concat;
cfg.continuous                         = 'yes';
cfg.trialdef.prestim                   = 0.5;
cfg.trialdef.poststim                  = 5.5;
cfg.trialdef.eventtype                 = 'Stimulus';
cfg.trialdef.eventvalue                = {'S  1'};
cfg                                    = ft_definetrial(cfg);
trlInf = cfg.trl;
cfg_new = [];
cfg_new.trl = trlInf;
epoced_dat = ft_redefinetrial(cfg_new, data);

median_arr = zeros(length(epoced_dat.label), length(epoced_dat.trialinfo));
ptimes = zeros(length(epoced_dat.trialinfo), 5);
for tt = 1:length(epoced_dat.trialinfo)
    median_arr(:, tt) = median(abs(epoced_dat.trial{tt}), 2);
    tms_samps = find(abs(epoced_dat.trial{tt}(1, :)) > 1.1 * median_arr(1, tt));
    tms_time = epoced_dat.time{tt}(tms_samps);
    diff_time = diff(tms_time);
    threshold = min(diff_time) * 1.1;
    start_idx = [1, find(diff_time > threshold) + 1];
    end_idx = [start_idx(2:end) - 1, length(tms_time)];
    pulse_dur = tms_time(end_idx) - tms_time(start_idx);

    ptimes(tt, :) = [tms_time(start_idx(1)) tms_time(end_idx(end)) pulse_dur];

    npulses = length(start_idx);
    if npulses ~= 3
        disp([tt, npulses])
    end
end


cfg = []; cfg.viewmode = 'vertical'; cfg.preproc.demean = 'yes'; ft_databrowser(cfg, epoced_dat);



% originalTime                           = 1:length(data.trial{1}) + sum(diff(trl_samps, 1, 2));
% newTime                                = setdiff(originalTime, trl_samps); 
% for i                                  = 1:size(trl_samps, 1)
%     segment                            = trl_samps(i, :);
%     startWindow                        = max(1, segment(1) - 10000);
%     endWindow = min(length(data.trial{1}), segment(2) + 10000);
% 
%     for j = 1:size(data.trial{1}, 1)
%         interpolationWindow = startWindow:endWindow;
%         dataWindow = data.trial{1}(j, interpolationWindow);
%         interpolatePoints = segment(1):segment(2);
%         interpolatePointsAdjusted = interpolatePoints - startWindow + 1;
%         data.trial{1}(j, segment(1):segment(2)) = interp1(interpolationWindow, dataWindow, interpolatePoints, 'spline');
%     end
% end

cfg_new                                = [];
cfg_new.trl                            = orig_trl;
epoched_data                           = ft_redefinetrial(cfg_new, data);

cfg                                    = []; 
cfg.keeptrials                         = 'no'; 
test                                   = ft_timelockanalysis(cfg, epoched_data);

cfg                                    = [];
cfg.dataset                            = fName.concat;
cfg.method                             = 'marker';
cfg.prestim                            = -2.5;
cfg.poststim                           = 2.8;
cfg.trialdef.eventtype                 = 'Stimulus';
cfg.trialdef.eventvalue                = {'S 11', 'S 12', 'S 13', 'S 14'};
cfg_ringing                            = ft_artifact_tms(cfg);

cfg_art                                = [];
cfg_art.dataset                        = fName.concat;
cfg_art.artfctdef.ringing.artifact     = cfg_ringing.artfctdef.tms.artifact;
cfg_art.artfctdef.reject               = 'partial';
cfg_art.trl                            = orig_trl;
cfg_art.artfctdef.minaccepttim         = 1;
cfg                                    = ft_rejectartifact(cfg_art);
data_eeg                               = ft_preprocessing(cfg);

cfg                                    = [];
cfg.channel                            = setdiff(data_eeg.label, {'LM', 'RM'});
data_eeg                               = ft_selectdata(cfg, data_eeg);

cfg                                    = [];
cfg.trl                                = orig_trl;
data_eeg                               = ft_redefinetrial(cfg, data_eeg);

cfg                                    = [];
if ~isempty(trls_to_remove)
    cfg.trials                         = setdiff(1:length(data_eeg.trialinfo), trls_to_remove);
end
data_eeg                               = ft_selectdata(cfg, data_eeg);

cfg                                    = [];
cfg.method                             = 'pchip';
cfg.prewindow                          = 0.1;
cfg.postwindow                         = 0.1;
data_eeg                               = ft_interpolatenan(cfg, data_eeg);
end