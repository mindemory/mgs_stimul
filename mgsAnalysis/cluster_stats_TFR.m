p_t = mTFR.T.pin.all;
p_t.powspctrm = permute(p_t.powspctrm, [4, 1, 2, 3]);
p_t.dimord = 'subj_chan_freq_time';

p_nt = mTFR.NT.pin.all;
p_nt.powspctrm = permute(p_nt.powspctrm, [4, 1, 2, 3]);
p_nt.dimord = 'subj_chan_freq_time';

cfg = [];

cfg.channel          = left_occ_elecs;
cfg.latency          = [3 4.5];
cfg.frequency        = [5 40];
cfg.method           = 'montecarlo';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.1;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.05;
cfg.numrandomization = 1e3;
% specifies with which sensors other sensors can form clusters
cfg_neighb.method    = 'distance';
cfg.neighbours       = neighbors;

subj = 15;
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg, p_t, p_nt);

% figure(); imshow(squeeze(mean(stat.mask, 1)));

figure(); 
% imshow(flipud(p1_notms-p1_tms))
% hold on;
imshow(flipud(~squeeze(mean(stat.posclusterslabelmat(:, :, :), 1))));


%% Plotting clusterstats
figure('Renderer','painters');
imagesc(t, f, p1_tms-p1_notms);
set(gca, 'YDir', 'normal');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
xlim([0, 4.5])
ylim([5, 40])
caxis([-1, 1])
hold on;
t_contour = linspace(-1, 4.5, size(stat.mask, 3));
f_contour = linspace(5, 40, size(stat.mask, 2));
contour(stat.time, stat.freq, squeeze(mean(stat.mask, 1)), 1, 'LineColor', 'r', 'LineWidth', 2)
colorbar();