function create_topo_stat(NoTMS_stat, TMS_stat)

occ_elecs = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7', 'O2', ...
            'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};
elec_idx_notms = find(ismember(NoTMS_stat.label,occ_elecs));
elec_idx_tms = find(ismember(TMS_stat.label,occ_elecs));

logical_idx_before = (TMS_stat.time > 0.5) & (TMS_stat.time < 2);
idx_t_before = find(logical_idx_before);
logical_idx_after = (TMS_stat.time > 3) & (TMS_stat.time < 4.5);
idx_t_after = find(logical_idx_after);
idx_t = [idx_t_before idx_t_after];


idx_f = 1;
max_pow_nt = max(NoTMS_stat.stat(elec_idx_notms, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_nt = min(NoTMS_stat.stat(elec_idx_notms, idx_f, idx_t), [], 'all', 'omitnan');
max_pow_t = max(TMS_stat.stat(elec_idx_tms, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_t = min(TMS_stat.stat(elec_idx_tms, idx_f, idx_t), [], 'all', 'omitnan');

min_pow = min([min_pow_nt, min_pow_t]);
max_pow = min([max_pow_nt, max_pow_t]);

figure('Renderer', 'painters', 'Position', [0 1000 1600 800])
sgtitle(['pow range =[' num2str(round(min_pow, 2)), ', ' num2str(round(max_pow, 2)) ']']);
cfg = []; cfg.layout = 'acticap-64_md.mat'; cfg.figure = 'gcf';
cfg.style = 'straight';
cfg.parameter = 'stat';
%cfg.ylim = [8 12]; 
%cfg.highlight = 'on'; 
cfg.highlightsymbol = 'x'; %cfg.highlightsize = 8;
cfg.colorbar = 'yes'; cfg.comment = 'no'; 
cfg.colormap = '*RdBu'; cfg.marker = 'on';
cfg.zlim = [min_pow max_pow];
cfg.interpolatenan = 'no';

subplot(2, 4, 1)
cfg.xlim = [0.5 1.5];
cfg.title = 'Alpha @ 0.5:1.5s';
ft_topoplotTFR(cfg, NoTMS_stat)
subplot(2, 4, 2)
cfg.xlim = [1.5 2];
cfg.title = 'Alpha @ 1.5:2s';
ft_topoplotTFR(cfg, NoTMS_stat)
subplot(2, 4, 3)
cfg.xlim = [3 3.5];
cfg.title = 'Alpha @ 3:3.5s';
ft_topoplotTFR(cfg, NoTMS_stat)
subplot(2, 4, 4)
cfg.xlim = [3.5 4.5];
cfg.title = 'Alpha @ 3.5:4.5s';
ft_topoplotTFR(cfg, NoTMS_stat)

subplot(2, 4, 5)
cfg.xlim = [0.5 1.5];
cfg.title = 'Alpha @ 0.5:1.5s';
ft_topoplotTFR(cfg, TMS_stat)
subplot(2, 4, 6)
cfg.xlim = [1.5 2];
cfg.title = 'Alpha @ 1.5:2s';
ft_topoplotTFR(cfg, TMS_stat)
subplot(2, 4, 7)
cfg.xlim = [3 3.5];
cfg.title = 'Alpha @ 3:3.5s';
ft_topoplotTFR(cfg, TMS_stat)
subplot(2, 4, 8)
cfg.xlim = [3.5 4.5];
cfg.title = 'Alpha @ 3.5:4.5s';
ft_topoplotTFR(cfg, TMS_stat)

% common_colorbar_subplot = subplot(2, 5, [5, 10]);
% 
% colorbars = findall(gcf, 'Type', 'ColorBar');
% for i = 1:numel(colorbars)
%     colorbar_axes = get(colorbars(i), 'Parent');
%     
%     pos = get(colorbar_axes, 'Position');
%     set(colorbar_axes, 'Position', pos);%[0.92, pos(2), 0.02, pos(4)]);
%     
%     delete(colorbars(i));
% end
% 
% % Customize the common colorbar as needed
% h_colorbar = colorbar(common_colorbar_subplot);
% set(h_colorbar, 'Position', pos);%[0.94, 0.1, 0.02, 0.8]);  % Adjust position if needed
% ylabel(h_colorbar, 'Colorbar Label');  % Add label if needed

end