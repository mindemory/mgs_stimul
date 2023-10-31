function A04_BatchITCAnalysis()
clearvars; close all; clc;
warning('off', 'all');

subs                                        = [1 3 5 6 7 8 11 12 13 14 15 16 17 18 21 22 23 25 27];
%goodsubs                                    = [1 3 5 6 14 15 16 17 22 25];
goodsubs                                   
[~, sidx]                                   = ismember(goodsubs, subs);
days                                        = [1 2 3];
t_stamp                                     = [0.5 2 3 4.5];
f_stamp                                     = [7 20];
conds                                       = ["NT", "T"];
t_types                                     = ["Pin", "Pout", "Ain", "Aout"];
t_types_in                                  = ["Pin", "Ain"];
locs                                        = ["ipsi", "contra"];
fName.mITC                                  = ['/datc/MD_TMS_EEG/EEGfiles/masterITC.mat'];
if ~exist(fName.mITC, 'file')
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
            fName.ITC                       = [fName.general '_TFR.mat'];
            fName.TMS_ITC                   = [fName.general '_TMS_TFR.mat'];
    
            [~, flg_chans]                  = flagged_trls_chans(subjID, day);
            %load(fName.ITC, 'POW');
            if p.day == NoTMSDays(subjID)
                load(fName.ITC, 'ITC')
            else
                load(fName.TMS_ITC, 'TMSITC')
                ITC                         = TMSITC;
                clearvars TMSITC;
            end
    
            tidx_before                     = find((ITC.prointoVF.time > t_stamp(1)) ...
                & (ITC.prointoVF.time < t_stamp(2)));
            tidx_after                      = find((ITC.prointoVF.time > t_stamp(3)) ...
                & (ITC.prointoVF.time < t_stamp(4)));
            tidx                            = [tidx_before tidx_after];
            fidx                            = find((ITC.prointoVF.freq > f_stamp(1)) ...
                & (ITC.prointoVF.freq < f_stamp(2)));
    
            % Combine ITCs for this subject over all days based on trial and
            % session type
            if p.day == NoTMSDays(subjID)
                disp(['Combining ITCs No TMS, day = ' num2str(p.day)])
                [stITC.NT.Pin.ipsi, stITC.NT.Pin.contra] ...
                    = combineITC_notms(ITC, this_hemi, 'prointoVF', 'prooutVF');
                stITC.NT.Pin.all              = alignelecsITC(ITC.prointoVF, this_hemi);
                stITC.NT.Pout.all             = alignelecsITC(ITC.prooutVF, this_hemi);
                [stITC.NT.Ain.ipsi, stITC.NT.Ain.contra] ...
                    = combineITC_notms(ITC, this_hemi, 'antiintoVF', 'antioutVF');
                stITC.NT.Ain.all              = alignelecsITC(ITC.antiintoVF, this_hemi);
                stITC.NT.Aout.all             = alignelecsITC(ITC.antioutVF, this_hemi);
            else
                disp(['Combining ITCs TMS, day = ' num2str(p.day)])
                if ~exist('ITC', 'var') || ~isfield(ITC, 'T')
                    stITC.T.Pin.ipsi          = combineITCs(ITC.prointoVF, this_hemi, 1);
                    stITC.T.Pin.contra        = combineITCs(ITC.prointoVF, this_hemi, 0);
                    stITC.T.Pin.all           = alignelecsITC(ITC.prointoVF, this_hemi);
                    stITC.T.Pout.ipsi         = combineITCs(ITC.prooutVF, this_hemi, 1);
                    stITC.T.Pout.contra       = combineITCs(ITC.prooutVF, this_hemi, 0);
                    stITC.T.Pout.all          = alignelecsITC(ITC.prooutVF, this_hemi);
    
                    stITC.T.Ain.ipsi          = combineITCs(ITC.antiintoVF, this_hemi, 1);
                    stITC.T.Ain.contra        = combineITCs(ITC.antiintoVF, this_hemi, 0);
                    stITC.T.Ain.all           = alignelecsITC(ITC.antiintoVF, this_hemi);
                    stITC.T.Aout.ipsi         = combineITCs(ITC.antioutVF, this_hemi, 1);
                    stITC.T.Aout.contra       = combineITCs(ITC.antioutVF, this_hemi, 0);
                    stITC.T.Aout.all          = alignelecsITC(ITC.antioutVF, this_hemi);
                else
                    stITC.T.Pin.ipsi          = combineITCs(ITC.prointoVF, this_hemi, 1, ITC.T.Pin.ipsi);
                    stITC.T.Pin.contra        = combineITCs(ITC.prointoVF, this_hemi, 0, ITC.T.Pin.contra);
                    stITC.T.Pin.all           = alignelecsITC(ITC.prointoVF, this_hemi, ITC.T.Pin.all);
                    stITC.T.Pout.ipsi         = combineITCs(ITC.prooutVF, this_hemi, 1, ITC.T.Pout.ipsi);
                    stITC.T.Pout.contra       = combineITCs(ITC.prooutVF, this_hemi, 0, ITC.T.Pout.contra);
                    stITC.T.Pout.all          = alignelecsITC(ITC.prooutVF, this_hemi, ITC.T.Pout.all);
    
                    stITC.T.Ain.ipsi          = combineITCs(ITC.antiintoVF, this_hemi, 1, ITC.T.Ain.ipsi);
                    stITC.T.Ain.contra        = combineITCs(ITC.antiintoVF, this_hemi, 0, ITC.T.Ain.contra);
                    stITC.T.Ain.all           = alignelecsITC(ITC.antiintoVF, this_hemi, ITC.T.Ain.all);
                    stITC.T.Aout.ipsi         = combineITCs(ITC.antioutVF, this_hemi, 1, ITC.T.Aout.ipsi);
                    stITC.T.Aout.contra       = combineITCs(ITC.antioutVF, this_hemi, 0, ITC.T.Aout.contra);
                    stITC.T.Aout.all          = alignelecsITC(ITC.antioutVF, this_hemi, ITC.T.Aout.all);
                end
            end
        end
    
        figname.subjITC_pro                 = [p.figure '/ITCplots/sub' p.subjID '_ITCpro.png'];
        figname.subjITC_anti                = [p.figure '/ITCplots/sub' p.subjID '_ITCanti.png'];
        figname.subjTOPO_pro                = [p.figure '/ITCtopoplots/sub' p.subjID '_TOPOpro.png'];
        figname.subjTOPO_anti               = [p.figure '/ITCtopoplots/sub' p.subjID '_TOPOanti.png'];
        if ~exist(figname.subjITC_pro, 'file')
            compare_condsITC(stITC, tidx, fidx, 'P')
            saveas(gcf, figname.subjITC_pro, 'png')
            compare_condsITC(stITC, tidx, fidx, 'A')
            saveas(gcf, figname.subjITC_anti, 'png')
        end
        if ~exist(figname.subjTOPO_pro, 'file')
            create_topoITC(stITC, tidx, fidx, 'P', 'alpha')
            saveas(gcf, figname.subjTOPO_pro, 'png')
            create_topoITC(stITC, tidx, fidx, 'A', 'alpha')
            saveas(gcf, figname.subjTOPO_anti, 'png')
        end
    
        % Store for combined analysis
        if ~exist('mITC', 'var')
            mITC = struct();
        end
        if ~isfield(mITC, 'NT')
            for tt                          = t_types_in
                mITC.NT.(tt).ipsi           = stITC.NT.(tt).ipsi;
                mITC.NT.(tt).contra         = stITC.NT.(tt).contra;
                mITC.NT.(tt).all            = stITC.NT.(tt).all;
            end
            mITC.NT.Pout.all                = stITC.NT.Pout.all;
            mITC.NT.Aout.all                = stITC.NT.Aout.all;
        else
            for tt                          = t_types_in
                mITC.NT.(tt).ipsi           = subject_level_groupingITC(mITC.NT.(tt).ipsi, stITC.NT.(tt).ipsi);
                mITC.NT.(tt).contra         = subject_level_groupingITC(mITC.NT.(tt).contra, stITC.NT.(tt).contra);
                mITC.NT.(tt).all            = subject_level_groupingITC(mITC.NT.(tt).all, stITC.NT.(tt).all, 1);
            end
            mITC.NT.Pout.all                = subject_level_groupingITC(mITC.NT.Pout.all, stITC.NT.Pout.all, 1);
            mITC.NT.Aout.all                = subject_level_groupingITC(mITC.NT.Aout.all, stITC.NT.Aout.all, 1);
        end
    
        if ~isfield(mITC, 'T')
            for tt = t_types
                mITC.T.(tt).ipsi            = stITC.T.(tt).ipsi;
                mITC.T.(tt).contra          = stITC.T.(tt).contra;
                mITC.T.(tt).all             = stITC.T.(tt).all;
            end
        else
            for tt = t_types
                mITC.T.(tt).ipsi            = subject_level_groupingITC(mITC.T.(tt).ipsi, stITC.T.(tt).ipsi);
                mITC.T.(tt).contra          = subject_level_groupingITC(mITC.T.(tt).contra, stITC.T.(tt).contra);
                mITC.T.(tt).all             = subject_level_groupingITC(mITC.T.(tt).all, stITC.T.(tt).all, 1);
            end
        end
    
        close all; clearvars ITC;
    end
    save(fName.mITC, 'mITC', '-v7.3')
else
    disp('Loading existing master ITC file')
    load(fName.mITC)
    tidx_before                     = find((mITC.NT.Pin.ipsi.time > t_stamp(1)) ...
        & (mITC.NT.Pin.ipsi.time < t_stamp(2)));
    tidx_after                      = find((mITC.NT.Pin.ipsi.time > t_stamp(3)) ...
        & (mITC.NT.Pin.ipsi.time < t_stamp(4)));
    tidx                            = [tidx_before tidx_after];
    fidx                            = find((mITC.NT.Pin.ipsi.freq > f_stamp(1)) ...
        & (mITC.NT.Pin.ipsi.freq < f_stamp(2)));
    p.figure                                = '/datc/MD_TMS_EEG/Figures/eeg_analysis';
end


%% If running for good subjects only
% Average all mITCs for plotting
for tt = t_types_in
    mITC.NT.(tt).ipsi.powspctrm         = mean(mITC.NT.(tt).ipsi.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mITC.NT.(tt).contra.powspctrm       = mean(mITC.NT.(tt).contra.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mITC.NT.(tt).all.powspctrm          = mean(mITC.NT.(tt).all.powspctrm(:, :, :, sidx), 4, 'omitnan');
end
mITC.NT.Pout.all.powspctrm              = mean(mITC.NT.Pout.all.powspctrm(:, :, :, sidx), 4, 'omitnan');
mITC.NT.Aout.all.powspctrm              = mean(mITC.NT.Aout.all.powspctrm(:, :, :, sidx), 4, 'omitnan');
for tt = t_types
    mITC.T.(tt).ipsi.powspctrm          = mean(mITC.T.(tt).ipsi.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mITC.T.(tt).contra.powspctrm        = mean(mITC.T.(tt).contra.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mITC.T.(tt).all.powspctrm           = mean(mITC.T.(tt).all.powspctrm(:, :, :, sidx), 4, 'omitnan');
end
    
% Figure names for master plots
figname.masterITC_pro                       = [p.figure '/ITCplots/goodsubs_ITCpro.png'];
figname.masterITC_anti                      = [p.figure '/ITCplots/goodsubs_ITCanti.png'];
figname.masterTOPO_pro                      = [p.figure '/topoplots/goodsubs_ITCTOPOpro.png'];
figname.masterTOPO_anti                     = [p.figure '/topoplots/goodsubs_TOPOanti.png'];

% Master figure plots for ITC and TOPO
if ~exist(figname.masterITC_pro, 'file')
    compare_condsITC(mITC, tidx, fidx, 'P')
    saveas(gcf, figname.masterITC_pro, 'png')
    compare_condsITC(mITC, tidx, fidx, 'A')
    saveas(gcf, figname.masterITC_anti, 'png')
end
if ~exist(figname.masterTOPO_pro, 'file')
    create_topoITC(mITC, tidx, fidx, 'P', 'alpha')
    saveas(gcf, figname.masterTOPO_pro, 'png')
    create_topoITC(mITC, tidx, fidx, 'A', 'alpha')
    saveas(gcf, figname.masterTOPO_anti, 'png')
end

%% If running for all subjects regardless
% Average all mITCs for plotting
for tt = t_types_in
    mITC.NT.(tt).ipsi.powspctrm         = mean(mITC.NT.(tt).ipsi.powspctrm, 1, 'omitnan');
    mITC.NT.(tt).contra.powspctrm       = mean(mITC.NT.(tt).contra.powspctrm, 1, 'omitnan');
    mITC.NT.(tt).all.powspctrm          = mean(mITC.NT.(tt).all.powspctrm, 4, 'omitnan');
end
mITC.NT.Pout.all.powspctrm              = mean(mITC.NT.Pout.all.powspctrm, 4, 'omitnan');
mITC.NT.Aout.all.powspctrm              = mean(mITC.NT.Aout.all.powspctrm, 4, 'omitnan');
for tt = t_types
    mITC.T.(tt).ipsi.powspctrm          = mean(mITC.T.(tt).ipsi.powspctrm, 1, 'omitnan');
    mITC.T.(tt).contra.powspctrm        = mean(mITC.T.(tt).contra.powspctrm, 1, 'omitnan');
    mITC.T.(tt).all.powspctrm           = mean(mITC.T.(tt).all.powspctrm, 4, 'omitnan');
end
    

% Figure names for master plots
figname.masterITC_pro                       = [p.figure '/ITCplots/allsubs_ITCpro.png'];
figname.masterITC_anti                      = [p.figure '/ITCplots/allsubs_ITCanti.png'];
figname.masterTOPO_pro                      = [p.figure '/topoplots/allsubs_TOPOpro.png'];
figname.masterTOPO_anti                     = [p.figure '/topoplots/allsubs_TOPOanti.png'];

% Master figure plots for ITC and TOPO
if ~exist(figname.masterITC_pro, 'file')
    compare_condsITC(mITC, tidx, fidx, 'P')
    saveas(gcf, figname.masterITC_pro, 'png')
    compare_condsITC(mITC, tidx, fidx, 'A')
    saveas(gcf, figname.masterITC_anti, 'png')
end
if ~exist(figname.masterTOPO_pro, 'file')
    create_topoITC(mITC, tidx, fidx, 'P', 'alpha')
    saveas(gcf, figname.masterTOPO_pro, 'png')
    create_topoITC(mITC, tidx, fidx, 'A', 'alpha')
    saveas(gcf, figname.masterTOPO_anti, 'png')
end


%% If running for good subjects (temporarily made for SfN (maybe?)
% Average all mITCs for plotting
for tt = t_types_in
    mITC.NT.(tt).ipsi.powspctrm         = mean(mITC.NT.(tt).ipsi.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mITC.NT.(tt).contra.powspctrm       = mean(mITC.NT.(tt).contra.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mITC.NT.(tt).all.powspctrm          = mean(mITC.NT.(tt).all.powspctrm(:, :, :, sidx), 4, 'omitnan');
end
mITC.NT.Pout.all.powspctrm              = mean(mITC.NT.Pout.all.powspctrm(:, :, :, sidx), 4, 'omitnan');
mITC.NT.Aout.all.powspctrm              = mean(mITC.NT.Aout.all.powspctrm(:, :, :, sidx), 4, 'omitnan');
for tt = t_types
    mITC.T.(tt).ipsi.powspctrm          = mean(mITC.T.(tt).ipsi.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mITC.T.(tt).contra.powspctrm        = mean(mITC.T.(tt).contra.powspctrm(sidx, :, :, :), 1, 'omitnan');
    mITC.T.(tt).all.powspctrm           = mean(mITC.T.(tt).all.powspctrm(:, :, :, sidx), 4, 'omitnan');
end
    
% Figure names for master plots
figname.masterITC_pro                       = [p.figure '/ITCplots/goodsubs_ITCpro.png'];
figname.masterITC_anti                      = [p.figure '/ITCplots/goodsubs_ITCanti.png'];
figname.masterTOPO_pro                      = [p.figure '/topoplots/goodsubs_TOPOpro.png'];
figname.masterTOPO_anti                     = [p.figure '/topoplots/goodsubs_TOPOanti.png'];

% Master figure plots for ITC and TOPO
if ~exist(figname.masterITC_pro, 'file')
    compare_condsITC(mITC, tidx, fidx, 'P')
    saveas(gcf, figname.masterITC_pro, 'png')
    compare_condsITC(mITC, tidx, fidx, 'A')
    saveas(gcf, figname.masterITC_anti, 'png')
end
%if ~exist(figname.masterTOPO_pro, 'file')
    createtopo_SfN(mITC, tidx, fidx, 'P', 'alpha')
    %saveas(gcf, figname.masterTOPO_pro, 'png')
    createtopo_SfN(mITC, tidx, fidx, 'A', 'alpha')
    %saveas(gcf, figname.masterTOPO_anti, 'png')
%end

%% If running for all subjects regardless (temporarily made for SfN (maybe?)
% Average all mITCs for plotting
for tt = t_types_in
    mITC.NT.(tt).ipsi.powspctrm         = mean(mITC.NT.(tt).ipsi.powspctrm, 1, 'omitnan');
    mITC.NT.(tt).contra.powspctrm       = mean(mITC.NT.(tt).contra.powspctrm, 1, 'omitnan');
    mITC.NT.(tt).all.powspctrm          = mean(mITC.NT.(tt).all.powspctrm, 4, 'omitnan');
end
mITC.NT.Pout.all.powspctrm              = mean(mITC.NT.Pout.all.powspctrm, 4, 'omitnan');
mITC.NT.Aout.all.powspctrm              = mean(mITC.NT.Aout.all.powspctrm, 4, 'omitnan');
for tt = t_types
    mITC.T.(tt).ipsi.powspctrm          = mean(mITC.T.(tt).ipsi.powspctrm, 1, 'omitnan');
    mITC.T.(tt).contra.powspctrm        = mean(mITC.T.(tt).contra.powspctrm, 1, 'omitnan');
    mITC.T.(tt).all.powspctrm           = mean(mITC.T.(tt).all.powspctrm, 4, 'omitnan');
end
    

% Figure names for master plots
figname.masterITC_pro                       = [p.figure '/ITCplots/allsubs_ITCpro.png'];
figname.masterITC_anti                      = [p.figure '/ITCplots/allsubs_ITCanti.png'];
figname.masterTOPO_pro                      = [p.figure '/topoplots/allsubs_TOPOpro.png'];
figname.masterTOPO_anti                     = [p.figure '/topoplots/allsubs_TOPOanti.png'];

% Master figure plots for ITC and TOPO
if ~exist(figname.masterITC_pro, 'file')
    compare_condsITC(mITC, tidx, fidx, 'P')
    saveas(gcf, figname.masterITC_pro, 'png')
    compare_condsITC(mITC, tidx, fidx, 'A')
    saveas(gcf, figname.masterITC_anti, 'png')
end
%if ~exist(figname.masterTOPO_pro, 'file')
    createtopo_SfN(mITC, tidx, fidx, 'P', 'alpha')
    %saveas(gcf, figname.masterTOPO_pro, 'png')
    createtopo_SfN(mITC, tidx, fidx, 'A', 'alpha')
    %saveas(gcf, figname.masterTOPO_anti, 'png')
%end
end