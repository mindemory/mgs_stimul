function compare_conds(NoTMS_intoVF_ipsi, NoTMS_intoVF_contra, TMS_intoVF_ipsi, TMS_intoVF_contra)
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
%% Create figure
figure('Renderer', 'painters', 'Position', [0 1000 1600 800])
cfg = [];
cfg.figure = 'gcf';
cfg.xlim = [0.5, 4.5];
cfg.ylim = [5, 35];
cfg.zlim = [min_pow, max_pow];
cfg.colormap = '*RdBu';
cfg.fontsize = 13;
subplot(2, 2, 1)
cfg.title = 'contra (left)';
ft_singleplotTFR(cfg, NoTMS_intoVF_contra)

subplot(2, 2, 2)
cfg.title = 'ipsi (right)';
ft_singleplotTFR(cfg, NoTMS_intoVF_ipsi)

subplot(2, 2, 3)
cfg.title = 'contra (left)';
ft_singleplotTFR(cfg, TMS_intoVF_contra)

subplot(2, 2, 4)
cfg.title = 'ipsi (right)';
ft_singleplotTFR(cfg, TMS_intoVF_ipsi)

end