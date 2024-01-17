function [data, trls_to_remove]        = remove_tms_pulse(fName, trls_to_remove)
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
% Put NaN at TMS pulse
for i                                  = size(trl_samps, 1):-1:1
    seg                                = trl_samps(i, :);
    data.trial{1}(:,seg(1):seg(2))     = NaN;
end

% Interpolate using 100 ms before and after the pulse
cfg                                    = [];
cfg.method                             = 'pchip';
cfg.prewindow                          = 0.1;
cfg.postwindow                         = 0.1;
data                                   = ft_interpolatenan(cfg, data);

% Epoching and detecting any trials that might still have TMS pulse left
% due to timing issues.
cfg = [];
cfg.dataset                            = fName.concat;
cfg.continuous                         = 'yes';
cfg.trialdef.prestim                   = 0.5;
cfg.trialdef.poststim                  = 5.5;
cfg.trialdef.eventtype                 = 'Stimulus';
cfg.trialdef.eventvalue                = {'S  1'};
cfg                                    = ft_definetrial(cfg);
trlInf                                 = cfg.trl;
cfg_new                                = [];
cfg_new.trl                            = trlInf;
epoced_dat                             = ft_redefinetrial(cfg_new, data);

% ptimes                                 = zeros(1, length(epoced_dat.trialinfo));
% for tt                                 = 1:length(epoced_dat.trialinfo)
%     median_arr                         = median(abs(epoced_dat.trial{tt}), 2);
%     tms_samps                          = abs(epoced_dat.trial{tt}(1, :)) > 1.5 * median_arr(1);
%     tms_time                           = epoced_dat.time{tt}(tms_samps);
%     npulses                            = length(tms_time);
%     ptimes(tt)                         = npulses>0;
% end

ptimes = zeros(1, length(epoced_dat.trialinfo));
for tt = 1:length(epoced_dat.trialinfo)
    num_channels = size(epoced_dat.trial{tt}, 1);
    channel_pulse_count = 0;

    for ch = 1:num_channels
        median_arr = median(abs(epoced_dat.trial{tt}(ch, :)), 2);
        tms_samps = abs(epoced_dat.trial{tt}(ch, :)) > 1.1 * median_arr;
        tms_time = epoced_dat.time{tt}(tms_samps);
        npulses = length(tms_time);

        if npulses > 0
            channel_pulse_count = channel_pulse_count + 1;
        end
    end

    if channel_pulse_count > num_channels / 3
        ptimes(tt) = 1;
    end
end
trls_to_remove                         = unique([trls_to_remove find(ptimes > 0)]);

% Filter the data
cfg                                    = [];
cfg.continuous                         = 'yes';
cfg.bpfilter                           = 'yes';
cfg.bpfreq                             = [0.5 50];
cfg.bpfilttype                         = 'but';
cfg.bpfiltord                          = 4; 
cfg.bpfiltdir                          = 'twopass'; 
data                                   = ft_preprocessing(cfg, data);


% Code to detect presence and timing of TMS pulses
% ptimes = zeros(length(epoced_dat.trialinfo), 5);
% for tt = 1:length(epoced_dat.trialinfo)
%     median_arr = median(abs(epoced_dat.trial{tt}), 2);
%     tms_samps = abs(epoced_dat.trial{tt}(1, :)) > 1.1 * median_arr(1);
%     tms_time = epoced_dat.time{tt}(tms_samps);
%     diff_time = diff(tms_time);
%     threshold = min(diff_time) * 1.1;
%     start_idx = [1, find(diff_time > threshold) + 1];
%     end_idx = [start_idx(2:end) - 1, length(tms_time)];
%     pulse_dur = tms_time(end_idx) - tms_time(start_idx);
%     ptimes(tt, :) = [tms_time(start_idx(1)) tms_time(end_idx(end)) pulse_dur];
%     npulses = length(start_idx);
%     if npulses ~= 3
%         disp([tt, npulses])
%     end
% end
end