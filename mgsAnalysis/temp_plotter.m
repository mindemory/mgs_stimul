f = mTFR.NT.pin.all.freq;
t = mTFR.NT.pin.all.time;
p_notms = mTFR.NT.pin.all.powspctrm;
p_tms = mTFR.T.pin.all.powspctrm;


left_occ_elecs = {'O1', 'PO1', 'PO3', 'P1', 'P3', 'P5', 'P7'};
right_occ_elecs = {'O2', 'PO2', 'PO4', 'P2', 'P4', 'P6', 'P8'};

idx_left_occ = find(ismember(mTFR.NT.pin.all.label, left_occ_elecs));
idx_right_occ = find(ismember(mTFR.NT.pin.all.label, right_occ_elecs));

n_subs = size(p_notms, 4);

figure();
for ii = 1:n_subs
    subplot(4, 4, ii)
    p1 = squeeze(mean(p_notms))
    s_nt = surf(t, f, squeeze(mean(p_notms(idx_left_occ, :, :, ii), 1, 'omitnan')));
    s_nt.EdgeColor = 'none';
    colorbar;
    caxis([5 30])
    view([0, 90])
    title(['Sub idx = ' num2str(ii, '%02d')])
end


figure();
for ii = 1:n_subs
    subplot(4, 4, ii)
    s_t = surf(t, f, squeeze(mean(p_tms(idx_left_occ, :, :, ii), 1, 'omitnan')));
    s_t.EdgeColor = 'none';
    colorbar;
    caxis([5, 30])
    zlim([5, 30])
    view([0, 90])
    title(['Sub idx = ' num2str(ii, '%02d')])
end 