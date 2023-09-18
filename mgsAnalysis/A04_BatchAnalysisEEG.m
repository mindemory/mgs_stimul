function A04_BatchAnalysisEEG()
clearvars; close all; clc;
warning('off', 'all');

subs =  [5];%[1 3 5 6 7 8 12 13 14 15 16 17 18 22 23 24];
days = [1, 2, 3];

for subjID = subs
    disp(['Running subj = ' num2str(subjID, '%02d')])
    for day = days
        p.subjID = num2str(subjID,'%02d');
        p.day = day;

        [p, taskMap] = initialization(p, 'eeg', 0);
        p.figure = [p.datc '/Figures/eeg_analysis'];
        meta_data = readtable([p.analysis '/EEG_TMS_meta - Summary.csv']);
        HemiStimulated = table2cell(meta_data(:, ["HemisphereStimulated"]));
        this_hemisphere = HemiStimulated{subjID};
        NoTMSDays = table2array(meta_data(:, ["NoTMSDay"]));

        % File names
        fName.folder = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/day' num2str(p.day, '%02d')];
        if ~exist(fName.folder, 'dir')
            mkdir(fName.folder)
        end
        fName.general = [fName.folder '/sub' num2str(p.subjID, '%02d') '_day' num2str(p.day, '%02d')];
        fName.load = [fName.general '_raweeg.mat'];
        fName.interp = [fName.general '_interpolated.mat'];
        fName.bandpass = [fName.general '_bandpass.mat'];
        fName.bandpass_TMS = [fName.general '_bandpass_TMS.mat'];
        fName.freqmat_prointoVF = [fName.general '_freqmat_prointoVF.mat'];
        fName.freqmat_prooutVF = [fName.general '_freqmat_prooutVF.mat'];
        fName.freqmat_antiintoVF = [fName.general '_freqmat_antiintoVF.mat'];
        fName.freqmat_antioutVF = [fName.general '_freqmat_antioutVF.mat'];
        fName.freqmat_ipsi_pro = [fName.general '_freqmat_ipsi_pro.mat'];
        fName.freqmat_ipsi_anti = [fName.general '_freqmat_ipsi_anti.mat'];
        fName.freqmat_contra_pro = [fName.general '_freqmat_contra_pro.mat'];
        fName.freqmat_contra_anti = [fName.general '_freqmat_contra_anti.mat'];
        if p.day ~= NoTMSDays(subjID)
            fName.tms_epoched_alltrls = [fName.general '_tms_epoched_alltrls.mat'];
            fName.tms_epoched_prointoVF = [fName.general '_tms_epoched_prointoVF.mat'];
            fName.tms_epoched_prooutVF = [fName.general '_tms_epoched_prooutVF.mat'];
            fName.tms_epoched_antiintoVF = [fName.general '_tms_epoched_antiintoVF.mat'];
            fName.tms_epoched_antioutVF = [fName.general '_tms_epoched_antioutVF.mat'];
            fName.tms_freqmat_prointoVF = [fName.general '_tms_freqmat_prointoVF.mat'];
            fName.tms_freqmat_prooutVF = [fName.general '_tms_freqmat_prooutVF.mat'];
            fName.tms_freqmat_antiintoVF = [fName.general '_tms_freqmat_antiintoVF.mat'];
            fName.tms_freqmat_antioutVF = [fName.general '_tms_freqmat_antioutVF.mat'];
        end
        load(fName.freqmat_prointoVF);
        logical_idx_before = (freqmat_prointoVF.time > 0.5) & (freqmat_prointoVF.time < 2);
        idx_t_before = find(logical_idx_before);
        logical_idx_after = (freqmat_prointoVF.time > 3.2) & (freqmat_prointoVF.time < 4.2);
        idx_t_after = find(logical_idx_after);
        idx_t = [idx_t_before idx_t_after];
        
        logical_freq_idx = (freqmat_prointoVF.freq > 10) & (freqmat_prointoVF.freq < 20);
        idx_f = find(logical_freq_idx);
        max_power = max(freqmat_prointoVF.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
        min_power = min(freqmat_prointoVF.powspctrm(:, idx_f, idx_t), [], 'all', 'omitnan');
        freqmat_prointoVF.powspctrm = (freqmat_prointoVF.powspctrm - min_power) / (max_power - min_power);

        if p.day == NoTMSDays(subjID)
            tic
            TFR_notms_prointoVF_ipsi = combineTFRs(freqmat_prointoVF, this_hemisphere, 1);
            toc
            TFR_notms_prointoVF_contra = combineTFRs(freqmat_prointoVF, this_hemisphere, 0);
            TFR_notms_prointoVF = alignelecs(freqmat_prointoVF, this_hemisphere);
        else
            if ~exist('TFR_tms_prointoVF', 'var')
                TFR_tms_prointoVF_ipsi = combineTFRs(freqmat_prointoVF, this_hemisphere, 1);
                TFR_tms_prointoVF_contra = combineTFRs(freqmat_prointoVF, this_hemisphere, 0);
                TFR_tms_prointoVF = alignelecs(freqmat_prointoVF, this_hemisphere);
            else
                TFR_tms_prointoVF_ipsi = combineTFRs(freqmat_prointoVF, this_hemisphere, 1, TFR_tms_prointoVF_ipsi);
                TFR_tms_prointoVF_contra = combineTFRs(freqmat_prointoVF, this_hemisphere, 0, TFR_tms_prointoVF_contra);
                TFR_tms_prointoVF = alignelecs(freqmat_prointoVF, this_hemisphere, TFR_tms_prointoVF);
            end
        end
    end
        
    figname.compare_TFR = [p.figure '/indiv_TFR/compar_TFR_prointoVF_sub' num2str(p.subjID, '%02d') '.png'];
    figname.compare_topo = [p.figure '/indiv_topo/compar_topo_prointoVF_sub' num2str(p.subjID, '%02d') '.png'];
    if ~exist(figname.compare_TFR, 'file')
        compare_conds(TFR_notms_prointoVF_ipsi, TFR_notms_prointoVF_contra, ...
            TFR_tms_prointoVF_ipsi, TFR_tms_prointoVF_contra)
        saveas(gcf, figname.compare_TFR, 'png')
    end
    if ~exist(figname.compare_topo, 'file')
        create_topo(TFR_notms_prointoVF, TFR_tms_prointoVF)
        saveas(gcf, figname.compare_topo, 'png')
    end
    
    % Store for combined analysis
    if ~exist('mTFR_notms_prointo_ipsi', 'var')
        mTFR_notms_prointo_ipsi = TFR_notms_prointoVF_ipsi;
    else
        mTFR_notms_prointo_ipsi = subject_level_grouping(mTFR_notms_prointo_ipsi, TFR_notms_prointoVF_ipsi);
    end

    if ~exist('mTFR_notms_prointo_contra', 'var')
        mTFR_notms_prointo_contra = TFR_notms_prointoVF_contra;
    else
        mTFR_notms_prointo_contra = subject_level_grouping(mTFR_notms_prointo_contra, TFR_notms_prointoVF_contra);
    end
    
    if ~exist('mTFR_tms_prointo_ipsi', 'var')
        mTFR_tms_prointo_ipsi = TFR_tms_prointoVF_ipsi;
    else
        mTFR_tms_prointo_ipsi = subject_level_grouping(mTFR_tms_prointo_ipsi, TFR_tms_prointoVF_ipsi);
    end

    if ~exist('mTFR_tms_prointo_contra', 'var')
        mTFR_tms_prointo_contra = TFR_tms_prointoVF_contra;
    else
        mTFR_tms_prointo_contra = subject_level_grouping(mTFR_tms_prointo_contra, TFR_tms_prointoVF_contra);
    end

    if ~exist('mTFR_notms_prointo', 'var')
        mTFR_notms_prointo = TFR_notms_prointoVF;
    else
        mTFR_notms_prointo = subject_level_grouping(mTFR_notms_prointo, TFR_notms_prointoVF);
    end

    if ~exist('mTFR_tms_prointo', 'var')
        mTFR_tms_prointo = TFR_tms_prointoVF;
    else
        mTFR_tms_prointo = subject_level_grouping(mTFR_tms_prointo, TFR_tms_prointoVF);
    end
    close all;
end
mTFR_notms_prointo_ipsi.powspctrm = mean(mTFR_notms_prointo_ipsi.powspctrm, 4, 'omitnan');
mTFR_notms_prointo_contra.powspctrm = mean(mTFR_notms_prointo_contra.powspctrm, 4, 'omitnan');
mTFR_tms_prointo_ipsi.powspctrm = mean(mTFR_tms_prointo_ipsi.powspctrm, 4, 'omitnan');
mTFR_tms_prointo_contra.powspctrm = mean(mTFR_tms_prointo_contra.powspctrm, 4, 'omitnan');
mTFR_notms_prointo.powspctrm = mean(mTFR_notms_prointo.powspctrm, 4, 'omitnan');
mTFR_tms_prointo.powspctrm = mean(mTFR_tms_prointo.powspctrm, 4, 'omitnan');

figname.master_compare_TFR = [p.figure '/indiv_TFR/compar_TFR_prointoVF_allsubs.png'];
figname.master_compare_topo = [p.figure '/indiv_topo/compar_topo_prointoVF_allsubs.png'];

if ~exist(figname.master_compare_TFR, 'file')
    compare_conds(mTFR_notms_prointo_ipsi, mTFR_notms_prointo_contra, ...
        mTFR_tms_prointo_ipsi, mTFR_tms_prointo_contra)
    saveas(gcf, figname.master_compare_TFR, 'png')
end
if ~exist(figname.master_compare_topo, 'file')
    create_topo(mTFR_notms_prointo, mTFR_tms_prointo)
    saveas(gcf, figname.master_compare_topo, 'png')
end
end

