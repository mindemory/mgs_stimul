f = mTFR.NT.pin.all.freq;
t = mTFR.NT.pin.all.time;
p_notms = mTFR.NT.pin.all.powspctrm;
p_tms = mTFR.T.pin.all.powspctrm;
baseline_tidx = find(t<0);

left_occ_elecs = {'O1', 'PO7', 'PO3', 'P1', 'P3', 'P5'};%, 'P7'};
right_occ_elecs = {'O2', 'PO8', 'PO4', 'P2', 'P4', 'P6'}; %, 'P8'};

idx_left_occ = find(ismember(mTFR.NT.pin.all.label, left_occ_elecs));
idx_right_occ = find(ismember(mTFR.NT.pin.all.label, right_occ_elecs));

n_subs = size(p_notms, 4);
s_idx_tplot = [1 2 3 4 6 7 8 9 10 11 12 13 14 16];
% s_idx_tplot = 1:15;

cmap = ft_colormap('*RdBu');

figure('Renderer','painters');
p1_notms = squeeze(mean(p_notms(idx_left_occ, :, :, s_idx_tplot), [1, 4], 'omitnan'));
p2_notms = squeeze(mean(p_notms(idx_right_occ, :, :, s_idx_tplot), [1, 4], 'omitnan'));
base_corr1 = mean(p1_notms(:, baseline_tidx), 2, 'omitnan');
base_corr2 = mean(p2_notms(:, baseline_tidx), 2, 'omitnan');
diff_notms = p1_notms - p2_notms;
diff_notms_basecorr = mean(diff_notms(:, baseline_tidx), 2, 'omitnan');
diff_notms = diff_notms - repmat(diff_notms_basecorr, 1, size(diff_notms, 2));
% p1_notms = p1_notms - repmat(base_corr1, 1, size(p1_notms, 2));
% p2_notms = p2_notms - repmat(base_corr2, 1, size(p2_notms, 2));
s_nt = surf(t, f, p1_notms);
s_nt.EdgeColor = 'none';
colormap(cmap)
colorbar;
caxis([5 30])
xlim([0, 4.5])
ylim([5 40])
view([0, 90])

figure('Renderer','painters');
p1_tms = squeeze(mean(p_tms(idx_left_occ, :, :, s_idx_tplot), [1, 4], 'omitnan'));
p2_tms = squeeze(mean(p_tms(idx_right_occ, :, :, s_idx_tplot), [1, 4], 'omitnan'));
base_corr1 = mean(p1_tms(:, baseline_tidx), 2, 'omitnan');
base_corr2 = mean(p2_tms(:, baseline_tidx), 2, 'omitnan');
diff_tms = p1_tms - p2_tms;
diff_tms_basecorr = mean(diff_tms(:, baseline_tidx), 2, 'omitnan');
diff_tms = diff_tms - repmat(diff_tms_basecorr, 1, size(diff_tms, 2));
% p1_tms = p1_tms - repmat(base_corr1, 1, size(p1_tms, 2));
% p2_tms = p2_tms - repmat(base_corr2, 1, size(p2_tms, 2));
s_nt = surf(t, f, p1_tms);
s_nt.EdgeColor = 'none';
colormap(cmap)
colorbar;
% caxis([-3 3])
caxis([5 30])
xlim([0, 4.5])
ylim([5 40])
view([0, 90])

    figure();
for ii = 1:n_subs
    subplot(4, 4, ii)
    p1_notms = squeeze(mean(p_notms(idx_left_occ, :, :, ii), 1, 'omitnan'));
    p2_notms = squeeze(mean(p_notms(idx_right_occ, :, :, ii), 1, 'omitnan'));
    base_corr1 = mean(p1_notms(:, baseline_tidx), 2, 'omitnan');
    base_corr2 = mean(p2_notms(:, baseline_tidx), 2, 'omitnan');
    p1_notms = p1_notms - repmat(base_corr1, 1, size(p1_notms, 2));
    p2_notms = p2_notms - repmat(base_corr2, 1, size(p2_notms, 2));
    s_nt = surf(t, f, p1_notms);
    s_nt.EdgeColor = 'none';
    colorbar;
    caxis([-5 5])
    view([45, 45])
    title(['Sub idx = ' num2str(ii, '%02d')])
end


figure();
for ii = 1:n_subs
    subplot(4, 4, ii)
    p1_tms = squeeze(mean(p_tms(idx_left_occ, :, :, ii), 1, 'omitnan'));
    p2_tms = squeeze(mean(p_tms(idx_right_occ, :, :, ii), 1, 'omitnan'));
    base_corr1_tms = mean(p1_tms(:, baseline_tidx), 2, 'omitnan');
    base_corr2_tms = mean(p2_tms(:, baseline_tidx), 2, 'omitnan');
    p1_tms = p1_tms - repmat(base_corr1_tms, 1, size(p1_tms, 2));
    p2_tms = p2_tms - repmat(base_corr2_tms, 1, size(p2_tms, 2));
    s_t = surf(t, f, p1_tms);
    s_t.EdgeColor = 'none';
    colorbar;
%     caxis([5, 30])
%     zlim([5, 30])
    view([0, 90])
    title(['Sub idx = ' num2str(ii, '%02d')])
end 