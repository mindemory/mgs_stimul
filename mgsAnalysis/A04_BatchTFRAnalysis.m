function A04_BatchTFRAnalysis(tfr_type)
clearvars -except tfr_type; close all; clc;
warning('off', 'all');

subs                                        = [1 3 5 6 7 10 12 14 15 16 17 22 23 24 25 26 27];

days                                        = [1 2 3];
t_stamp                                     = [0.5 2 3 4.5];
f_stamp                                     = [7 20];
conds                                       = ["NT", "T"];
t_types                                     = ["pin", "pout", "ain", "aout"];
t_types_in                                  = ["pin", "ain"];
locs                                        = ["ipsi", "contra"];
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);
if strcmp(hostname, 'zod')
    if strcmp(tfr_type, 'evoked')
        fName.mTFR                                  = '/datc/MD_TMS_EEG/EEGfiles/masterTFR_evoked.mat';
    elseif strcmp(tfr_type, 'induced')
        fName.mTFR                                  = '/datc/MD_TMS_EEG/EEGfiles/masterTFR_induced.mat';
    end
    fig_path                                    = '/datc/MD_TMS_EEG/Figures';
else
    if strcmp(tfr_type, 'evoked')
        fName.mTFR                                  = '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/MD_TMS_EEG/EEGfiles/masterTFR_evoked.mat';
    elseif strcmp(tfr_type, 'induced')
        fName.mTFR                                  = '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/MD_TMS_EEG/EEGfiles/masterTFR_induced.mat';
    end
    fig_path                                    = '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/MD_TMS_EEG/Figures';
end
if ~exist(fName.mTFR, 'file')
    for subjID                              = subs
        disp(['Running subj = ' num2str(subjID, '%02d')])
        for day = days
            p.subjID                        = num2str(subjID,'%02d');
            p.day                           = day;
            [p, taskMap]                    = initialization(p, 'eeg', 0);
            p.figure                        = [p.datc '/Figures/eeg_analysis'];
            meta_data                       = readtable([p.analysis '/EEG_TMS_meta_Summary.csv']);
            HemiStimulated                  = table2cell(meta_data(:, ["HemisphereStimulated"]));
            this_hemi                       = HemiStimulated{subjID};
            NoTMSDays                       = table2array(meta_data(:, ["NoTMSDay"]));
    
            % File names
            fName.folder                    = [p.saveEEG '/sub' p.subjID '/day' num2str(p.day,'%02d')];
            fName.general                   = [fName.folder '/sub' p.subjID '_day' num2str(p.day,'%02d')];
            fName.concat                    = [fName.general '.vhdr'];
            fName.flag_data                 = [fName.general '_flagdata.mat'];
            fName.load                      = [fName.general '_raweeg.mat'];
            fName.ica                       = [fName.general '_ica.mat'];
            fName.raw_cleaned               = [fName.general '_raw_cleaned.mat'];
            fName.trl_idx                   = [fName.general '_trl_idx.mat'];
            fName.epoc_all                  = [fName.general '_epoc_all.mat'];
            fName.epoc                      = [fName.general '_epoc.mat'];
            fName.erp                       = [fName.general '_erp.mat'];
            fName.TFR_evoked                = [fName.general '_TFR_evoked.mat'];
            fName.TFR_induced               = [fName.general '_TFR_induced.mat'];

    
            %[~, flg_chans]                  = flagged_trls_chans(subjID, day);
            if strcmp(tfr_type, 'induced')
                load(fName.TFR_induced, 'POW');
            elseif strcmp(tfr_type, 'evoked')
                load(fName.TFR_evoked, 'POW');
            end
    
            tidx_before                     = find((POW.pin.time > t_stamp(1)) ...
                & (POW.pin.time < t_stamp(2)));
            tidx_after                      = find((POW.pin.time > t_stamp(3)) ...
                & (POW.pin.time < t_stamp(4)));
            tidx                            = [tidx_before tidx_after];
            fidx                            = find((POW.pin.freq > f_stamp(1)) ...
                & (POW.pin.freq < f_stamp(2)));
    
            % Combine TFRs for this subject over all days based on trial and
            % session type
            if p.day == NoTMSDays(subjID)
                disp(['Combining TFRs No TMS, day = ' num2str(p.day)])
                [TFR.NT.pin.ipsi, TFR.NT.pin.contra] ...
                    = combineTFR_notms(POW, this_hemi, 'pin', 'pout');
                TFR.NT.pin.all              = alignelecs(POW.pin, this_hemi);
                TFR.NT.pout.all             = alignelecs(POW.pout, this_hemi);
                [TFR.NT.ain.ipsi, TFR.NT.ain.contra] ...
                    = combineTFR_notms(POW, this_hemi, 'ain', 'aout');
                TFR.NT.ain.all              = alignelecs(POW.ain, this_hemi);
                TFR.NT.aout.all             = alignelecs(POW.aout, this_hemi);
            else
                disp(['Combining TFRs TMS, day = ' num2str(p.day)])
                if ~exist('TFR', 'var') || ~isfield(TFR, 'T')
                    TFR.T.pin.ipsi          = combineTFRs(POW.pin, this_hemi, 1);
                    TFR.T.pin.contra        = combineTFRs(POW.pin, this_hemi, 0);
                    TFR.T.pin.all           = alignelecs(POW.pin, this_hemi);
                    TFR.T.pout.ipsi         = combineTFRs(POW.pout, this_hemi, 1);
                    TFR.T.pout.contra       = combineTFRs(POW.pout, this_hemi, 0);
                    TFR.T.pout.all          = alignelecs(POW.pout, this_hemi);
    
                    TFR.T.ain.ipsi          = combineTFRs(POW.ain, this_hemi, 1);
                    TFR.T.ain.contra        = combineTFRs(POW.ain, this_hemi, 0);
                    TFR.T.ain.all           = alignelecs(POW.ain, this_hemi);
                    TFR.T.aout.ipsi         = combineTFRs(POW.aout, this_hemi, 1);
                    TFR.T.aout.contra       = combineTFRs(POW.aout, this_hemi, 0);
                    TFR.T.aout.all          = alignelecs(POW.aout, this_hemi);
                else
                    TFR.T.pin.ipsi          = combineTFRs(POW.pin, this_hemi, 1, TFR.T.pin.ipsi);
                    TFR.T.pin.contra        = combineTFRs(POW.pin, this_hemi, 0, TFR.T.pin.contra);
                    TFR.T.pin.all           = alignelecs(POW.pin, this_hemi, TFR.T.pin.all);
                    TFR.T.pout.ipsi         = combineTFRs(POW.pout, this_hemi, 1, TFR.T.pout.ipsi);
                    TFR.T.pout.contra       = combineTFRs(POW.pout, this_hemi, 0, TFR.T.pout.contra);
                    TFR.T.pout.all          = alignelecs(POW.pout, this_hemi, TFR.T.pout.all);
    
                    TFR.T.ain.ipsi          = combineTFRs(POW.ain, this_hemi, 1, TFR.T.ain.ipsi);
                    TFR.T.ain.contra        = combineTFRs(POW.ain, this_hemi, 0, TFR.T.ain.contra);
                    TFR.T.ain.all           = alignelecs(POW.ain, this_hemi, TFR.T.ain.all);
                    TFR.T.aout.ipsi         = combineTFRs(POW.aout, this_hemi, 1, TFR.T.aout.ipsi);
                    TFR.T.aout.contra       = combineTFRs(POW.aout, this_hemi, 0, TFR.T.aout.contra);
                    TFR.T.aout.all          = alignelecs(POW.aout, this_hemi, TFR.T.aout.all);
                end
            end
        end
    
        figname.subjTFR_pro                 = [p.figure '/tfrplots/' tfr_type '/sub' p.subjID '_TFRpro.png'];
        figname.subjTFR_anti                = [p.figure '/tfrplots/' tfr_type '/sub' p.subjID '_TFRanti.png'];
        figname.subjTOPO_pro                = [p.figure '/topoplots/' tfr_type '/sub' p.subjID '_TOPOpro.png'];
        figname.subjTOPO_anti               = [p.figure '/topoplots/' tfr_type '/sub' p.subjID '_TOPOanti.png'];
        if ~exist(figname.subjTFR_pro, 'file')
            compare_conds(TFR, tidx, fidx, 'p')
            saveas(gcf, figname.subjTFR_pro, 'png')
            compare_conds(TFR, tidx, fidx, 'a')
            saveas(gcf, figname.subjTFR_anti, 'png')
        end
        if ~exist(figname.subjTOPO_pro, 'file')
            create_topo(TFR, tidx, fidx, 'p', 'alpha')
            saveas(gcf, figname.subjTOPO_pro, 'png')
            create_topo(TFR, tidx, fidx, 'a', 'alpha')
            saveas(gcf, figname.subjTOPO_anti, 'png')
        end
    
        % Store for combined analysis
        if ~exist('mTFR', 'var')
            mTFR = struct();
        end
        if ~isfield(mTFR, 'NT')
            for tt                          = t_types_in
                mTFR.NT.(tt).ipsi           = TFR.NT.(tt).ipsi;
                mTFR.NT.(tt).contra         = TFR.NT.(tt).contra;
                mTFR.NT.(tt).all            = TFR.NT.(tt).all;
            end
            mTFR.NT.pout.all                = TFR.NT.pout.all;
            mTFR.NT.aout.all                = TFR.NT.aout.all;
        else
            for tt                          = t_types_in
                mTFR.NT.(tt).ipsi           = subject_level_grouping(mTFR.NT.(tt).ipsi, TFR.NT.(tt).ipsi);
                mTFR.NT.(tt).contra         = subject_level_grouping(mTFR.NT.(tt).contra, TFR.NT.(tt).contra);
                mTFR.NT.(tt).all            = subject_level_grouping(mTFR.NT.(tt).all, TFR.NT.(tt).all, 1);
            end
            mTFR.NT.pout.all                = subject_level_grouping(mTFR.NT.pout.all, TFR.NT.pout.all, 1);
            mTFR.NT.aout.all                = subject_level_grouping(mTFR.NT.aout.all, TFR.NT.aout.all, 1);
        end
    
        if ~isfield(mTFR, 'T')
            for tt = t_types
                mTFR.T.(tt).ipsi            = TFR.T.(tt).ipsi;
                mTFR.T.(tt).contra          = TFR.T.(tt).contra;
                mTFR.T.(tt).all             = TFR.T.(tt).all;
            end
        else
            for tt = t_types
                mTFR.T.(tt).ipsi            = subject_level_grouping(mTFR.T.(tt).ipsi, TFR.T.(tt).ipsi);
                mTFR.T.(tt).contra          = subject_level_grouping(mTFR.T.(tt).contra, TFR.T.(tt).contra);
                mTFR.T.(tt).all             = subject_level_grouping(mTFR.T.(tt).all, TFR.T.(tt).all, 1);
            end
        end
    
        close all; clearvars TFR;
    end
    save(fName.mTFR, 'mTFR', '-v7.3')
else
    disp('Loading existing master TFR file')
    load(fName.mTFR)
    tidx_before                     = find((mTFR.NT.pin.ipsi.time > t_stamp(1)) ...
        & (mTFR.NT.pin.ipsi.time < t_stamp(2)));
    tidx_after                      = find((mTFR.NT.pin.ipsi.time > t_stamp(3)) ...
        & (mTFR.NT.pin.ipsi.time < t_stamp(4)));
    tidx                            = [tidx_before tidx_after];
    fidx                            = find((mTFR.NT.pin.ipsi.freq > f_stamp(1)) ...
        & (mTFR.NT.pin.ipsi.freq < f_stamp(2)));
    p.figure                                = fig_path;
end

%% If running for all subjects regardless
% Average all mTFRs for plotting
% for tt = t_types_in
%     mTFR.NT.(tt).ipsi.powspctrm         = mean(mTFR.NT.(tt).ipsi.powspctrm, 1, 'omitnan');
%     mTFR.NT.(tt).contra.powspctrm       = mean(mTFR.NT.(tt).contra.powspctrm, 1, 'omitnan');
%     mTFR.NT.(tt).all.powspctrm          = mean(mTFR.NT.(tt).all.powspctrm, 4, 'omitnan');
% end
% mTFR.NT.pout.all.powspctrm              = mean(mTFR.NT.pout.all.powspctrm, 4, 'omitnan');
% mTFR.NT.aout.all.powspctrm              = mean(mTFR.NT.aout.all.powspctrm, 4, 'omitnan');
% for tt = t_types
%     mTFR.T.(tt).ipsi.powspctrm          = mean(mTFR.T.(tt).ipsi.powspctrm, 1, 'omitnan');
%     mTFR.T.(tt).contra.powspctrm        = mean(mTFR.T.(tt).contra.powspctrm, 1, 'omitnan');
%     mTFR.T.(tt).all.powspctrm           = mean(mTFR.T.(tt).all.powspctrm, 4, 'omitnan');
% end
%     
% 
% % Figure names for master plots
% figname.masterTFR_pro                       = [p.figure '/tfrplots/' tfr_type '/allsubs_TFRpro.png'];
% figname.masterTFR_anti                      = [p.figure '/tfrplots/' tfr_type '/allsubs_TFRanti.png'];
% figname.masterTOPO_pro                      = [p.figure '/topoplots/' tfr_type '/allsubs_TOPOpro.png'];
% figname.masterTOPO_anti                     = [p.figure '/topoplots/' tfr_type '/allsubs_TOPOanti.png'];
% 
% % Master figure plots for TFR and TOPO
% if ~exist(figname.masterTFR_pro, 'file')
%     compare_conds(mTFR, tidx, fidx, 'p')
%     saveas(gcf, figname.masterTFR_pro, 'png')
%     compare_conds(mTFR, tidx, fidx, 'a')
%     saveas(gcf, figname.masterTFR_anti, 'png')
% end
% if ~exist(figname.masterTOPO_pro, 'file')
%     create_topo(mTFR, tidx, fidx, 'p', 'alpha')
%     saveas(gcf, figname.masterTOPO_pro, 'png')
%     create_topo(mTFR, tidx, fidx, 'a', 'alpha')
%     saveas(gcf, figname.masterTOPO_anti, 'png')
% end

%% If running for all subjects regardless (temporarily made for SfN (maybe?)
% for ss = 1:length(subs)
%     NTin_tfr                                         = mTFR.NT.pin.all;
%     NTout_tfr                                        = mTFR.NT.pout.all;
%     Tin_tfr                                          = mTFR.T.pin.all;
%     Tout_tfr                                         = mTFR.T.pout.all;
%     NTin_tfr.powspctrm                               = squeeze(NTin_tfr.powspctrm(:,:,:,ss));
%     NTout_tfr.powspctrm                              = squeeze(NTout_tfr.powspctrm(:,:,:,ss));
%     Tin_tfr.powspctrm                                = squeeze(Tin_tfr.powspctrm(:,:,:,ss));
%     Tout_tfr.powspctrm                               = squeeze(Tout_tfr.powspctrm(:,:,:,ss));
%     
%     cfg                                              = [];
%     cfg.operation                                    = '(10^(x1/10) - 10^(x2/10)) / (10^(x1/10) + 10^(x2/10))';
%     cfg.parameter                                    = 'powspctrm';
%     NTcontrast                                       = ft_math(cfg, NTin_tfr, NTout_tfr);
%     Tcontrast                                        = ft_math(cfg, Tin_tfr, Tout_tfr);
%     cfg                                              = [];
%     cfg.operation                                    = 'x1-x2';
%     cfg.parameter                                    = 'powspctrm';
%     diffcontrast                                     = ft_math(cfg, NTcontrast, Tcontrast);
%     % Fing electrodes that are statistically different from 0
%     tlateidx                                         = find(diffcontrast.time > 2.8 & diffcontrast.time < 3.2);
%     diff_powmat                                      = squeeze(mean(diffcontrast.powspctrm(:, fidx, tlateidx), [2, 3], 'omitnan'));
%     if ~exist('diffmaster', 'var')
%         diffmaster = diff_powmat;
%     else
%         diffmaster = cat(3, diffmaster, diff_powmat);
%     end
%     %diffmaster = [diffmaster; diff_powmat];
%     clearvars NTin_tfr NTout_tfr Tin_tfr Tout_tfr NTcontrast Tcontrast diffcontrast diff_powmat;
% end
% 
% 
% for ii = 1:length(mTFR.NT.Pin.all.label)
%     [h, p, ci, stats]                                = ttest(diffmaster(ii, 1, :), 0, 'alpha', 0.05);
%     if h == 1
%         disp([mTFR.NT.Pin.all.label{ii} ': ' num2str(p, '%.03f')])
%         %disp([mTFR.NT.Pin.all.label{ii} ': ' num2str(h)])
%         %disp(p, stats)
%     end
% end
% 
% %Average all mTFRs for plotting
% for tt = t_types_in
%     mTFR.NT.(tt).ipsi.powspctrm         = mean(mTFR.NT.(tt).ipsi.powspctrm, 1, 'omitnan');
%     mTFR.NT.(tt).contra.powspctrm       = mean(mTFR.NT.(tt).contra.powspctrm, 1, 'omitnan');
%     mTFR.NT.(tt).all.powspctrm          = mean(mTFR.NT.(tt).all.powspctrm, 4, 'omitnan');
% end
% mTFR.NT.Pout.all.powspctrm              = mean(mTFR.NT.Pout.all.powspctrm, 4, 'omitnan');
% mTFR.NT.Aout.all.powspctrm              = mean(mTFR.NT.Aout.all.powspctrm, 4, 'omitnan');
% for tt = t_types
%     mTFR.T.(tt).ipsi.powspctrm          = mean(mTFR.T.(tt).ipsi.powspctrm, 1, 'omitnan');
%     mTFR.T.(tt).contra.powspctrm        = mean(mTFR.T.(tt).contra.powspctrm, 1, 'omitnan');
%     mTFR.T.(tt).all.powspctrm           = mean(mTFR.T.(tt).all.powspctrm, 4, 'omitnan');
% end
%     
% 
% % Figure names for master plots
% figname.masterTFR_pro                       = [p.figure '/tfrplots/allsubs_TFRpro.png'];
% figname.masterTFR_anti                      = [p.figure '/tfrplots/allsubs_TFRanti.png'];
% figname.masterTOPO_pro                      = [p.figure '/topoplots/allsubs_TOPOpro.png'];
% figname.masterTOPO_anti                     = [p.figure '/topoplots/allsubs_TOPOanti.png'];
% 
% % Master figure plots for TFR and TOPO
% if ~exist(figname.masterTFR_pro, 'file')
%     compare_conds(mTFR, tidx, fidx, 'P')
%     saveas(gcf, figname.masterTFR_pro, 'png')
%     compare_conds(mTFR, tidx, fidx, 'A')
%     saveas(gcf, figname.masterTFR_anti, 'png')
% end
% %if ~exist(figname.masterTOPO_pro, 'file')
%     createtopo_SfN(mTFR, tidx, fidx, 'P', 'alpha')
%     %saveas(gcf, figname.masterTOPO_pro, 'png')
%     createtopo_SfN(mTFR, tidx, fidx, 'A', 'alpha')
%     %saveas(gcf, figname.masterTOPO_anti, 'png')
% %end
end