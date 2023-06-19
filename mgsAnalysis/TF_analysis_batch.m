clear; close all; clc;

subjects = [16];

for subjID = subjects
    if subjID     == 1
        NoTMSdays = 2;
    elseif subjID == 3
        NoTMSdays = 2;
    elseif subjID == 6
        NoTMSdays = 2;
    elseif subjID == 8
        NoTMSdays = 3;
    elseif subjID == 12
        NoTMSdays = 2;
    elseif subjID == 13
        NoTMSdays = 3;
    elseif subjID == 14
        NoTMSdays = 2;
    elseif subjID == 15
        NoTMSdays = 3;
    elseif subjID == 16
        NoTMSdays = 3;
    end
    p = struct;
    data = struct;
    p.subjID = num2str(subjID,'%02d');
    
    tms_day_counter = 1;
    for day = 1:3
        p.day = day;
        [p, taskMap] = initialization(p, 'eeg', 0);
        fName.folder = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/day' num2str(p.day, '%02d')];
        fName.general = [fName.folder '/sub' num2str(p.subjID, '%02d') '_day' num2str(p.day, '%02d')];
        fName.epoched_prointoVF = [fName.general '_epoched_prointoVF.mat'];
        fName.epoched_prooutVF = [fName.general '_epoched_prooutVF.mat'];

        disp('Epoched files exist, importing mat files.')
        load(fName.epoched_prointoVF)
        %load(fName.epoched_prooutVF)
        if day == NoTMSdays
            data.control = data_eeg_prointoVF;
            %data_eeg_control_prooutVF = data_eeg_prooutVF;
        else
            data_eeg_TMS_prointoVF_holder(tms_day_counter) = data_eeg_prointoVF;
            %data_eeg_TMS_prooutVF_holder(tms_day_counter) = data_eeg_prooutVF;
            tms_day_counter = tms_day_counter + 1;
        end
    end
    cfg = [];
    cfg.keepsampleinfo = 'no';
    data.TMS = ft_appenddata(cfg, data_eeg_TMS_prointoVF_holder(1), data_eeg_TMS_prointoVF_holder(2));
    %data_eeg_TMS_prooutVF = ft_appenddata(cfg, data_eeg_TMS_prooutVF_holder(1), data_eeg_TMS_prooutVF_holder(2));

    create_TFplots(p, data)

end