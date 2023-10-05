function compare_conds_old(NoTMS_intoVF_ipsi, NoTMS_intoVF_contra, TMS_intoVF_ipsi, TMS_intoVF_contra)
% Change the labels of all matrices
NoTMS_intoVF_ipsi.label = {'lol'};
NoTMS_intoVF_contra.label = {'lol'};
TMS_intoVF_ipsi.label = {'lol'};
TMS_intoVF_contra.label = {'lol'};

logical_idx_before = (TMS_intoVF_ipsi.time > 0.8) & (TMS_intoVF_ipsi.time < 2);
idx_t_before = find(logical_idx_before);
logical_idx_after = (TMS_intoVF_ipsi.time > 3) & (TMS_intoVF_ipsi.time < 4.2);
idx_t_after = find(logical_idx_after);
idx_t = [idx_t_before idx_t_after];

logical_freq_idx = (TMS_intoVF_ipsi.freq > 10) & (TMS_intoVF_ipsi.freq < 20);
idx_f = find(logical_freq_idx);

max_pow_nt_ivf_ipsi = max(NoTMS_intoVF_ipsi.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_nt_ivf_ipsi = min(NoTMS_intoVF_ipsi.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
max_pow_nt_ivf_contra = max(NoTMS_intoVF_contra.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_nt_ivf_contra = min(NoTMS_intoVF_contra.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');

max_pow_t_ivf_ipsi = max(TMS_intoVF_ipsi.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_t_ivf_ipsi = min(TMS_intoVF_ipsi.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
max_pow_t_ovf_contra = max(TMS_intoVF_contra.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_t_ovf_contra = min(TMS_intoVF_contra.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');

min_pow = min([min_pow_nt_ivf_ipsi, min_pow_nt_ivf_contra, min_pow_t_ivf_ipsi, min_pow_t_ovf_contra]);
max_pow = max([max_pow_nt_ivf_ipsi, max_pow_nt_ivf_contra, max_pow_t_ivf_ipsi, max_pow_t_ovf_contra]);
%min_pow = 0;
%max_pow = 1;
%% Compute TFR differences
cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'subtract';
NoTMS_difference = ft_math(cfg, NoTMS_intoVF_contra, NoTMS_intoVF_ipsi);
TMS_difference = ft_math(cfg, TMS_intoVF_contra, TMS_intoVF_ipsi);
ipsi_difference = ft_math(cfg, TMS_intoVF_ipsi, NoTMS_intoVF_ipsi);
contra_difference = ft_math(cfg, TMS_intoVF_contra, NoTMS_intoVF_contra);

max_pow_nt_diff = max(NoTMS_difference.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_nt_diff = min(NoTMS_difference.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
max_pow_t_diff = max(TMS_difference.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_t_diff = min(TMS_difference.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
max_pow_right_diffs = max([max_pow_nt_diff, max_pow_t_diff]);
min_pow_right_diffs = min([min_pow_nt_diff, min_pow_t_diff]);
%max_pow_right_diffs = 1;
%min_pow_right_diffs = -1;
max_pow_ipsi_diff = max(ipsi_difference.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_ipsi_diff = min(ipsi_difference.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
max_pow_contra_diff = max(contra_difference.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_contra_diff = min(contra_difference.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
max_pow_bottom_diffs = max([max_pow_ipsi_diff, max_pow_contra_diff]);
min_pow_bottom_diffs = min([min_pow_ipsi_diff, min_pow_contra_diff]);
%max_pow_bottom_diffs = 1;
%min_pow_bottom_diffs = -1;
%min_pow_diffs = min([min_pow_nt_diff, min_pow_t_diff, min_pow_ipsi_diff, min_pow_contra_diff]);
%max_pow_diffs = max([max_pow_nt_diff, max_pow_t_diff, max_pow_ipsi_diff, max_pow_contra_diff]);

% tVal_RH = squeeze(stats_allChannels.stat);
% h = subplot(2,1,2);imagesc(t,[],flipud(tVal_RH));colorbar;
%% Create figure
%figure();
figure('Renderer', 'painters', 'Position', [0 1000 1600 800])
%suptitle(['subject = ' num2str(p.subjID, '%02d')])
cfg = [];
cfg.figure = 'gcf';
cfg.xlim = [0.5, 4.5];
cfg.ylim = [5, 35];
cfg.zlim = [min_pow, max_pow];
cfg.colormap = '*RdBu';
cfg.fontsize = 13;
subplot(3, 3, 1)
cfg.title = 'ipsi';
ft_singleplotTFR(cfg, NoTMS_intoVF_ipsi)
subplot(3, 3, 2)
cfg.title = 'contra';
ft_singleplotTFR(cfg, NoTMS_intoVF_contra)
subplot(3, 3, 4)
cfg.title = 'ipsi';
ft_singleplotTFR(cfg, TMS_intoVF_ipsi)
subplot(3, 3, 5)
cfg.title = 'contra';
ft_singleplotTFR(cfg, TMS_intoVF_contra)

cfg.zlim = [min_pow_right_diffs, max_pow_right_diffs];
subplot(3, 3, 3)
cfg.title = 'contra - ipsi';
ft_singleplotTFR(cfg, NoTMS_difference)
subplot(3, 3, 6)
cfg.title = 'contra - ipsi';
ft_singleplotTFR(cfg, TMS_difference)

cfg.zlim = [min_pow_bottom_diffs, max_pow_bottom_diffs];
subplot(3, 3, 7)
cfg.title = 'ipsi (TMS - NoTMS)';
ft_singleplotTFR(cfg, ipsi_difference)
subplot(3, 3, 8)
cfg.title = 'contra (TMS - NoTMS)';
ft_singleplotTFR(cfg, contra_difference)
end