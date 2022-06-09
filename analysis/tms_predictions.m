clear; close all; clc;
trials = 300;
conds = 2;

mean_baseline = [1.8, 2];
mean_tms_r_into = mean_baseline * 0.6;
mean_tms_arr_into = mean_baseline * 1.3;
mean_sham_r_into = mean_baseline + rand/10;
mean_sham_arr_into = mean_baseline + rand/10;
mean_tms_r_away = mean_baseline + rand/10;
mean_tms_arr_away = mean_baseline + rand/10;
mean_sham_r_away = mean_baseline + rand/10;
mean_sham_arr_away = mean_baseline + rand/10;

sdev = 1.5;

baseline = zeros(trials, conds);
tms_r_into = zeros(trials, conds);
tms_arr_into = zeros(trials, conds);
sham_r_into = zeros(trials, conds);
sham_arr_into = zeros(trials, conds);
tms_r_away = zeros(trials, conds);
tms_arr_away = zeros(trials, conds);
sham_r_away = zeros(trials, conds);
sham_arr_away = zeros(trials, conds);

for c = 1:conds
    baseline(:, c) = mean_baseline(c) + sdev .* randn(300, 1);
    tms_r_into(:, c) = mean_tms_r_into(c) + sdev .* randn(300, 1);
    tms_arr_into(:, c) = mean_tms_arr_into(c) + sdev .* randn(300, 1);
    sham_r_into(:, c) = mean_sham_r_into(c) + sdev .* randn(300, 1);
    sham_arr_into(:, c) = mean_sham_arr_away(c) + sdev .* randn(300, 1);
    tms_r_away(:, c) = mean_tms_r_away(c) + sdev .* randn(300, 1);
    tms_arr_away(:, c) = mean_tms_arr_away(c) + sdev .* randn(300, 1);
    sham_r_away(:, c) = mean_sham_r_away(c) + sdev .* randn(300, 1);
    sham_arr_away(:, c) = mean_sham_arr_away(c) + sdev .* randn(300, 1);
end

baseline_mean = mean(baseline);
tms_r_into_mean = mean(tms_r_into);
tms_arr_into_mean = mean(tms_arr_into);
sham_r_into_mean = mean(sham_r_into);
sham_arr_into_mean = mean(sham_arr_into);
tms_r_away_mean = mean(tms_r_away);
tms_arr_away_mean = mean(tms_arr_away);
sham_r_away_mean = mean(sham_r_away);
sham_arr_away_mean = mean(sham_arr_away);

baseline_sem = std(baseline)/sqrt(trials - 1);
tms_r_into_sem = std(tms_r_into)/sqrt(trials - 1);
tms_arr_into_sem = std(tms_arr_into)/sqrt(trials - 1);
sham_r_into_sem = std(sham_r_into)/sqrt(trials - 1);
sham_arr_into_sem = std(sham_arr_into)/sqrt(trials - 1);
tms_r_away_sem = std(tms_r_away)/sqrt(trials - 1);
tms_arr_away_sem = std(tms_arr_away)/sqrt(trials - 1);
sham_r_away_sem = std(sham_r_away)/sqrt(trials - 1);
sham_arr_away_sem = std(sham_arr_away)/sqrt(trials - 1);

net_mean = [baseline_mean, tms_r_into_mean, tms_r_away_mean, ...
    tms_arr_into_mean, tms_arr_away_mean, sham_r_into_mean, ...
    sham_r_away_mean, sham_arr_into_mean, sham_arr_away_mean];
net_sem = [baseline_sem, tms_r_into_sem, tms_r_away_sem, ...
    tms_arr_into_sem, tms_arr_away_sem, sham_r_into_sem, ...
    sham_r_away_sem, sham_arr_into_sem, sham_arr_away_sem];
low_lim = net_mean - net_sem;
up_lim = net_mean + net_sem;

net_mean1 = [baseline_mean(1), tms_r_into_mean(1), tms_arr_into_mean(1), ...
    sham_r_into_mean(1), sham_arr_into_mean(1)];
net_mean2 = [baseline_mean(2), tms_r_into_mean(2), tms_arr_into_mean(2), ...
    sham_r_into_mean(2), sham_arr_into_mean(2)];
net_mean3 = [tms_r_away_mean(1), tms_arr_away_mean(1), ...
    sham_r_away_mean(1), sham_arr_away_mean(1)];
net_mean4 = [tms_r_away_mean(2), tms_arr_away_mean(2), ...
    sham_r_away_mean(2), sham_arr_away_mean(2)];

net_sem1 = [baseline_sem(1), tms_r_into_sem(1), tms_arr_into_sem(1), ...
    sham_r_into_sem(1), sham_arr_into_sem(1)];
net_sem2 = [baseline_sem(2), tms_r_into_sem(2), tms_arr_into_sem(2), ...
    sham_r_into_sem(2), sham_arr_into_sem(2)];
net_sem3 = [tms_r_away_sem(1), tms_arr_away_sem(1), ...
    sham_r_away_sem(1), sham_arr_away_sem(1)];
net_sem4 = [tms_r_away_sem(2), tms_arr_away_sem(2), ...
    sham_r_away_sem(2), sham_arr_away_sem(2)];
x1 = [0.33, 2.2, 4.2, 6.2, 8.2];
x2 = [0.67, 2.4, 4.4, 6.4, 8.4];
x3 = [2.6, 4.6, 6.6, 8.6];
x4 = [2.8, 4.8, 6.8, 8.8];
% x = [0.33, 0.67, 2.2, 2.4, 2.6, 2.8, 4.2, 4.4, 4.6, 4.8, ...
%     6.2, 6.4, 6.6, 6.8, 8.2, 8.4, 8.6, 8.8];
%x = [0.5, 1.5, 1.75, 2, 2.25, 3.25, 4, 5, 5.5, 6.5, 7];
figure
e1 = errorbar(x1, net_mean1, net_sem1, net_sem1, ...
    'o','MarkerSize',7,'MarkerEdgeColor','green','MarkerFaceColor','green', ...
    'CapSize', 5, 'LineWidth',1.5, 'Color', 'green');
hold on;
e2 = errorbar(x2, net_mean2, net_sem2, net_sem2, ...
    'o','MarkerSize',7,'MarkerEdgeColor','red','MarkerFaceColor','red', ...
    'CapSize',5, 'LineWidth',1.5, 'Color', 'red');
e3 = errorbar(x3, net_mean3, net_sem3, net_sem3, ...
    'o','MarkerSize',7,'MarkerEdgeColor','black','MarkerFaceColor','black', ...
    'CapSize',5, 'LineWidth',1.5, 'Color', 'black');
e4 = errorbar(x4, net_mean4, net_sem4, net_sem4, ...
    'o','MarkerSize',7,'MarkerEdgeColor','blue','MarkerFaceColor','blue', ...
    'CapSize',5, 'LineWidth',1.5, 'Color', 'blue');

xlim([0, 8])
xticks([0.5, 2.5, 4.5, 6.5, 8.5])
xticklabels({'baseline', 'rhythmic TMS', 'arrhythmic TMS', ...
    'rhythmic Sham', 'arrhythmic Sham'})
ylabel('Memory Error (M\pm SE) in degrees', 'FontAngle','italic')
%xlabel('Conditions', 'FontAngle', 'italic')
legend({'Pro MGS into TMS VF', 'Anti MGS into TMS VF', ...
    'Pro MGS outside TMS VF', 'Anti MGS outside TMS VF'})
%ylim([1, 3.5])
ax = gca;
ax.XAxis.FontSize = 11;
ax.YAxis.FontSize = 11;