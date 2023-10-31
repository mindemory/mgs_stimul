function A04_BatchAnalysisEEG_stat()
clearvars; close all; clc;
warning('off', 'all');

subs =  [1  5 6 7 22];% 13 14 15 16 17 18 22 23 24];
%subs =  [1  5 6 7 16 17 18 22 24];
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
        fName.freqmat_prointoVF_normalized = [fName.general '_freqmat_prointoVF_normalized.mat'];

        fName.trlfreqmat_prointoVF = [fName.general '_trlfreqmat_prointoVF.mat'];
        fName.trlfreqmat_prooutVF = [fName.general '_trlfreqmat_prooutVF.mat'];
        fName.trlfreqmat_antiintoVF = [fName.general '_trlfreqmat_antiintoVF.mat'];
        fName.trlfreqmat_antioutVF = [fName.general '_trlfreqmat_antioutVF.mat'];
        fName.trlfreqmat_prointoVF_normalized = [fName.general '_trlfreqmat_prointoVF_normalized.mat'];

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
            fName.tms_trlfreqmat_prointoVF = [fName.general '_tms_trlfreqmat_prointoVF.mat'];
            fName.tms_trlfreqmat_prooutVF = [fName.general '_tms_trlfreqmat_prooutVF.mat'];
            fName.tms_trlfreqmat_antiintoVF = [fName.general '_tms_trlfreqmat_antiintoVF.mat'];
            fName.tms_trlfreqmat_antioutVF = [fName.general '_tms_trlfreqmat_antioutVF.mat'];
            fName.tms_trlfreqmat_prointoVF_normalized = [fName.general '_tms_trlfreqmat_prointoVF_normalized.mat'];
        end
        [~, flg_chans] = flagged_trls_chans(subjID, day);
        load(fName.trlfreqmat_prointoVF);
        load(fName.trlfreqmat_prooutVF);

        [statmat] = compute_stats(trlfreqmat_prointoVF, trlfreqmat_prooutVF);

        

        if p.day == NoTMSDays(subjID)
%             tic
%             %TFR_notms_prointoVF_ipsi = combineTFRs(freqmat_prointoVF, this_hemisphere, 1);
%             toc
            %TFR_notms_prointoVF_contra = combineTFRs(freqmat_prointoVF, this_hemisphere, 0);
            statmat_notms = alignelecs_stat(statmat, this_hemisphere);
        else
            if ~exist('TFR_tms_prointoVF_ipsi', 'var')
                %TFR_tms_prointoVF_ipsi = combineTFRs(freqmat_prointoVF, this_hemisphere, 1);
                %TFR_tms_prointoVF_contra = combineTFRs(freqmat_prointoVF, this_hemisphere, 0);
                statmat_tms = alignelecs(statmat, this_hemisphere);
            else
                %TFR_tms_prointoVF_ipsi = combineTFRs(freqmat_prointoVF, this_hemisphere, 1, TFR_tms_prointoVF_ipsi);
                %TFR_tms_prointoVF_contra = combineTFRs(freqmat_prointoVF, this_hemisphere, 0, TFR_tms_prointoVF_contra);
                statmat_tms = alignelecs(statmat, this_hemisphere, statmat_tms);
            end
        end
    end
        
    %figname.compare_TFR = [p.figure '/indiv_TFR/compar_TFR_prointoVF_sub' num2str(p.subjID, '%02d') '.png'];
    figname.stat_topo = [p.figure '/stat_topo/stat_topo_RVL_sub' num2str(p.subjID, '%02d') '.png'];
%     if ~exist(figname.compare_TFR, 'file')
%         compare_conds(TFR_notms_prointoVF_ipsi, TFR_notms_prointoVF_contra, ...
%             TFR_tms_prointoVF_ipsi, TFR_tms_prointoVF_contra)
%         saveas(gcf, figname.compare_TFR, 'png')
%     end
    if ~exist(figname.stat_topo, 'file')
        create_topo_stat(statmat_notms, statmat_tms)
        saveas(gcf, figname.stat_topo, 'png')
    end
    
    % Store for combined analysis
    if ~exist('mstatmat_notms', 'var')
        mstatmat_notms = statmat_notms;
    else
        mstatmat_notms = subject_level_grouping_stat(mstatmat_notms, statmat_notms);
    end

    if ~exist('mTFR_tms_prointo', 'var')
        mstatmat_tms = statmat_tms;
    else
        mstatmat_tms = subject_level_grouping_stat(mstatmat_tms, statmat_tms);
    end
    close all; clearvars statmat_notms statmat_tms
end
mstatmat_notms.mask = double(any(mstatmat_notms.mask, 4));
mstatmat_notms.prob = mean(mstatmat_notms.prob, 4);
mstatmat_notms.stat = mean(mstatmat_notms.stat, 4);

mstatmat_tms.mask = double(any(mstatmat_tms.mask, 4));
mstatmat_tms.prob = mean(mstatmat_tms.prob, 4);
mstatmat_tms.stat = mean(mstatmat_tms.stat, 4);


figname.master_stat_topo = [p.figure '/stat_topo/stat_topo_RVL_allsubs.png'];
if ~exist(figname.master_stat_topo, 'file')
    create_topo_stat(mstatmat_notms, mstatmat_tms)
    saveas(gcf, figname.master_stat_topo, 'png')
end
end

% cfg = [];
% cfg.channel = freqmat_prointoVF.label;
% cfg.latency     = [0.5 4.5]; 
% cfg.frequency   = [8 12];
% % cfg.avgoverchan = 'yes';
% cfg.avgovertime = 'yes';
% cfg.avgoverfreq = 'yes';
% cfg.parameter   = 'powspctrm';
% 
% cfg.method  = 'stats';
% cfg.correctm = 'no';
% cfg.statistic = 'ttest2';
% 
% inds_LVF = freqmat_prointoVF.trialinfo;
% inds_RVF = freqmat_prooutVF.trialinfo;
% design = ones(1,length(inds_LVF)+length(inds_RVF));
% % design(inds_LVF) = 1;
% % design(inds_RVF) = 2;
% design(length(inds_LVF)+1:length(inds_LVF)+length(inds_RVF)) = 2;
% 
% cfg.design = design;
% cfg_orig = cfg;
% stats_allChannels = ft_freqstatistics(cfg, freqmat_prointoVF,freqmat_prooutVF);
% 
% cfg = [];
% cfg.xlim = [0.5 4.5];
% cfg.ylim = [8 12];
% cfg.layout = 'acticap-64_md.mat';
% cfg.style = 'straight';
% cfg.parameter = 'powspctrm';
% ft_topoplotTFR(cfg, freqmat_prointoVF)
