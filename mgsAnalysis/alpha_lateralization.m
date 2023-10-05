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

lat_alpha_notms_contra_into = [];
lat_alpha_notms_contra_out = [];
lat_alpha_notms_ipsi_into = [];
lat_alpha_notms_ipsi_out = [];

lat_alpha_tms_contra_into = [];
lat_alpha_tms_contra_out = [];
lat_alpha_tms_ipsi_into = [];
lat_alpha_tms_ipsi_out = [];
notms_num_con = [];
notms_num_inn = [];
tms_num_con = [];
tms_num_inn = [];

for subjID = subs
    disp(['We are running subj' num2str(subjID, '%02d')])
    this_subj_latalpha_contra_into = [];
    this_subj_latalpha_contra_out = [];
    this_subj_latalpha_ipsi_into = [];
    this_subj_latalpha_ipsi_out = [];
    for day = days
        this_hemisphere = HemiStimulated{subjID};
        load([eeg_dir 'sub' num2str(subjID, '%02d') '/day' num2str(day, '%02d') ...
            '/sub' num2str(subjID, '%02d') '_day' num2str(day, '%02d') '_trlfreqmat_prointoVF.mat']);
        load([eeg_dir 'sub' num2str(subjID, '%02d') '/day' num2str(day, '%02d') ...
            '/sub' num2str(subjID, '%02d') '_day' num2str(day, '%02d') '_trlfreqmat_prooutVF.mat']);
        
        fidx = intersect(find(trlfreqmat_prointoVF.freq >= 8), find(trlfreqmat_prointoVF.freq <= 12));
        lidx = find(ismember(trlfreqmat_TprointoVF.label, left_occ_elecs));
        ridx = find(ismember(trlfreqmat_prointoVF.label, right_occ_elecs));
        if subjID == 1
            time_array = trlfreqmat_prointoVF.time;
        end
        
        if strcmp(this_hemisphere, 'Left')
            contra_pow_into = mean(trlfreqmat_prointoVF.powspctrm(:, lidx, fidx, :), [1 2 3]);
            ipsi_pow_into = mean(trlfreqmat_prointoVF.powspctrm(:, ridx, fidx, :), [1 2 3]);
            contra_pow_out = mean(trlfreqmat_prooutVF.powspctrm(:, ridx, fidx, :), [1 2 3]);
            ipsi_pow_out = mean(trlfreqmat_prooutVF.powspctrm(:, lidx, fidx, :), [1 2 3]);
        else
            contra_pow_into = mean(trlfreqmat_prointoVF.powspctrm(:, ridx, fidx, :), [1 2 3]);
            ipsi_pow_into = mean(trlfreqmat_prointoVF.powspctrm(:, lidx, fidx, :), [1 2 3]);
            contra_pow_out = mean(trlfreqmat_prooutVF.powspctrm(:, lidx, fidx, :), [1 2 3]);
            ipsi_pow_out = mean(trlfreqmat_prooutVF.powspctrm(:, ridx, fidx, :), [1 2 3]);
        end

        if day == NoTMSDays(subjID)
            lat_alpha_notms_contra_into = [lat_alpha_notms_contra_into; contra_pow_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            lat_alpha_notms_contra_out = [lat_alpha_notms_contra_out; contra_pow_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
            lat_alpha_notms_ipsi_into = [lat_alpha_notms_ipsi_into; ipsi_pow_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            lat_alpha_notms_ipsi_out = [lat_alpha_notms_ipsi_out; ipsi_pow_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
            notms_num_con = [notms_num_con; (contra_pow_into - ipsi_pow_out)./ (contra_pow_into + ipsi_pow_out)];
            notms_num_inn = [notms_num_inn; (contra_pow_out - ipsi_pow_into)./ (contra_pow_out + ipsi_pow_into)];
            %notms_den = ;
        else
            this_subj_latalpha_contra_into = [this_subj_latalpha_contra_into; contra_pow_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            this_subj_latalpha_contra_out = [this_subj_latalpha_contra_out; contra_pow_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
            this_subj_latalpha_ipsi_into = [this_subj_latalpha_ipsi_into; ipsi_pow_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            this_subj_latalpha_ipsi_out = [this_subj_latalpha_ipsi_out; ipsi_pow_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
        end
        clearvars contra_pow_into ipsi_pow_into contra_pow_out ipsi_pow_out trlfreqmat_prointoVF trlfreqmat_prooutVF;
    end
    lat_alpha_tms_contra_into = [lat_alpha_tms_contra_into; mean(this_subj_latalpha_contra_into, 1)];
    lat_alpha_tms_contra_out = [lat_alpha_tms_contra_out; mean(this_subj_latalpha_contra_out, 1)];
    lat_alpha_tms_ipsi_into = [lat_alpha_tms_ipsi_into; mean(this_subj_latalpha_ipsi_into, 1)];
    lat_alpha_tms_ipsi_out = [lat_alpha_tms_ipsi_out; mean(this_subj_latalpha_ipsi_out, 1)];
    

    tms_num_con = [tms_num_con; (mean(this_subj_latalpha_contra_into, 1) - ...
        mean(this_subj_latalpha_ipsi_out, 1))./(mean(this_subj_latalpha_contra_into, 1) ...
        + mean(this_subj_latalpha_ipsi_out, 1))];
    tms_num_inn = [tms_num_inn; (mean(this_subj_latalpha_contra_out, 1) - ...
        mean(this_subj_latalpha_ipsi_into, 1))./(mean(this_subj_latalpha_contra_out, 1) ...
        + mean(this_subj_latalpha_ipsi_into, 1))];
end

% Contra
mean_lateral_notms_contra_into = mean(squeeze(lat_alpha_notms_contra_into), 1);
mean_lateral_tms_contra_into = mean(squeeze(lat_alpha_tms_contra_into), 1);
sem_lateral_notms_contra_into = std(squeeze(lat_alpha_notms_contra_into), 1)./length(subs);
sem_lateral_tms_contra_into = std(squeeze(lat_alpha_tms_contra_into), 1)./length(subs);
mean_lateral_notms_contra_out = mean(squeeze(lat_alpha_notms_contra_out), 1);
mean_lateral_tms_contra_out = mean(squeeze(lat_alpha_tms_contra_out), 1);
sem_lateral_notms_contra_out = std(squeeze(lat_alpha_notms_contra_out), 1)./length(subs);
sem_lateral_tms_contra_out = std(squeeze(lat_alpha_tms_contra_out), 1)./length(subs);

% Ipsi
mean_lateral_notms_ipsi_into = mean(squeeze(lat_alpha_notms_ipsi_into), 1);
mean_lateral_tms_ipsi_into = mean(squeeze(lat_alpha_tms_ipsi_into), 1);
sem_lateral_notms_ipsi_into = std(squeeze(lat_alpha_notms_ipsi_into), 1)./length(subs);
sem_lateral_tms_ipsi_into = std(squeeze(lat_alpha_tms_ipsi_into), 1)./length(subs);
mean_lateral_notms_ipsi_out = mean(squeeze(lat_alpha_notms_ipsi_out), 1);
mean_lateral_tms_ipsi_out = mean(squeeze(lat_alpha_tms_ipsi_out), 1);
sem_lateral_notms_ipsi_out = std(squeeze(lat_alpha_notms_ipsi_out), 1)./length(subs);
sem_lateral_tms_ipsi_out = std(squeeze(lat_alpha_tms_ipsi_out), 1)./length(subs);

y_min = 2000;
y_max = 40000;


figure();
subplot(2, 2, 1)
plot(time_array, mean_lateral_notms_contra_out, 'k-', 'LineWidth', 2)
hold on;
%plot(time_array, zeros(length(time_array), 1), 'b--', 'LineWidth', 3)
y1 = mean_lateral_notms_contra_out - sem_lateral_notms_contra_out;
y2 = mean_lateral_notms_contra_out + sem_lateral_notms_contra_out;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);

plot(time_array, mean_lateral_tms_contra_out, 'r-', 'LineWidth', 2)
hold on;
y1 = mean_lateral_tms_contra_out - sem_lateral_tms_contra_out;
y2 = mean_lateral_tms_contra_out + sem_lateral_tms_contra_out;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
xlabel('Time (s)')
ylabel('Alpha power (raw)')
ylim([y_min, y_max])
hold off;

subplot(2, 2, 2)
plot(time_array, mean_lateral_notms_contra_into, 'k-', 'LineWidth', 2)
hold on;
%plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
y1 = mean_lateral_notms_contra_into - sem_lateral_notms_contra_into;
y2 = mean_lateral_notms_contra_into + sem_lateral_notms_contra_into;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);

plot(time_array, mean_lateral_tms_contra_into, 'r-', 'LineWidth', 2)
hold on;
%plot(time_array, zeros(length(time_array), 1), 'r--', 'LineWidth', 3)
y1 = mean_lateral_tms_contra_into - sem_lateral_tms_contra_into;
y2 = mean_lateral_tms_contra_into + sem_lateral_tms_contra_into;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
xlabel('Time (s)')
ylabel('Alpha power (raw)')
ylim([y_min, y_max])
hold off;

subplot(2, 2, 3)
plot(time_array, mean_lateral_notms_ipsi_out, 'k-', 'LineWidth', 2)
hold on;
%plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
y1 = mean_lateral_notms_ipsi_out - sem_lateral_notms_ipsi_out;
y2 = mean_lateral_notms_ipsi_out + sem_lateral_notms_ipsi_out;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);

plot(time_array, mean_lateral_tms_ipsi_out, 'r-', 'LineWidth', 2)
hold on;
y1 = mean_lateral_tms_ipsi_out - sem_lateral_tms_ipsi_out;
y2 = mean_lateral_tms_ipsi_out + sem_lateral_tms_ipsi_out;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
xlabel('Time (s)')
ylabel('Alpha power (raw)')
ylim([y_min, y_max])
hold off;

subplot(2, 2, 4)
plot(time_array, mean_lateral_notms_ipsi_into, 'k-', 'LineWidth', 2)
hold on;
%plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
y1 = mean_lateral_notms_ipsi_into - sem_lateral_notms_ipsi_into;
y2 = mean_lateral_notms_ipsi_into + sem_lateral_notms_ipsi_into;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);

plot(time_array, mean_lateral_tms_ipsi_into, 'r-', 'LineWidth', 2)
hold on;
y1 = mean_lateral_tms_ipsi_into - sem_lateral_tms_ipsi_into;
y2 = mean_lateral_tms_ipsi_into + sem_lateral_tms_ipsi_into;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
xlabel('Time (s)')
ylabel('Alpha power (raw)')
ylim([y_min, y_max])
hold off;

tms_num = mean_lateral_tms_contra_into - mean_lateral_tms_ipsi_out;
tms_den = mean_lateral_tms_contra_into + mean_lateral_tms_ipsi_out;
notms_num = mean_lateral_notms_contra_into - mean_lateral_notms_ipsi_out;
notms_den = mean_lateral_notms_contra_into + mean_lateral_notms_ipsi_out;
lateralized_alpha_tms = tms_num./tms_den;
lateralized_alpha_notms = notms_num./notms_den;
std_tms_contra_i = sem_lateral_tms_contra_into.*length(subs);
std_tms_ipsi_i = sem_lateral_tms_ipsi_into.*length(subs);
std_notms_contra_i = sem_lateral_notms_contra_into.*length(subs);
std_notms_ipsi_i = sem_lateral_notms_ipsi_into.*length(subs);

sem_tms_num = sqrt(std_tms_contra_i.^2+std_tms_ipsi_i.^2);
sem_notms_num = sqrt(std_notms_contra_i.^2+std_notms_ipsi_i.^2);
sem_alpha_tms = lateralized_alpha_tms .* sqrt(((sem_tms_num./tms_num)).^2+((sem_tms_num./tms_den).^2)) ./length(subs);
sem_alpha_notms = lateralized_alpha_notms .* sqrt(((sem_notms_num./notms_num)).^2+((sem_notms_num./notms_den).^2))./length(subs);


mean_lateral_notms_con = mean(squeeze(notms_num_con), 1);
mean_lateral_tms_con = mean(squeeze(tms_num_con), 1);
sem_lateral_notms_con = std(squeeze(notms_num_con), 1)./(length(subs)-1);
sem_lateral_tms_con = std(squeeze(tms_num_con), 1)./(length(subs)-1);

mean_lateral_notms_inn = mean(squeeze(notms_num_inn), 1);
mean_lateral_tms_inn = mean(squeeze(tms_num_inn), 1);
sem_lateral_notms_inn = std(squeeze(notms_num_inn), 1)./length(subs);
sem_lateral_tms_inn = std(squeeze(tms_num_inn), 1)./length(subs);

figure();
%subplot(2, 1, 1)
plot(time_array, mean_lateral_notms_con, 'k-', 'LineWidth', 2, 'DisplayName', 'No TMS');
hold on;
plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3, 'HandleVisibility','off');
y1 = mean_lateral_notms_con - sem_lateral_notms_con;
y2 = mean_lateral_notms_con + sem_lateral_notms_con;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3, 'HandleVisibility','off');

plot(time_array, mean_lateral_tms_con, 'r-', 'LineWidth', 2, 'DisplayName', 'TMS');
hold on;
y1 = mean_lateral_tms_con - sem_lateral_tms_con;
y2 = mean_lateral_tms_con + sem_lateral_tms_con;
fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3, 'HandleVisibility','off');
xlabel('Time (s)')
ylabel('Alpha Lateralization')
title('Alpha lateralization (right - left)')
legend('Location', 'southeast')
plot(time_array(sig==1), 0.08* ones(sum(sig), 1), 'k*', 'MarkerSize', 5, 'LineWidth', 2, 'HandleVisibility','off');
%hold off;


sig = zeros(length(time_array), 1);
global_tms = squeeze(tms_num_con);
global_notms = squeeze(notms_num_con);
corr_fact = length(2:length(time_array)-1);
for t = 2:length(time_array)-1
    
    this_tms = global_tms(:, t-1:t+1);
    this_notms = global_notms(:, t-1:t+1);
    sig(t) = ttest(this_tms(:), this_notms(:), 'Alpha', 0.025);
end
[R,P] = corrcoef(mean_lateral_notms_con,mean_lateral_tms_con);
% subplot(2, 1, 2)
% plot(time_array, mean_lateral_notms_inn, 'k-', 'LineWidth', 2)
% hold on;
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% y1 = mean_lateral_notms_inn - sem_lateral_notms_inn;
% y2 = mean_lateral_notms_inn + sem_lateral_notms_inn;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% 
% plot(time_array, mean_lateral_tms_inn, 'r-', 'LineWidth', 2)
% hold on;
% y1 = mean_lateral_tms_inn - sem_lateral_tms_inn;
% y2 = mean_lateral_tms_inn + sem_lateral_tms_inn;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% xlabel('Time (s)')
% ylabel('Alpha power (raw)')
% hold off;

% figure();
% subplot(2, 2, 1)
% plot(time_array, mean_lateral_notms_contra_into, 'r-', 'LineWidth', 2)
% hold on;
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% y1 = mean_lateral_notms_contra_into - sem_lateral_notms_contra_into;
% y2 = mean_lateral_notms_contra_into + sem_lateral_notms_contra_into;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% xlabel('Time (s)')
% ylabel('Alpha Lateralization Index (ALI)')
% ylim([2000, 25000])
% hold off;
% 
% subplot(2, 2, 2)
% plot(time_array, mean_lateral_notms_contra_out, 'r-', 'LineWidth', 2)
% hold on;
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% y1 = mean_lateral_notms_contra_out - sem_lateral_notms_contra_out;
% y2 = mean_lateral_notms_contra_out + sem_lateral_notms_contra_out;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% xlabel('Time (s)')
% ylabel('Alpha Lateralization Index (ALI)')
% ylim([2000, 25000])
% 
% hold off;
% 
% subplot(2, 2, 3)
% plot(time_array, mean_lateral_tms_contra_into, 'r-', 'LineWidth', 2)
% hold on;
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% y1 = mean_lateral_tms_contra_into - sem_lateral_tms_contra_into;
% y2 = mean_lateral_tms_contra_into + sem_lateral_tms_contra_into;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% xlabel('Time (s)')
% ylabel('Alpha Lateralization Index (ALI)')
% ylim([2000, 25000])
% 
% hold off;
% 
% subplot(2, 2, 4)
% plot(time_array, mean_lateral_tms_contra_out, 'r-', 'LineWidth', 2)
% hold on;
% plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% y1 = mean_lateral_tms_contra_out - sem_lateral_tms_contra_out;
% y2 = mean_lateral_tms_contra_out + sem_lateral_tms_contra_out;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% xlabel('Time (s)')
% ylabel('Alpha Lateralization Index (ALI)')
% ylim([2000, 25000])
% 
% hold off;

figure();
hold on;
legend_names ={'baseline'};
plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
for sidx = 1:length(subs)
    subjID = subs(sidx);
    plot(time_array, squeeze(lat_alpha_tms_contra_out(sidx, :, :, :)- lat_alpha_tms_contra_into(sidx, :, :, :)), 'LineWidth', 2)
    legend_names{end+1} = sprintf('sub %d', subjID);
end
xlabel('Time (s)')
ylabel('Alpha Lateralization Index (ALI)')
legend(legend_names);
hold off;
