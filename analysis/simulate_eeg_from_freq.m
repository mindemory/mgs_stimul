clear; close all; clc;

%nFreqs = 50;
srate=1000;
time=(0:1/srate:4.5);
stim_pres = 0.2;
resp_start = 3.5;
nTime = length(time); % in seconds
nTrials = 30;
pulse_start = 2;
pulse_end = pulse_start + 0.1*4;
pulses_rhythm = pulse_start:0.1:pulse_end;
pulses_arrhythm = pulses_rhythm;
pulses_arrhythm(2:4) = pulses_rhythm(2:4) + 0.03 + 0.01 * randn(1, 3);

freqs = 5:35;
nFreqs = length(freqs);
tf_baseline = zeros(nTime, nFreqs, nTrials);
tf_rhythmic_tms = zeros(nTime, nFreqs, nTrials);
tf_arrhythmic_sham = zeros(nTime, nFreqs, nTrials);
tf_rhythmic_sham = zeros(nTime, nFreqs, nTrials);
tf_arrhythmic_tms = zeros(nTime, nFreqs, nTrials);
ttest_tms = zeros(nTime, nFreqs);
ttest_sham = zeros(nTime, nFreqs);
ttest_rhythm = zeros(nTime, nFreqs);
ttest_arrhythm = zeros(nTime, nFreqs);

for trial = 1:nTrials
    for tt = 1:nTime
        time_now = time(tt);
        if time_now > stim_pres && time_now < resp_start % stimulus onset and stimulus offset
            power_baseline = randi(20, 1, length(freqs)) + 100 * normpdf(freqs, 10, 2.5);
            power_rhythmic_sham = randi(20, 1, length(freqs)) + 100 * normpdf(freqs, 10, 2.5);
            power_arrhythmic_sham = randi(20, 1, length(freqs)) + 100 * normpdf(freqs, 10, 2.5);
            
            if (time_now > pulses_rhythm(1) && time_now < pulses_rhythm(2)) || ...
                    (time_now > pulses_rhythm(2) && time_now < pulses_rhythm(3)) || ...
                    (time_now > pulses_rhythm(3) && time_now < pulses_rhythm(4)) || ...
                    (time_now > pulses_rhythm(4) && time_now < pulses_rhythm(5) + .2)
                power_rhythmic_tms = 0.5 * power_baseline + randi(20, 1, length(freqs)) + 100 * normpdf(freqs, 10, 4);
            elseif time_now > pulses_rhythm(5)
                power_rhythmic_tms = 1.3 * power_baseline;
            else
                power_rhythmic_tms = power_baseline;
            end
    
            if (time_now > pulses_arrhythm(1) && time_now < pulses_arrhythm(2)) || ...
                    (time_now > pulses_arrhythm(4) && time_now < pulses_arrhythm(5))
                power_arrhythmic_tms = 0.5 * power_baseline + randi(20, 1, length(freqs)) + 100 * normpdf(freqs, 10, 4);
            else
                power_arrhythmic_tms = power_baseline;
            end
        else
            power_baseline = 2 * randi(10, 1, length(freqs));
            power_rhythmic_sham = 2 * randi(10, 1, length(freqs));
            power_arrhythmic_sham = 2 * randi(10, 1, length(freqs));
            power_rhythmic_tms = power_baseline;
            power_arrhythmic_tms = power_baseline;
        end
        tf_baseline(tt, :, trial) = power_baseline;
        tf_rhythmic_tms(tt, :, trial) = power_rhythmic_tms;
        tf_arrhythmic_tms(tt, :, trial) = power_arrhythmic_tms;
        tf_rhythmic_sham(tt, :, trial) = power_rhythmic_sham;
        tf_arrhythmic_sham(tt, :, trial) = power_arrhythmic_sham;
    end
end

mean_tf_rhythmic_tms = mean(tf_rhythmic_tms, 3);
mean_tf_arrhythmic_tms = mean(tf_arrhythmic_tms, 3);
mean_tf_rhythmic_sham = mean(tf_rhythmic_sham, 3);
mean_tf_arrhythmic_sham = mean(tf_arrhythmic_sham, 3);

% for tt = 1:nTime
%     for ff = 1:nFreqs
%         [~, ~, ~, stats1] = ttest(tf_rhythmic_tms(tt, ff, :), ...
%             tf_arrhythmic_tms(tt, ff, :));
%         
%         [~, ~, ~, stats2] = ttest(tf_rhythmic_sham(tt, ff, :), ...
%             tf_arrhythmic_sham(tt, ff, :));
%         [~, ~, ~, stats3] = ttest(tf_rhythmic_tms(tt, ff, :), ...
%             tf_rhythmic_sham(tt, ff, :));
%         [~, ~, ~, stats4] = ttest(tf_arrhythmic_tms(tt, ff, :), ...
%             tf_arrhythmic_sham(tt, ff, :));
%         ttest_tms(tt, ff) = stats1.tstat;
%         ttest_sham(tt, ff) = stats2.tstat;
%         ttest_rhythm(tt, ff) = stats3.tstat;
%         ttest_arrhythm(tt, ff) = stats4.tstat;
%     end
% end
% thresh = -2;
% ttest_tms(ttest_tms < thresh) = thresh;
% ttest_sham(ttest_sham < thresh) = thresh;
% ttest_rhythm(ttest_rhythm < thresh) = thresh;
% ttest_arrhythm(ttest_arrhythm < thresh) = thresh;

figure
ax1 = subplot(211);
imagesc(mean_tf_rhythmic_tms')
colormap(ax1, winter)

set(gca,'ydir','normal', ...
    'ytick',1:7:nFreqs,'yticklabel',round(freqs(1:7:end)), ...
    'xtick',0:srate:5000,'xticklabel',0:5)
line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
line([pulses_rhythm(1) * srate, pulses_rhythm(1) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
line([pulses_rhythm(2) * srate, pulses_rhythm(2) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
line([pulses_rhythm(3) * srate, pulses_rhythm(3) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
line([pulses_rhythm(4) * srate, pulses_rhythm(4) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
title('Rhythmic TMS')
xlabel('Time (s)')
ylabel('Frequency (Hz)')

ax2 = subplot(212);
imagesc(mean_tf_arrhythmic_tms')
colormap(ax2, winter)

set(gca,'ydir','normal', ...
    'ytick',1:7:nFreqs,'yticklabel',round(5:7:35), ...
    'xtick',0:srate:5000,'xticklabel',0:5)
hold on;
line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
line([pulses_rhythm(1) * srate, pulses_rhythm(1) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
line([pulses_rhythm(2) * srate, pulses_rhythm(2) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
line([pulses_rhythm(3) * srate, pulses_rhythm(3) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
line([pulses_rhythm(4) * srate, pulses_rhythm(4) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
title('Arrhythmic TMS')
xlabel('Time (s)')
ylabel('Frequency (Hz)')

% %% Figures
% figure
% ax1 = subplot(331);
% imagesc(mean_tf_rhythmic_tms')
% colormap(ax1, winter)
% 
% set(gca,'ydir','normal', ...
%     'ytick',1:7:nFreqs,'yticklabel',round(freqs(1:7:end)), ...
%     'xtick',0:srate:5000,'xticklabel',0:5)
% line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
% line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
% line([pulses_rhythm(1) * srate, pulses_rhythm(1) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(2) * srate, pulses_rhythm(2) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(3) * srate, pulses_rhythm(3) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(4) * srate, pulses_rhythm(4) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% title('Rhythmic TMS')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% 
% ax2 = subplot(332);
% imagesc(mean_tf_arrhythmic_tms')
% colormap(ax2, winter)
% 
% set(gca,'ydir','normal', ...
%     'ytick',1:7:nFreqs,'yticklabel',round(5:7:35), ...
%     'xtick',0:srate:5000,'xticklabel',0:5)
% hold on;
% line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
% line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
% line([pulses_rhythm(1) * srate, pulses_rhythm(1) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(2) * srate, pulses_rhythm(2) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(3) * srate, pulses_rhythm(3) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(4) * srate, pulses_rhythm(4) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% title('Arrhythmic TMS')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% 
% ax3 = subplot(333);
% imagesc(ttest_tms')
% colormap(ax3, gray)
% c = colorbar(ax3);
% c.Label.String = 't-stat';
% set(gca,'ydir','normal', ...
%     'ytick',1:7:nFreqs,'yticklabel',round(5:7:35), ...
%     'xtick',0:srate:5000,'xticklabel',0:5)
% hold on;
% line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 1, 'color', 'r')
% line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 1, 'color', 'r')
% title('ttest TMS')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% 
% ax4 = subplot(334);
% imagesc(mean_tf_rhythmic_sham')
% colormap(ax4, winter)
% 
% set(gca,'ydir','normal', ...
%     'ytick',1:7:nFreqs,'yticklabel',round(freqs(1:7:end)), ...
%     'xtick',0:srate:5000,'xticklabel',0:5)
% line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
% line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
% title('Rhythmic Sham')
% line([pulses_rhythm(1) * srate, pulses_rhythm(1) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(2) * srate, pulses_rhythm(2) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(3) * srate, pulses_rhythm(3) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(4) * srate, pulses_rhythm(4) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% 
% ax5 = subplot(335);
% imagesc(mean_tf_arrhythmic_sham')
% colormap(ax5, winter)
% 
% set(gca,'ydir','normal', ...
%     'ytick',1:7:nFreqs,'yticklabel',round(freqs(1:7:end)), ...
%     'xtick',0:srate:5000,'xticklabel',0:5)
% line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
% line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 2, 'color', 'k')
% line([pulses_rhythm(1) * srate, pulses_rhythm(1) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(2) * srate, pulses_rhythm(2) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(3) * srate, pulses_rhythm(3) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% line([pulses_rhythm(4) * srate, pulses_rhythm(4) * srate], [0, 35], 'LineWidth', 0.5, 'color', 'm')
% title('Arrhythmic Sham')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% 
% ax6 = subplot(336);
% imagesc(ttest_sham')
% colormap(ax6, gray)
% c = colorbar(ax6);
% c.Label.String = 't-stat';
% set(gca,'ydir','normal', ...
%     'ytick',1:7:nFreqs,'yticklabel',round(5:7:35), ...
%     'xtick',0:srate:5000,'xticklabel',0:5)
% hold on;
% line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 1, 'color', 'r')
% line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 1, 'color', 'r')
% title('ttest Sham')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% 
% ax7 = subplot(337);
% imagesc(ttest_rhythm')
% colormap(ax7, gray)
% c = colorbar(ax7);
% c.Label.String = 't-stat';
% set(gca,'ydir','normal', ...
%     'ytick',1:7:nFreqs,'yticklabel',round(5:7:35), ...
%     'xtick',0:srate:5000,'xticklabel',0:5)
% hold on;
% line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 1, 'color', 'r')
% line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 1, 'color', 'r')
% title('ttest rhythmic')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% 
% ax8 = subplot(338);
% imagesc(ttest_arrhythm')
% colormap(ax8, gray)
% c = colorbar(ax8);
% c.Label.String = 't-stat';
% set(gca,'ydir','normal', ...
%     'ytick',1:7:nFreqs,'yticklabel',round(5:7:35), ...
%     'xtick',0:srate:5000,'xticklabel',0:5)
% hold on;
% line([stim_pres * srate, stim_pres * srate], [0, 35], 'LineWidth', 1, 'color', 'r')
% line([resp_start * srate, resp_start * srate], [0, 35], 'LineWidth', 1, 'color', 'r')
% title('ttest arrhythmic')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
