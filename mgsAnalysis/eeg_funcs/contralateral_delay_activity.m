
clear; close all; clc;

meta_data = readtable(['/datc/MD_TMS_EEG/analysis/EEG_TMS_meta - Summary.csv']);
HemiStimulated = table2cell(meta_data(:, ["HemisphereStimulated"]));
NoTMSDays = table2array(meta_data(:, ["NoTMSDay"]));
eeg_dir = '/datc/MD_TMS_EEG/EEGfiles/';
left_occ_elecs = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_occ_elecs = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

days = [1 2 3];
%subs = [1 3 5 6 7 8 12 13 14 15 16 17 22 24];
subs = [1 3 5 6 7 8 11 12 13 14 15 16 17 18 22 23 24 25 26 27];

cda_notms_contra_into = [];
cda_notms_contra_out = [];
cda_notms_ipsi_into = [];
cda_notms_ipsi_out = [];

cda_tms_contra_into = [];
cda_tms_contra_out = [];
cda_tms_ipsi_into = [];
cda_tms_ipsi_out = [];
notms_num_con = [];
notms_num_inn = [];
tms_num_con = [];
tms_num_inn = [];
for subjID = subs
    disp(['We are running subj' num2str(subjID, '%02d')])
    this_subj_erp_contra_into = [];
    this_subj_erp_contra_out = [];
    this_subj_erp_ipsi_into = [];
    this_subj_erp_ipsi_out = [];
    for day = days
        this_hemisphere = HemiStimulated{subjID};
        
        if day == NoTMSDays(subjID)
            load([eeg_dir 'sub' num2str(subjID, '%02d') '/day' num2str(day, '%02d') ...
                '/sub' num2str(subjID, '%02d') '_day' num2str(day, '%02d') '_erp.mat']);
            erp_prointoVF = ERP.antiintoVF;%ERP.prointoVF;
            erp_prooutVF = ERP.antioutVF;%ERP.prooutVF;
        else
            load([eeg_dir 'sub' num2str(subjID, '%02d') '/day' num2str(day, '%02d') ...
                '/sub' num2str(subjID, '%02d') '_day' num2str(day, '%02d') '_tms_erp.mat']);
            
            erp_prointoVF = TMS_ERP.antiintoVF; %TMS_ERP.prointoVF;
            erp_prooutVF = TMS_ERP.antioutVF; %TMS_ERP.prooutVF;
        end
        %fidx = intersect(find(erp_prointoVF.freq >= 11), find(erp_prointoVF.freq <= 15));
        lidx = find(ismember(erp_prointoVF.label, left_occ_elecs));
        ridx = find(ismember(erp_prointoVF.label, right_occ_elecs));
        if subjID == 1
            time_array = erp_prointoVF.time;
        end

        if strcmp(this_hemisphere, 'Left')
            contra_erp_into = mean(erp_prointoVF.avg(lidx,  :), 1);
            ipsi_erp_into = mean(erp_prointoVF.avg(ridx, :), 1);
            contra_erp_out = mean(erp_prooutVF.avg(ridx,  :), 1);
            ipsi_erp_out = mean(erp_prooutVF.avg(lidx, :), 1);
        else
            contra_erp_into = mean(erp_prointoVF.avg(ridx,  :), 1);
            ipsi_erp_into = mean(erp_prointoVF.avg(lidx, :), 1);
            contra_erp_out = mean(erp_prooutVF.avg(lidx,  :), 1);
            ipsi_erp_out = mean(erp_prooutVF.avg(ridx, :), 1);
        end
        
        if day == NoTMSDays(subjID)
            cda_notms_contra_into = [cda_notms_contra_into; contra_erp_into]; 
            cda_notms_contra_out = [cda_notms_contra_out; contra_erp_out]; 
            cda_notms_ipsi_into = [cda_notms_contra_out; ipsi_erp_into]; 
            cda_notms_ipsi_out = [cda_notms_ipsi_out; ipsi_erp_out]; 
            notms_num_con = [notms_num_con; (contra_erp_into - ipsi_erp_out)];
            notms_num_inn = [notms_num_inn; (contra_erp_out - ipsi_erp_into)];
            %notms_den = ;
        else
            this_subj_erp_contra_into = [this_subj_erp_contra_into; contra_erp_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            this_subj_erp_contra_out = [this_subj_erp_contra_out; contra_erp_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
            this_subj_erp_ipsi_into = [this_subj_erp_ipsi_into; ipsi_erp_into]; %(contra_pow_into-ipsi_pow_into)./(contra_pow_into+ipsi_pow_into)];
            this_subj_erp_ipsi_out = [this_subj_erp_ipsi_out; ipsi_erp_out]; %(contra_pow_out-ipsi_pow_out)./(contra_pow_out+ipsi_pow_out)];
        end

        clearvars contra_erp_into contra_erp_out ipsi_erp_into ipsi_erp_out erp_prointoVF erp_prooutVF;
    end
    cda_tms_contra_into = [cda_tms_contra_into; mean(this_subj_erp_contra_into, 1)];
    cda_tms_contra_out = [cda_tms_contra_out; mean(this_subj_erp_contra_out, 1)];
    cda_tms_ipsi_into = [cda_tms_ipsi_into; mean(this_subj_erp_ipsi_into, 1)];
    cda_tms_ipsi_out = [cda_tms_ipsi_out; mean(this_subj_erp_ipsi_out, 1)];
    tms_num_con = [tms_num_con; (mean(this_subj_erp_contra_into, 1) - ...
        mean(this_subj_erp_ipsi_out, 1))];
    tms_num_inn = [tms_num_inn; (mean(this_subj_erp_contra_out, 1) - ...
        mean(this_subj_erp_ipsi_into, 1))];
end

% Contra
mean_lateral_notms_contra_into = mean(squeeze(cda_notms_contra_into), 1);
mean_lateral_tms_contra_into = mean(squeeze(cda_tms_contra_into), 1);
sem_lateral_notms_contra_into = std(squeeze(cda_notms_contra_into), 1)./sqrt(length(subs));
sem_lateral_tms_contra_into = std(squeeze(cda_tms_contra_into), 1)./sqrt(length(subs));
mean_lateral_notms_contra_out = mean(squeeze(cda_notms_contra_out), 1);
mean_lateral_tms_contra_out = mean(squeeze(cda_tms_contra_out), 1);
sem_lateral_notms_contra_out = std(squeeze(cda_notms_contra_out), 1)./sqrt(length(subs));
sem_lateral_tms_contra_out = std(squeeze(cda_tms_contra_out), 1)./sqrt(length(subs));

% Ipsi
mean_lateral_notms_ipsi_into = mean(squeeze(cda_notms_ipsi_into), 1);
mean_lateral_tms_ipsi_into = mean(squeeze(cda_tms_ipsi_into), 1);
sem_lateral_notms_ipsi_into = std(squeeze(cda_notms_ipsi_into), 1)./sqrt(length(subs));
sem_lateral_tms_ipsi_into = std(squeeze(cda_tms_ipsi_into), 1)./sqrt(length(subs));
mean_lateral_notms_ipsi_out = mean(squeeze(cda_notms_ipsi_out), 1);
mean_lateral_tms_ipsi_out = mean(squeeze(cda_tms_ipsi_out), 1);
sem_lateral_notms_ipsi_out = std(squeeze(cda_notms_ipsi_out), 1)./sqrt(length(subs));
sem_lateral_tms_ipsi_out = std(squeeze(cda_tms_ipsi_out), 1)./sqrt(length(subs));

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
% y1 = mean_lateral_notms_con - sem_lateral_notms_con;
% y2 = mean_lateral_notms_con + sem_lateral_notms_con;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3, 'HandleVisibility','off');

plot(time_array, mean_lateral_tms_con, 'r-', 'LineWidth', 2, 'DisplayName', 'TMS');
% hold on;
% y1 = mean_lateral_tms_con - sem_lateral_tms_con;
% y2 = mean_lateral_tms_con + sem_lateral_tms_con;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3, 'HandleVisibility','off');
xlabel('Time (s)')
ylabel('Alpha Lateralization')
title('Alpha lateralization (right - left)')
legend()
hold off;

%%
% figure();
% subplot(2, 2, 1)
% plot(time_array, mean_lateral_notms_contra_out, 'k-', 'LineWidth', 2)
% hold on;
% %plot(time_array, zeros(length(time_array), 1), 'b--', 'LineWidth', 3)
% y1 = mean_lateral_notms_contra_out - sem_lateral_notms_contra_out;
% y2 = mean_lateral_notms_contra_out + sem_lateral_notms_contra_out;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% 
% % plot(time_array, mean_lateral_tms_contra_out, 'r-', 'LineWidth', 2)
% % hold on;
% % y1 = mean_lateral_tms_contra_out - sem_lateral_tms_contra_out;
% % y2 = mean_lateral_tms_contra_out + sem_lateral_tms_contra_out;
% % fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% xlabel('Time (s)')
% ylabel('ERP (uV)')
% %ylim([y_min, y_max])
% hold off;
% 
% subplot(2, 2, 2)
% plot(time_array, mean_lateral_notms_contra_into, 'k-', 'LineWidth', 2)
% hold on;
% %plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% y1 = mean_lateral_notms_contra_into - sem_lateral_notms_contra_into;
% y2 = mean_lateral_notms_contra_into + sem_lateral_notms_contra_into;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% 
% % plot(time_array, mean_lateral_tms_contra_into, 'r-', 'LineWidth', 2)
% % hold on;
% % %plot(time_array, zeros(length(time_array), 1), 'r--', 'LineWidth', 3)
% % y1 = mean_lateral_tms_contra_into - sem_lateral_tms_contra_into;
% % y2 = mean_lateral_tms_contra_into + sem_lateral_tms_contra_into;
% % fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% xlabel('Time (s)')
% ylabel('ERP (uV)')
% %ylim([y_min, y_max])
% hold off;
% 
% subplot(2, 2, 3)
% plot(time_array, mean_lateral_notms_ipsi_out, 'k-', 'LineWidth', 2)
% hold on;
% %plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% y1 = mean_lateral_notms_ipsi_out - sem_lateral_notms_ipsi_out;
% y2 = mean_lateral_notms_ipsi_out + sem_lateral_notms_ipsi_out;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% 
% % plot(time_array, mean_lateral_tms_ipsi_out, 'r-', 'LineWidth', 2)
% % hold on;
% % y1 = mean_lateral_tms_ipsi_out - sem_lateral_tms_ipsi_out;
% % y2 = mean_lateral_tms_ipsi_out + sem_lateral_tms_ipsi_out;
% % fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% xlabel('Time (s)')
% ylabel('ERP (uV)')
% %ylim([y_min, y_max])
% hold off;
% 
% subplot(2, 2, 4)
% plot(time_array, mean_lateral_notms_ipsi_into, 'k-', 'LineWidth', 2)
% hold on;
% %plot(time_array, zeros(length(time_array), 1), 'k--', 'LineWidth', 3)
% y1 = mean_lateral_notms_ipsi_into - sem_lateral_notms_ipsi_into;
% y2 = mean_lateral_notms_ipsi_into + sem_lateral_notms_ipsi_into;
% fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'k', 'FaceAlpha', 0.3);
% 
% % plot(time_array, mean_lateral_tms_ipsi_into, 'r-', 'LineWidth', 2)
% % hold on;
% % y1 = mean_lateral_tms_ipsi_into - sem_lateral_tms_ipsi_into;
% % y2 = mean_lateral_tms_ipsi_into + sem_lateral_tms_ipsi_into;
% % fill([time_array, fliplr(time_array)], [y1, fliplr(y2)], 'r', 'FaceAlpha', 0.3);
% xlabel('Time (s)')
% ylabel('ERP (uV)')
% %ylim([y_min, y_max])
% hold off;
% 
