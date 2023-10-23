clear; close all; clc;

meta_data = readtable(['/datc/MD_TMS_EEG/analysis/EEG_TMS_meta - Summary.csv']);
HemiStimulated = table2cell(meta_data(:, ["HemisphereStimulated"]));
NoTMSDays = table2array(meta_data(:, ["NoTMSDay"]));
eeg_dir = '/datc/MD_TMS_EEG/EEGfiles/';
left_occ_elecs = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_occ_elecs = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

days = [1 2 3];
%subs = [1 3 5 6 7 8 12 13 14 15 16 17 22 24];
subs = [1 5 7 6 8 12 24];

notms_contra_into = [];
notms_contra_out = [];
notms_ipsi_into = [];
notms_ipsi_out = [];

tms_contra_into = [];
tms_contra_out = [];
tms_ipsi_into = [];
tms_ipsi_out = [];
notms_num_con = [];
notms_num_inn = [];
tms_num_con = [];
tms_num_inn = [];

for subjID = subs
    disp(['We are running subj' num2str(subjID, '%02d')])
    this_subj_contra_into = [];
    this_subj_contra_out = [];
    this_subj_ipsi_into = [];
    this_subj_ipsi_out = [];
    for day = days
        this_hemisphere = HemiStimulated{subjID};
        load([eeg_dir 'sub' num2str(subjID, '%02d') '/day' num2str(day, '%02d') ...
            '/sub' num2str(subjID, '%02d') '_day' num2str(day, '%02d') '_trlfreqmat_prointoVF.mat']);
        load([eeg_dir 'sub' num2str(subjID, '%02d') '/day' num2str(day, '%02d') ...
            '/sub' num2str(subjID, '%02d') '_day' num2str(day, '%02d') '_trlfreqmat_prooutVF.mat']);
        
        fidx = intersect(find(trlfreqmat_prointoVF.freq >= 8), find(trlfreqmat_prointoVF.freq <= 12));
        lidx = find(ismember(trlfreqmat_prointoVF.label, left_occ_elecs));
        ridx = find(ismember(trlfreqmat_prointoVF.label, right_occ_elecs));
        if subjID == 1
            time_array = trlfreqmat_prointoVF.time;
        end
%         trlfreqmat_prointoVF.powspctrm = squeeze(mean(trlfreqmat_prointoVF.powspctrm, 1, 'omitnan'));
%         trlfreqmat_prooutVF.powspctrm = squeeze(mean(trlfreqmat_prooutVF.powspctrm, 1, 'omitnan'));
%         trlfreqmat_prointoVF.
        if strcmp(this_hemisphere, 'Left')
            contra_pow_into = mean(trlfreqmat_prointoVF.powspctrm(:, lidx, :, :), [1 2]);
            ipsi_pow_into = mean(trlfreqmat_prointoVF.powspctrm(:, ridx, :, :), [1 2]);
            contra_pow_out = mean(trlfreqmat_prooutVF.powspctrm(:, ridx, :, :), [1 2]);
            ipsi_pow_out = mean(trlfreqmat_prooutVF.powspctrm(:, lidx, :, :), [1 2]);
        else
            contra_pow_into = mean(trlfreqmat_prointoVF.powspctrm(:, ridx, :, :), [1 2]);
            ipsi_pow_into = mean(trlfreqmat_prointoVF.powspctrm(:, lidx, :, :), [1 2]);
            contra_pow_out = mean(trlfreqmat_prooutVF.powspctrm(:, lidx, :, :), [1 2]);
            ipsi_pow_out = mean(trlfreqmat_prooutVF.powspctrm(:, ridx, :, :), [1 2]);
        end

        if day == NoTMSDays(subjID)
            notms_contra_into = [notms_contra_into; contra_pow_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            notms_contra_out = [notms_contra_out; contra_pow_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
            notms_ipsi_into = [notms_ipsi_into; ipsi_pow_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            notms_ipsi_out = [notms_ipsi_out; ipsi_pow_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
            notms_num_con = [notms_num_con; (contra_pow_into - ipsi_pow_out)./ (contra_pow_into + ipsi_pow_out)];
            notms_num_inn = [notms_num_inn; (contra_pow_out - ipsi_pow_into)./ (contra_pow_out + ipsi_pow_into)];
            %notms_den = ;
        else
            this_subj_contra_into = [this_subj_contra_into; contra_pow_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            this_subj_contra_out = [this_subj_contra_out; contra_pow_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
            this_subj_ipsi_into = [this_subj_ipsi_into; ipsi_pow_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            this_subj_ipsi_out = [this_subj_ipsi_out; ipsi_pow_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
        end
        clearvars contra_pow_into ipsi_pow_into contra_pow_out ipsi_pow_out trlfreqmat_prointoVF trlfreqmat_prooutVF;
    end
    tms_contra_into = [tms_contra_into; mean(this_subj_contra_into, 1)];
    tms_contra_out = [tms_contra_out; mean(this_subj_contra_out, 1)];
    tms_ipsi_into = [tms_ipsi_into; mean(this_subj_ipsi_into, 1)];
    tms_ipsi_out = [tms_ipsi_out; mean(this_subj_ipsi_out, 1)];
    

    tms_num_con = [tms_num_con; (mean(this_subj_contra_into, 1) - ...
        mean(this_subj_ipsi_out, 1))./(mean(this_subj_contra_into, 1) ...
        + mean(this_subj_ipsi_out, 1))];
    tms_num_inn = [tms_num_inn; (mean(this_subj_contra_out, 1) - ...
        mean(this_subj_ipsi_into, 1))./(mean(this_subj_contra_out, 1) ...
        + mean(this_subj_ipsi_into, 1))];
end

freq = tms_trlfreqmat_prointoVF.freq;
rem_idx = find(freq<5);
freq(rem_idx) = [];
freq_labels = [10 20 30 40];
freq_str = cellstr(num2str(freq_labels'));
freq_pos = zeros(size(freq_labels));  
for ii = 1:length(freq_labels)
    freq_pos(ii) = find(freq < freq_labels(ii), 1, 'last');
end

time = tms_trlfreqmat_prointoVF.time;
time_labels = 0:0.5:5;
time_str = cellstr(num2str(time_labels'));
time_pos = zeros(size(time_labels));  
for ii = 2:length(time_labels)
    time_pos(ii) = find(time < time_labels(ii), 1, 'last');
end

tms_mat = squeeze(mean(tms_num_con, 1, 'omitnan'));
notms_mat = squeeze(mean(notms_num_con, 1, 'omitnan'));


figure();
subplot(2, 1, 1)
imagesc(notms_mat(max(rem_idx)+1:end, :));
colormap(jet); caxis([-0.2, 0.2]); colorbar;
set(gca, 'YDir', 'normal');
set(gca, 'YTick', freq_pos);
set(gca, 'YTickLabel', freq_str);
set(gca, 'XTick', time_pos);
set(gca, 'XTickLabel', time_str);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
title('No TMS (right - left)')

subplot(2, 1, 2)
imagesc(tms_mat(max(rem_idx)+1:end, :));
colormap(jet); caxis([-0.2, 0.2]); colorbar;

set(gca, 'YDir', 'normal');
set(gca, 'YTick', freq_pos);
set(gca, 'YTickLabel', freq_str);
set(gca, 'XTick', time_pos);
set(gca, 'XTickLabel', time_str);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
title('TMS (right - left)')



figure();
imagesc(tms_mat);
set(gca, 'YDir', 'normal');
ylabel('Frequency (Hz)')
xlabel('Time(s)')
