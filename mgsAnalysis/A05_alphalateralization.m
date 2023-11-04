function A05_alphalateralization()
clearvars; close all; clc;
warning('off', 'all');

subs                                        = [1 3 5 6 7 8 11 12 13 14 15 16 17 18 22 23 24 25 26 27];
goodsubs                                    = [1 3 5 6 14 15 16 17 22 25 27];
%goodsubs                                    = subs;
t_stamp                                     = [-0.5 5];
f_stamp                                     = [8 12];
t_types                                     = ["Pin", "Pout", "Ain", "Aout"];
t_types_in                                  = ["Pin", "Ain"];
fName.mTFR                                  = ['/datc/MD_TMS_EEG/EEGfiles/masterTFR.mat'];

disp('Loading existing master TFR file')
load(fName.mTFR)
tidx                                        = find((mTFR.NT.Pout.all.time >= t_stamp(1)) ...
                                                    & (mTFR.NT.Pout.all.time <= t_stamp(2)));
fidx                                        = find((mTFR.NT.Pout.all.freq >= f_stamp(1)) ...
                                                    & (mTFR.NT.Pout.all.freq <= f_stamp(2)));
[~, sidx]                                   = ismember(goodsubs, subs);
nsubs                                       = length(sidx); 
ALI                                         = struct();
ALImean                                     = struct();
ALIsem                                      = struct();

% Average all mTFRs for plotting
time_array                                  = mTFR.NT.Pin.ipsi.time(tidx);
baselinewin                                 = find(time_array <= 0, 1, 'last');
baseline                                    = 1;
for tt = t_types_in
    this_contra                             = mean(mTFR.NT.(tt).contra.powspctrm(sidx, :, fidx, tidx), 3, 'omitnan');
    this_ipsi                               = mean(mTFR.NT.(tt).ipsi.powspctrm(sidx, :, fidx, tidx), 3, 'omitnan');
    ALI.NT.(tt)                             = squeeze(this_contra - this_ipsi);
    %ALI.NT.(tt)                             = squeeze((10.^(this_contra./10) - 10.^(this_ipsi./10)) ./ (10.^(this_contra./10) + 10.^(this_ipsi./10)));
    if baseline
        ALI.NT.(tt)                         = ALI.NT.(tt) - ALI.NT.(tt)(:, baselinewin);
    end
end
for tt = t_types
    this_contra                             = mean(mTFR.T.(tt).contra.powspctrm(sidx, :, fidx, tidx), 3, 'omitnan');
    this_ipsi                               = mean(mTFR.T.(tt).ipsi.powspctrm(sidx, :, fidx, tidx), 3, 'omitnan');
    ALI.T.(tt)                              = squeeze(this_contra - this_ipsi);
    %ALI.T.(tt)                             = squeeze((10.^(this_contra./10) - 10.^(this_ipsi./10)) ./ (10.^(this_contra./10) + 10.^(this_ipsi./10)));
    if baseline
        ALI.T.(tt)                          = ALI.T.(tt) - ALI.T.(tt)(:, baselinewin);
    end
end
min_vals                                    = [];
max_vals                                    = [];

% SEM all mTFRs for plotting
for tt = t_types_in
    ALImean.NT.(tt)                         = squeeze(mean(ALI.NT.(tt), 1, 'omitnan'));
    ALIsem.NT.(tt)                          = squeeze(std(ALI.NT.(tt), 0, 1, 'omitnan')./sqrt(nsubs*7));
    min_vals                                = [min_vals, min(ALImean.NT.(tt) - ALIsem.NT.(tt), [], 'all')];
    max_vals                                = [max_vals, max(ALImean.NT.(tt) + ALIsem.NT.(tt), [], 'all')];
end
for tt = t_types
    ALImean.T.(tt)                          = squeeze(mean(ALI.T.(tt), 1, 'omitnan'));
    ALIsem.T.(tt)                           = squeeze(std(ALI.T.(tt), 0, 1, 'omitnan')./sqrt(nsubs*7));
    min_vals                                = [min_vals, min(ALImean.T.(tt) - ALIsem.T.(tt), [], 'all')];
    max_vals                                = [max_vals, max(ALImean.T.(tt) + ALIsem.T.(tt), [], 'all')];
end

%% Plot only pro with and without TMS
time_array                                  = mTFR.NT.Pin.ipsi.time(tidx);
y_min                                       = min(min_vals); 
y_max                                       = max(max_vals);

sig                                         = zeros(length(time_array), 1);
global_tms                                  = squeeze(ALI.T.Pin);
global_notms                                = squeeze(ALI.NT.Pin);
movwin                                      = 11; % samples
tfac                                        = int32(floor(3/2));
corr_fact                                   = length(movwin-1:length(time_array)-(movwin-2));
for t                                       = movwin-1:length(time_array)-(movwin-2)
    this_tms                                = global_tms(:, t-tfac:t+tfac);
    this_notms                              = global_notms(:, t-tfac:t+tfac);
    sig(t)                                  = ttest(this_tms(:), this_notms(:), 'Alpha', 0.05);
end
[R,P]                                       = corrcoef(ALImean.T.Pin,ALImean.NT.Pin);

figure('Renderer', 'painters');
plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
hold on;
hold on;
y1                                          = ALImean.NT.Pin - ALIsem.NT.Pin;
y2                                          = ALImean.NT.Pin + ALIsem.NT.Pin;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);

y1                                          = ALImean.T.Pin - ALIsem.T.Pin;
y2                                          = ALImean.T.Pin + ALIsem.T.Pin;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);

plot(time_array, ALImean.NT.Pin, 'k-', 'LineWidth', 2)
plot(time_array, ALImean.T.Pin, 'r-', 'LineWidth', 2)
%plot(time_array, mean(cat(1, ALImean.T.Pin, -ALImean.T.Pout), 1), 'r-', 'LineWidth', 2)

plot(time_array(sig==1), 0.2* ones(sum(sig), 1), 'k*', 'MarkerSize', 3, 'LineWidth', 1, 'HandleVisibility','off');
xlabel('Time (s)')
ylabel('ALI')
xlim([-0.5 4.5])
ylim([-2, 0.4])
hold off;

%%
% figure();
% subplot(4, 3, 1)
% plot(time_array, ALImean.NT.Pin, 'k-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.NT.Pin - ALIsem.NT.Pin;
% y2 = ALImean.NT.Pin + ALIsem.NT.Pin;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% xlim(t_stamp)
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 2)
% plot(time_array, ALImean.NT.Ain, 'r-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.NT.Ain - ALIsem.NT.Ain;
% y2 = ALImean.NT.Ain + ALIsem.NT.Ain;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3);
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% xlim(t_stamp)
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 3)
% plot(time_array, ALImean.NT.Pin, 'k-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.NT.Pin - ALIsem.NT.Pin;
% y2 = ALImean.NT.Pin + ALIsem.NT.Pin;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% plot(time_array, ALImean.NT.Ain, 'r-', 'LineWidth', 2)
% y1 = ALImean.NT.Ain - ALIsem.NT.Ain;
% y2 = ALImean.NT.Ain + ALIsem.NT.Ain;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 4)
% plot(time_array, ALImean.T.Pin, 'k-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.T.Pin - ALIsem.T.Pin;
% y2 = ALImean.T.Pin + ALIsem.T.Pin;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% 
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 5)
% plot(time_array, ALImean.T.Ain, 'r-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.T.Ain - ALIsem.T.Ain;
% y2 = ALImean.T.Ain + ALIsem.T.Ain;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 6)
% plot(time_array, ALImean.T.Pin, 'k-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.T.Pin - ALIsem.T.Pin;
% y2 = ALImean.T.Pin + ALIsem.T.Pin;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% plot(time_array, ALImean.T.Ain, 'r-', 'LineWidth', 2)
% y1 = ALImean.T.Ain - ALIsem.T.Ain;
% y2 = ALImean.T.Ain + ALIsem.T.Ain;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 7)
% plot(time_array, ALImean.T.Pout, 'k-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.T.Pout - ALIsem.T.Pout;
% y2 = ALImean.T.Pout + ALIsem.T.Pout;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 8)
% plot(time_array, ALImean.T.Aout, 'r-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.T.Aout - ALIsem.T.Aout;
% y2 = ALImean.T.Aout + ALIsem.T.Aout;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 9)
% plot(time_array, ALImean.T.Pout, 'k-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.T.Pout - ALIsem.T.Pout;
% y2 = ALImean.T.Pout + ALIsem.T.Pout;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% plot(time_array, ALImean.T.Aout, 'r-', 'LineWidth', 2)
% y1 = ALImean.T.Aout - ALIsem.T.Aout;
% y2 = ALImean.T.Aout + ALIsem.T.Aout;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 10)
% plot(time_array, ALImean.NT.Pin, 'k-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.NT.Pin - ALIsem.NT.Pin;
% y2 = ALImean.NT.Pin + ALIsem.NT.Pin;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% plot(time_array, ALImean.T.Pin, 'r-', 'LineWidth', 2)
% y1 = ALImean.T.Pin - ALIsem.T.Pin;
% y2 = ALImean.T.Pin + ALIsem.T.Pin;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% ylim([y_min, y_max])
% hold off;
% 
% subplot(4, 3, 11)
% plot(time_array, ALImean.NT.Ain, 'k-', 'LineWidth', 2)
% hold on;
% y1 = ALImean.NT.Ain - ALIsem.NT.Ain;
% y2 = ALImean.NT.Ain + ALIsem.NT.Ain;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% plot(time_array, ALImean.T.Ain, 'r-', 'LineWidth', 2)
% y1 = ALImean.T.Ain - ALIsem.T.Ain;
% y2 = ALImean.T.Ain + ALIsem.T.Ain;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% xlabel('Time (s)')
% ylabel('ALI (AU)')
% ylim([y_min, y_max])
% hold off;
end