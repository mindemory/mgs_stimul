function A04_BatchTFRAnalysis()
clearvars; close all; clc;
warning('off', 'all');

subs                                        = [1 3 5 6 7 8 11 12 13 14 15 16 17 18 21 22 23 25 27];
goodsubs                                    = [1 3 5 6 14 15 16 17 22 25];
[~, sidx]                                   = ismember(goodsubs, subs);
days                                        = [1 2 3];
t_stamp                                     = [0.5 2 3 4.5];
f_stamp                                     = [7 20];
conds                                       = ["NT", "T"];
t_types                                     = ["Pin", "Pout", "Ain", "Aout"];
t_types_in                                  = ["Pin", "Ain"];
locs                                        = ["ipsi", "contra"];
fName.mTFR                                  = ['/datc/MD_TMS_EEG/EEGfiles/masterTFR.mat'];
if ~exist(fName.mTFR, 'file')
    for subjID                              = subs
        disp(['Running subj = ' num2str(subjID, '%02d')])
        for day = days
            p.subjID                        = num2str(subjID,'%02d');
            p.day                           = day;
            [p, taskMap]                    = initialization(p, 'eeg', 0);
            p.figure                        = [p.datc '/Figures/eeg_analysis'];
            meta_data                       = readtable([p.analysis '/EEG_TMS_meta - Summary.csv']);
            HemiStimulated                  = table2cell(meta_data(:, ["HemisphereStimulated"]));
            this_hemi                       = HemiStimulated{subjID};
            NoTMSDays                       = table2array(meta_data(:, ["NoTMSDay"]));
    
            % File names
            fName.folder                    = [p.saveEEG '/sub' p.subjID '/day' num2str(p.day,'%02d')];
            fName.general                   = [fName.folder '/sub' p.subjID '_day' num2str(p.day,'%02d')];
            fName.concat                    = [fName.general '.vhdr'];
            fName.load                      = [fName.general '_raweeg.mat'];
            fName.ica                       = [fName.general '_ica.mat'];
            fName.bandpass                  = [fName.general '_bandpass.mat'];
            fName.bandpass_TMS              = [fName.general '_bandpass_TMS.mat'];
            fName.erp                       = [fName.general '_erp.mat'];
            fName.tms_erp                   = [fName.general '_tms_erp.mat'];
            fName.TFR                       = [fName.general '_TFR.mat'];
            fName.TMS_TFR                   = [fName.general '_TMS_TFR.mat'];
    
            [~, flg_chans]                  = flagged_trls_chans(subjID, day);
            %load(fName.TFR, 'POW');
            if p.day == NoTMSDays(subjID)
                load(fName.TFR, 'POW')
            else
                load(fName.TMS_TFR, 'TMSPOW')
                POW                         = TMSPOW;
                clearvars TMSPOW;
            end
    
            tidx_before                     = find((POW.prointoVF.time > t_stamp(1)) ...
                & (POW.prointoVF.time < t_stamp(2)));
            tidx_after                      = find((POW.prointoVF.time > t_stamp(3)) ...
                & (POW.prointoVF.time < t_stamp(4)));
            tidx                            = [tidx_before tidx_after];
            fidx                            = find((POW.prointoVF.freq > f_stamp(1)) ...
                & (POW.prointoVF.freq < f_stamp(2)));
    
            % Combine TFRs for this subject over all days based on trial and
            % session type
            if p.day == NoTMSDays(subjID)
                disp(['Combining TFRs No TMS, day = ' num2str(p.day)])
                [TFR.NT.Pin.ipsi, TFR.NT.Pin.contra] ...
                    = combineTFR_notms(POW, this_hemi, 'prointoVF', 'prooutVF');
                TFR.NT.Pin.all              = alignelecs(POW.prointoVF, this_hemi);
                TFR.NT.Pout.all             = alignelecs(POW.prooutVF, this_hemi);
                [TFR.NT.Ain.ipsi, TFR.NT.Ain.contra] ...
                    = combineTFR_notms(POW, this_hemi, 'antiintoVF', 'antioutVF');
                TFR.NT.Ain.all              = alignelecs(POW.antiintoVF, this_hemi);
                TFR.NT.Aout.all             = alignelecs(POW.antioutVF, this_hemi);
            else
                disp(['Combining TFRs TMS, day = ' num2str(p.day)])
                if ~exist('TFR', 'var') || ~isfield(TFR, 'T')
                    TFR.T.Pin.ipsi          = combineTFRs(POW.prointoVF, this_hemi, 1);
                    TFR.T.Pin.contra        = combineTFRs(POW.prointoVF, this_hemi, 0);
                    TFR.T.Pin.all           = alignelecs(POW.prointoVF, this_hemi);
                    TFR.T.Pout.ipsi         = combineTFRs(POW.prooutVF, this_hemi, 1);
                    TFR.T.Pout.contra       = combineTFRs(POW.prooutVF, this_hemi, 0);
                    TFR.T.Pout.all          = alignelecs(POW.prooutVF, this_hemi);
    
                    TFR.T.Ain.ipsi          = combineTFRs(POW.antiintoVF, this_hemi, 1);
                    TFR.T.Ain.contra        = combineTFRs(POW.antiintoVF, this_hemi, 0);
                    TFR.T.Ain.all           = alignelecs(POW.antiintoVF, this_hemi);
                    TFR.T.Aout.ipsi         = combineTFRs(POW.antioutVF, this_hemi, 1);
                    TFR.T.Aout.contra       = combineTFRs(POW.antioutVF, this_hemi, 0);
                    TFR.T.Aout.all          = alignelecs(POW.antioutVF, this_hemi);
                else
                    TFR.T.Pin.ipsi          = combineTFRs(POW.prointoVF, this_hemi, 1, TFR.T.Pin.ipsi);
                    TFR.T.Pin.contra        = combineTFRs(POW.prointoVF, this_hemi, 0, TFR.T.Pin.contra);
                    TFR.T.Pin.all           = alignelecs(POW.prointoVF, this_hemi, TFR.T.Pin.all);
                    TFR.T.Pout.ipsi         = combineTFRs(POW.prooutVF, this_hemi, 1, TFR.T.Pout.ipsi);
                    TFR.T.Pout.contra       = combineTFRs(POW.prooutVF, this_hemi, 0, TFR.T.Pout.contra);
                    TFR.T.Pout.all          = alignelecs(POW.prooutVF, this_hemi, TFR.T.Pout.all);
    
                    TFR.T.Ain.ipsi          = combineTFRs(POW.antiintoVF, this_hemi, 1, TFR.T.Ain.ipsi);
                    TFR.T.Ain.contra        = combineTFRs(POW.antiintoVF, this_hemi, 0, TFR.T.Ain.contra);
                    TFR.T.Ain.all           = alignelecs(POW.antiintoVF, this_hemi, TFR.T.Ain.all);
                    TFR.T.Aout.ipsi         = combineTFRs(POW.antioutVF, this_hemi, 1, TFR.T.Aout.ipsi);
                    TFR.T.Aout.contra       = combineTFRs(POW.antioutVF, this_hemi, 0, TFR.T.Aout.contra);
                    TFR.T.Aout.all          = alignelecs(POW.antioutVF, this_hemi, TFR.T.Aout.all);
                end
            end
        end
    
        figname.subjTFR_pro                 = [p.figure '/tfrplots/sub' p.subjID '_TFRpro.png'];
        figname.subjTFR_anti                = [p.figure '/tfrplots/sub' p.subjID '_TFRanti.png'];
        figname.subjTOPO_pro                = [p.figure '/topoplots/sub' p.subjID '_TOPOpro.png'];
        figname.subjTOPO_anti               = [p.figure '/topoplots/sub' p.subjID '_TOPOanti.png'];
        if ~exist(figname.subjTFR_pro, 'file')
            compare_conds(TFR, tidx, fidx, 'P')
            saveas(gcf, figname.subjTFR_pro, 'png')
            compare_conds(TFR, tidx, fidx, 'A')
            saveas(gcf, figname.subjTFR_anti, 'png')
        end
        if ~exist(figname.subjTOPO_pro, 'file')
            create_topo(TFR, tidx, fidx, 'P', 'alpha')
            saveas(gcf, figname.subjTOPO_pro, 'png')
            create_topo(TFR, tidx, fidx, 'A', 'alpha')
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
            mTFR.NT.Pout.all                = TFR.NT.Pout.all;
            mTFR.NT.Aout.all                = TFR.NT.Aout.all;
        else
            for tt                          = t_types_in
                mTFR.NT.(tt).ipsi           = subject_level_grouping(mTFR.NT.(tt).ipsi, TFR.NT.(tt).ipsi);
                mTFR.NT.(tt).contra         = subject_level_grouping(mTFR.NT.(tt).contra, TFR.NT.(tt).contra);
                mTFR.NT.(tt).all            = subject_level_grouping(mTFR.NT.(tt).all, TFR.NT.(tt).all, 1);
            end
            mTFR.NT.Pout.all                = subject_level_grouping(mTFR.NT.Pout.all, TFR.NT.Pout.all, 1);
            mTFR.NT.Aout.all                = subject_level_grouping(mTFR.NT.Aout.all, TFR.NT.Aout.all, 1);
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
    tidx_before                     = find((mTFR.NT.Pin.ipsi.time > t_stamp(1)) ...
        & (mTFR.NT.Pin.ipsi.time < t_stamp(2)));
    tidx_after                      = find((mTFR.NT.Pin.ipsi.time > t_stamp(3)) ...
        & (mTFR.NT.Pin.ipsi.time < t_stamp(4)));
    tidx                            = [tidx_before tidx_after];
    fidx                            = find((mTFR.NT.Pin.ipsi.freq > f_stamp(1)) ...
        & (mTFR.NT.Pin.ipsi.freq < f_stamp(2)));
    p.figure                                = '/datc/MD_TMS_EEG/Figures/eeg_analysis';
end


%% If running for good subjects only
% Average all mTFRs for plotting
for tt = t_types_in
    mTFR.NT.(tt).ipsi.powspctrm         = mean(mTFR.NT.(tt).ipsi.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mTFR.NT.(tt).contra.powspctrm       = mean(mTFR.NT.(tt).contra.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mTFR.NT.(tt).all.powspctrm          = mean(mTFR.NT.(tt).all.powspctrm(:, :, :, sidx), 4, 'omitnan');
end
mTFR.NT.Pout.all.powspctrm              = mean(mTFR.NT.Pout.all.powspctrm(:, :, :, sidx), 4, 'omitnan');
mTFR.NT.Aout.all.powspctrm              = mean(mTFR.NT.Aout.all.powspctrm(:, :, :, sidx), 4, 'omitnan');
for tt = t_types
    mTFR.T.(tt).ipsi.powspctrm          = mean(mTFR.T.(tt).ipsi.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mTFR.T.(tt).contra.powspctrm        = mean(mTFR.T.(tt).contra.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mTFR.T.(tt).all.powspctrm           = mean(mTFR.T.(tt).all.powspctrm(:, :, :, sidx), 4, 'omitnan');
end
    
% Figure names for master plots
figname.masterTFR_pro                       = [p.figure '/tfrplots/goodsubs_TFRpro.png'];
figname.masterTFR_anti                      = [p.figure '/tfrplots/goodsubs_TFRanti.png'];
figname.masterTOPO_pro                      = [p.figure '/topoplots/goodsubs_TOPOpro.png'];
figname.masterTOPO_anti                     = [p.figure '/topoplots/goodsubs_TOPOanti.png'];

% Master figure plots for TFR and TOPO
if ~exist(figname.masterTFR_pro, 'file')
    compare_conds(mTFR, tidx, fidx, 'P')
    saveas(gcf, figname.masterTFR_pro, 'png')
    compare_conds(mTFR, tidx, fidx, 'A')
    saveas(gcf, figname.masterTFR_anti, 'png')
end
if ~exist(figname.masterTOPO_pro, 'file')
    create_topo(mTFR, tidx, fidx, 'P', 'alpha')
    saveas(gcf, figname.masterTOPO_pro, 'png')
    create_topo(mTFR, tidx, fidx, 'A', 'alpha')
    saveas(gcf, figname.masterTOPO_anti, 'png')
end

%% If running for all subjects regardless
% Average all mTFRs for plotting
for tt = t_types_in
    mTFR.NT.(tt).ipsi.powspctrm         = mean(mTFR.NT.(tt).ipsi.powspctrm, 1, 'omitnan');
    mTFR.NT.(tt).contra.powspctrm       = mean(mTFR.NT.(tt).contra.powspctrm, 1, 'omitnan');
    mTFR.NT.(tt).all.powspctrm          = mean(mTFR.NT.(tt).all.powspctrm, 4, 'omitnan');
end
mTFR.NT.Pout.all.powspctrm              = mean(mTFR.NT.Pout.all.powspctrm, 4, 'omitnan');
mTFR.NT.Aout.all.powspctrm              = mean(mTFR.NT.Aout.all.powspctrm, 4, 'omitnan');
for tt = t_types
    mTFR.T.(tt).ipsi.powspctrm          = mean(mTFR.T.(tt).ipsi.powspctrm, 1, 'omitnan');
    mTFR.T.(tt).contra.powspctrm        = mean(mTFR.T.(tt).contra.powspctrm, 1, 'omitnan');
    mTFR.T.(tt).all.powspctrm           = mean(mTFR.T.(tt).all.powspctrm, 4, 'omitnan');
end
    

% Figure names for master plots
figname.masterTFR_pro                       = [p.figure '/tfrplots/allsubs_TFRpro.png'];
figname.masterTFR_anti                      = [p.figure '/tfrplots/allsubs_TFRanti.png'];
figname.masterTOPO_pro                      = [p.figure '/topoplots/allsubs_TOPOpro.png'];
figname.masterTOPO_anti                     = [p.figure '/topoplots/allsubs_TOPOanti.png'];

% Master figure plots for TFR and TOPO
if ~exist(figname.masterTFR_pro, 'file')
    compare_conds(mTFR, tidx, fidx, 'P')
    saveas(gcf, figname.masterTFR_pro, 'png')
    compare_conds(mTFR, tidx, fidx, 'A')
    saveas(gcf, figname.masterTFR_anti, 'png')
end
if ~exist(figname.masterTOPO_pro, 'file')
    create_topo(mTFR, tidx, fidx, 'P', 'alpha')
    saveas(gcf, figname.masterTOPO_pro, 'png')
    create_topo(mTFR, tidx, fidx, 'A', 'alpha')
    saveas(gcf, figname.masterTOPO_anti, 'png')
end


%% If running for good subjects (temporarily made for SfN (maybe?)
% Average all mTFRs for plotting
for tt = t_types_in
    mTFR.NT.(tt).ipsi.powspctrm         = mean(mTFR.NT.(tt).ipsi.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mTFR.NT.(tt).contra.powspctrm       = mean(mTFR.NT.(tt).contra.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mTFR.NT.(tt).all.powspctrm          = mean(mTFR.NT.(tt).all.powspctrm(:, :, :, sidx), 4, 'omitnan');
end
mTFR.NT.Pout.all.powspctrm              = mean(mTFR.NT.Pout.all.powspctrm(:, :, :, sidx), 4, 'omitnan');
mTFR.NT.Aout.all.powspctrm              = mean(mTFR.NT.Aout.all.powspctrm(:, :, :, sidx), 4, 'omitnan');
for tt = t_types
    mTFR.T.(tt).ipsi.powspctrm          = mean(mTFR.T.(tt).ipsi.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mTFR.T.(tt).contra.powspctrm        = mean(mTFR.T.(tt).contra.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mTFR.T.(tt).all.powspctrm           = mean(mTFR.T.(tt).all.powspctrm(:, :, :, sidx), 4, 'omitnan');
end
    
% Figure names for master plots
figname.masterTFR_pro                       = [p.figure '/tfrplots/goodsubs_TFRpro.png'];
figname.masterTFR_anti                      = [p.figure '/tfrplots/goodsubs_TFRanti.png'];
figname.masterTOPO_pro                      = [p.figure '/topoplots/goodsubs_TOPOpro.png'];
figname.masterTOPO_anti                     = [p.figure '/topoplots/goodsubs_TOPOanti.png'];

% Master figure plots for TFR and TOPO
if ~exist(figname.masterTFR_pro, 'file')
    compare_conds(mTFR, tidx, fidx, 'P')
    saveas(gcf, figname.masterTFR_pro, 'png')
    compare_conds(mTFR, tidx, fidx, 'A')
    saveas(gcf, figname.masterTFR_anti, 'png')
end
%if ~exist(figname.masterTOPO_pro, 'file')
    createtopo_SfN(mTFR, tidx, fidx, 'P', 'alpha')
    %saveas(gcf, figname.masterTOPO_pro, 'png')
    createtopo_SfN(mTFR, tidx, fidx, 'A', 'alpha')
    %saveas(gcf, figname.masterTOPO_anti, 'png')
%end

%% If running for all subjects regardless (temporarily made for SfN (maybe?)
% Average all mTFRs for plotting
for tt = t_types_in
    mTFR.NT.(tt).ipsi.powspctrm         = mean(mTFR.NT.(tt).ipsi.powspctrm, 1, 'omitnan');
    mTFR.NT.(tt).contra.powspctrm       = mean(mTFR.NT.(tt).contra.powspctrm, 1, 'omitnan');
    mTFR.NT.(tt).all.powspctrm          = mean(mTFR.NT.(tt).all.powspctrm, 4, 'omitnan');
end
mTFR.NT.Pout.all.powspctrm              = mean(mTFR.NT.Pout.all.powspctrm, 4, 'omitnan');
mTFR.NT.Aout.all.powspctrm              = mean(mTFR.NT.Aout.all.powspctrm, 4, 'omitnan');
for tt = t_types
    mTFR.T.(tt).ipsi.powspctrm          = mean(mTFR.T.(tt).ipsi.powspctrm, 1, 'omitnan');
    mTFR.T.(tt).contra.powspctrm        = mean(mTFR.T.(tt).contra.powspctrm, 1, 'omitnan');
    mTFR.T.(tt).all.powspctrm           = mean(mTFR.T.(tt).all.powspctrm, 4, 'omitnan');
end
    

% Figure names for master plots
figname.masterTFR_pro                       = [p.figure '/tfrplots/allsubs_TFRpro.png'];
figname.masterTFR_anti                      = [p.figure '/tfrplots/allsubs_TFRanti.png'];
figname.masterTOPO_pro                      = [p.figure '/topoplots/allsubs_TOPOpro.png'];
figname.masterTOPO_anti                     = [p.figure '/topoplots/allsubs_TOPOanti.png'];

% Master figure plots for TFR and TOPO
if ~exist(figname.masterTFR_pro, 'file')
    compare_conds(mTFR, tidx, fidx, 'P')
    saveas(gcf, figname.masterTFR_pro, 'png')
    compare_conds(mTFR, tidx, fidx, 'A')
    saveas(gcf, figname.masterTFR_anti, 'png')
end
%if ~exist(figname.masterTOPO_pro, 'file')
    createtopo_SfN(mTFR, tidx, fidx, 'P', 'alpha')
    %saveas(gcf, figname.masterTOPO_pro, 'png')
    createtopo_SfN(mTFR, tidx, fidx, 'A', 'alpha')
    %saveas(gcf, figname.masterTOPO_anti, 'png')
%end
end