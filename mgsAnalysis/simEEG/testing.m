clear; close all; clc;
addpath /hyper/software/fieldtrip-20220104;
ft_defaults;
fs = 2500; 
nchan = 1;
nrpt = 32;
start_time = -1;
end_time = 2.5;
nsamples = (end_time - start_time) * fs + 1;

data = [];
freqs_to_use = [8, 10, 12, 50, 100];
for k = 1:nrpt
    data.time{k} = linspace(start_time, end_time, nsamples);
    data.trial{k} = sin(2*pi*0*data.time{k});
    for ff = freqs_to_use
        data.trial{k} = data.trial{k}+sin(2*pi*ff*data.time{k}); %randn(nchan, nsamples);
    end
end
data.label = cellstr(num2str((1:nchan).'));
figure(); plot(data.time{1}, data.trial{1}(1, :))
%%
cfg = [];
cfg.resamplefs = 1000;
dataout1 = ft_resampledata(cfg, data);
figure(); plot(dataout1.time{1}, dataout1.trial{1}(1, :))
%%
cfg.lpfilter = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq = 100;
dataout2 = ft_resampledata(cfg, data);
figure(); plot(dataout2.time{1}, dataout2.trial{1}(1, :))
%%
cfg.lpfreq = 90;
dataout3 = ft_resampledata(cfg, data);
figure(); plot(dataout3.time{1}, dataout3.trial{1}(1, :))
%%
cfg = [];
cfg.time = dataout1.time;
dataout4 = ft_resampledata(cfg, data);
figure(); plot(dataout4.time{1}, dataout4.trial{1}(1, :))
%%
cfg.lpfilter = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq = 100;
dataout5 = ft_resampledata(cfg, data);
figure(); plot(dataout5.time{1}, dataout5.trial{1}(1, :))
%%
cfg = [];
cfg.resamplefs = 500;
cfg.method = 'downsample';
dataout6 = ft_resampledata(cfg, data);
figure(); plot(dataout6.time{1}, dataout6.trial{1}(1, :))
%%
cfg.lpfilter = 'yes';
cfg.lpfilttype = 'firws';
cfg.lpfreq = 100;
dataout7 = ft_resampledata(cfg, data);
figure(); plot(dataout7.time{1}, dataout7.trial{1}(1, :))
%%
cfg = [];
cfg.method = 'mtmfft';
cfg.tapsmofrq = 1;
cfg.pad = 4;
freq = ft_freqanalysis(cfg, data);
freq1 = ft_freqanalysis(cfg, dataout1);
freq2 = ft_freqanalysis(cfg, dataout2);
freq3 = ft_freqanalysis(cfg, dataout3);
freq4 = ft_freqanalysis(cfg, dataout4);
freq5 = ft_freqanalysis(cfg, dataout5);
freq6 = ft_freqanalysis(cfg, dataout6);
freq7 = ft_freqanalysis(cfg, dataout7);
%%
cmap = ft_colormap('Set1');

figure; hold on;
plot(freq.freq, (log10(freq.powspctrm)), 'color', cmap(1, :), 'linewidth', 2);
plot(freq1.freq, (log10(freq1.powspctrm)), 'color', cmap(2, :), 'linewidth', 2);
plot(freq2.freq, (log10(freq2.powspctrm)), 'color', cmap(3, :), 'linewidth', 2);
plot(freq3.freq, (log10(freq3.powspctrm)), 'color', cmap(4, :), 'linewidth', 2);
plot(freq4.freq, (log10(freq4.powspctrm)), 'color', cmap(5, :), 'linewidth', 2);
plot(freq5.freq, (log10(freq5.powspctrm)), 'color', cmap(7, :), 'linewidth', 2);
plot(freq6.freq, (log10(freq6.powspctrm)), 'color', cmap(8, :), 'linewidth', 2);
plot(freq7.freq, (log10(freq7.powspctrm)), 'color', cmap(9, :), 'linewidth', 2);
legend({'rs_native', 'rs_firws100', 'rs_firws090', 'interp1', 'interp1_firws100', ...
    'downsample', 'downsample_firws100', 'original'}, 'Interpreter','none')
xlabel('Frequency (Hz)')
ylabel('power')
