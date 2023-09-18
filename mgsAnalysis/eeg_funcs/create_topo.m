function create_topo(NoTMS_intoVF, TMS_intoVF)

logical_idx_before = (TMS_intoVF.time > 0.8) & (TMS_intoVF.time < 2);
idx_t_before = find(logical_idx_before);
logical_idx_after = (TMS_intoVF.time > 3) & (TMS_intoVF.time < 4.2);
idx_t_after = find(logical_idx_after);
idx_t = [idx_t_before idx_t_after];

logical_freq_idx = (TMS_intoVF.freq > 10) & (TMS_intoVF.freq < 20);
idx_f = find(logical_freq_idx);
max_pow_nt = max(NoTMS_intoVF.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_nt = min(NoTMS_intoVF.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
max_pow_t = max(TMS_intoVF.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
min_pow_t = min(TMS_intoVF.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');

min_pow = min([min_pow_nt, min_pow_t]);
max_pow = min([max_pow_nt, max_pow_t]);
%min_pow = 0;
%max_pow = 1;
notms_missing_elecs = NoTMS_intoVF.missing_elecs
tms_missing_elecs = TMS_intoVF.missing_elecs
NoTMS_intoVF = rmfield(NoTMS_intoVF, 'missing_elecs');
TMS_intoVF = rmfield(TMS_intoVF, 'missing_elecs');

figure('Renderer', 'painters', 'Position', [0 1000 1600 800])
sgtitle(['pow range =[' num2str(round(min_pow, 2)), ', ' num2str(round(max_pow, 2)) ']']);
cfg = []; cfg.layout = 'acticap-64_md.mat'; cfg.figure = 'gcf';
cfg.ylim = [8 12]; 
cfg.highlight = 'on'; 
cfg.highlightsymbol = 'x'; cfg.highlightsize = 8;
cfg.colorbar = 'yes'; cfg.comment = 'no'; 
cfg.colormap = '*RdBu'; cfg.marker = 'off';
cfg.zlim = [min_pow max_pow];
%cfg.zlim = [0 1];
cfg.interpolatenan = 'no';

cfg.highlightchannel =  notms_missing_elecs;
subplot(2, 4, 1)
cfg.xlim = [0.5 1.5];
cfg.title = 'Alpha @ 0.5:1.5s';
ft_topoplotTFR(cfg, NoTMS_intoVF)
subplot(2, 4, 2)
cfg.xlim = [1.5 2];
cfg.title = 'Alpha @ 1.5:2s';
ft_topoplotTFR(cfg, NoTMS_intoVF)
subplot(2, 4, 3)
cfg.xlim = [3 3.5];
cfg.title = 'Alpha @ 3:3.5s';
ft_topoplotTFR(cfg, NoTMS_intoVF)
subplot(2, 4, 4)
cfg.xlim = [3.5 4.5];
cfg.title = 'Alpha @ 3.5:4.5s';
ft_topoplotTFR(cfg, NoTMS_intoVF)

cfg.highlightchannel = tms_missing_elecs;
subplot(2, 4, 5)
cfg.xlim = [0.5 1.5];
cfg.title = 'Alpha @ 0.5:1.5s';
ft_topoplotTFR(cfg, TMS_intoVF)
subplot(2, 4, 6)
cfg.xlim = [1.5 2];
cfg.title = 'Alpha @ 1.5:2s';
ft_topoplotTFR(cfg, TMS_intoVF)
subplot(2, 4, 7)
cfg.xlim = [3 3.5];
cfg.title = 'Alpha @ 3:3.5s';
ft_topoplotTFR(cfg, TMS_intoVF)
subplot(2, 4, 8)
cfg.xlim = [3.5 4.5];
cfg.title = 'Alpha @ 3.5:4.5s';
ft_topoplotTFR(cfg, TMS_intoVF)

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