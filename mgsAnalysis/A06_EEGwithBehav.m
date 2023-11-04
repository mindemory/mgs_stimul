function A06_EEGwithBehav()
clearvars; close all; clc;
warning('off', 'all');

subs                                        = [1 3 5 6 7 8 11 12 13 14 15 16 17 18 22 23 24 25 26 27];
subs                                        = [1 3 5 6 8 12];
% goodsubs                                    = [1 3 5 6 14 15 16 17 22 25];
goodsubs                                    = [26];
%subs = [26];
[~, sidx]                                   = ismember(goodsubs, subs);
days                                        = [1 2 3];
t_stamp                                     = [-0.5 4.5];
xt                                          = [-0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5];
f_stamp                                     = [8 12];
ttypes                                      = ["Pin", "Pout", "Ain", "Aout"];
conds                                       = ["NT", "T"];
left_occ_elecs                              = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_occ_elecs                             = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};


fName.mTFR                                  = ['/datc/MD_TMS_EEG/EEGfiles/masterTFR.mat'];
for subjID                              = subs
    for day = days
        disp(['Running subj = ' num2str(subjID, '%02d') ', day = ' num2str(day, '%02d')])
        p.subjID                        = num2str(subjID,'%02d');
        p.day                           = day;
        if subjID == 1 && day == 1
            [p, ~]                    = initialization(p, 'eeg', 0);
            p.figure                        = [p.datc '/Figures/eeg_analysis'];
            meta_data                       = readtable([p.analysis '/EEG_TMS_meta - Summary.csv']);
            HemiStimulated                  = table2cell(meta_data(:, ["HemisphereStimulated"]));
            NoTMSDays                       = table2array(meta_data(:, ["NoTMSDay"]));
        end

        this_hemi                       = HemiStimulated{subjID};

        % File names
        fName.folder                    = [p.saveEEG '/sub' p.subjID '/day' num2str(p.day,'%02d')];
        fName.general                   = [fName.folder '/sub' p.subjID '_day' num2str(p.day,'%02d')];
        fName.erp                       = [fName.general '_erp.mat'];
        fName.tms_erp                   = [fName.general '_tms_erp.mat'];
        fName.TFR                       = [fName.general '_TFR.mat'];
        fName.TMS_TFR                   = [fName.general '_TMS_TFR.mat'];
        
        % Load flagged trials based on timing errors
        load([p.analysis '/sub' num2str(subjID, '%02d') '/flagged_trls.mat'])
        block_flag = flg.block(flg.day == p.day);
        trl_flag = flg.trls(flg.day == p.day);
        trls_to_remove = (block_flag - 1) * 40 + trl_flag;
        [flg_trls, flg_chans]           = flagged_trls_chans(subjID, day);
        
        if p.day == NoTMSDays(subjID)
            load(fName.TFR, 'POW')
        else
            load(fName.TMS_TFR, 'TMSPOW')
            POW                         = TMSPOW;
            clearvars TMSPOW;
        end
        
        if subjID == 1 && day == 1
            tidx                                        = find((POW.prointoVF.time >= t_stamp(1)) ...
                                                                & (POW.prointoVF.time <= t_stamp(2)));
            fidx                                        = find((POW.prointoVF.freq >= f_stamp(1)) ...
                                                                & (POW.prointoVF.freq <= f_stamp(2)));
            chanlist                                    = POW.prointoVF.label;
            
            
        end
        if strcmp(this_hemi, 'Left')
            cidx_i                                  = find(ismember(chanlist, right_occ_elecs));
            cidx_c                                  = find(ismember(chanlist, left_occ_elecs));
        else
            cidx_i                                  = find(ismember(chanlist, left_occ_elecs));
            cidx_c                                  = find(ismember(chanlist, right_occ_elecs));
        end
        
        % Compute alpha power in the time range of interest
        ALPHA.Pin.ipsi                            = squeeze(mean(POW.prointoVF.powspctrm(:, cidx_i, fidx, tidx), [2,3], 'omitnan'));
        ALPHA.Pout.ipsi                         = squeeze(mean(POW.prooutVF.powspctrm(:, cidx_i, fidx, tidx), [2,3], 'omitnan'));
        ALPHA.Ain.ipsi                       = squeeze(mean(POW.antiintoVF.powspctrm(:, cidx_i, fidx, tidx), [2,3], 'omitnan'));
        ALPHA.Aout.ipsi                        = squeeze(mean(POW.antioutVF.powspctrm(:, cidx_i, fidx, tidx), [2,3], 'omitnan'));
        
        ALPHA.Pin.contra                      = squeeze(mean(POW.prointoVF.powspctrm(:, cidx_c, fidx, tidx), [2,3], 'omitnan'));
        ALPHA.Pout.contra                       = squeeze(mean(POW.prooutVF.powspctrm(:, cidx_c, fidx, tidx), [2,3], 'omitnan'));
        ALPHA.Ain.contra                     = squeeze(mean(POW.antiintoVF.powspctrm(:, cidx_c, fidx, tidx), [2,3], 'omitnan'));
        ALPHA.Aout.contra                      = squeeze(mean(POW.antioutVF.powspctrm(:, cidx_c, fidx, tidx), [2,3], 'omitnan'));

        % Load behavior
        behav_fname = [p.analysis '/sub' p.subjID '/day' num2str(p.day,'%02d') '/ii_sess_sub' p.subjID '_day' num2str(p.day,'%02d') '.mat'];
        load(behav_fname);

        % Load EEG flag sequence
        EEGflags_fname = [p.analysis '/sub' p.subjID '/day' num2str(p.day,'%02d') '/EEGflags.mat'];
        load(EEGflags_fname)
        trl_order = flags.num(flags.num>10);

        % Check if the trial count matches
        if size(POW.prointoVF.powspctrm, 1)+size(POW.prooutVF.powspctrm, 1) ...
                +size(POW.antiintoVF.powspctrm, 1)+size(POW.antioutVF.powspctrm, 1) ...
                == 400 - length(flg_trls) - length(trls_to_remove)
            
            firstpass_goodtrls              = setdiff(1:400, trls_to_remove);
            
            prointoVF_trls                  = find(trl_order(firstpass_goodtrls) == 11);
            trls.Pin                        = setdiff(prointoVF_trls, flg_trls);
            prooutVF_trls                   = find(trl_order(firstpass_goodtrls) == 12);
            trls.Pout                       = setdiff(prooutVF_trls, flg_trls);
            antiintoVF_trls                 = find(trl_order(firstpass_goodtrls) == 13);
            trls.Ain                        = setdiff(antiintoVF_trls, flg_trls);
            antioutVF_trls                  = find(trl_order(firstpass_goodtrls) == 14);
            trls.Aout                       = setdiff(antioutVF_trls, flg_trls);
            
            

            if day == NoTMSDays(subjID)
                if ~exist('mALI', 'var') || ~isfield(mALI, 'NT')
                    for tt = ttypes
                        mALI.NT.(tt)               = ALPHA.(tt).contra - ALPHA.(tt).ipsi;
                        ierr.NT.(tt)               = eval(['ii_sess.i_sacc_err(trls.' char(tt) ')']);
                        irt.NT.(tt)                = eval(['ii_sess.i_sacc_rt(trls.' char(tt) ')']);
                        ferr.NT.(tt)               = eval(['ii_sess.f_sacc_err(trls.' char(tt) ')']);
                        frt.NT.(tt)                = eval(['ii_sess.f_sacc_rt(trls.' char(tt) ')']);
                    end
                else
                    for tt = ttypes
                        mALI.NT.(tt)               = cat(1, mALI.NT.(tt), ALPHA.(tt).contra - ALPHA.(tt).ipsi);
                        ierr.NT.(tt)               = cat(1, ierr.NT.(tt), eval(['ii_sess.i_sacc_err(trls.' char(tt) ')']));
                        irt.NT.(tt)                = cat(1, irt.NT.(tt), eval(['ii_sess.i_sacc_rt(trls.' char(tt) ')']));
                        ferr.NT.(tt)               = cat(1, ferr.NT.(tt), eval(['ii_sess.f_sacc_err(trls.' char(tt) ')']));
                        frt.NT.(tt)                = cat(1, frt.NT.(tt), eval(['ii_sess.f_sacc_rt(trls.' char(tt) ')']));
                    end
                end
            else
                if ~exist('mALI', 'var') || ~isfield(mALI, 'T')
                    for tt = ttypes
                        mALI.T.(tt)                = ALPHA.(tt).contra - ALPHA.(tt).ipsi;
                        ierr.T.(tt)                = eval(['ii_sess.i_sacc_err(trls.' char(tt) ')']);
                        irt.T.(tt)                 = eval(['ii_sess.i_sacc_rt(trls.' char(tt) ')']);
                        ferr.T.(tt)               = eval(['ii_sess.f_sacc_err(trls.' char(tt) ')']);
                        frt.T.(tt)                = eval(['ii_sess.f_sacc_rt(trls.' char(tt) ')']);
                    end
                else
                    for tt = ttypes
                        mALI.T.(tt)                = cat(1, mALI.T.(tt), ALPHA.(tt).contra - ALPHA.(tt).ipsi);
                        ierr.T.(tt)                = cat(1, ierr.T.(tt), eval(['ii_sess.i_sacc_err(trls.' char(tt) ')']));
                        irt.T.(tt)                 = cat(1, irt.T.(tt), eval(['ii_sess.i_sacc_rt(trls.' char(tt) ')']));
                        ferr.T.(tt)               = cat(1, ferr.T.(tt), eval(['ii_sess.f_sacc_err(trls.' char(tt) ')']));
                        frt.T.(tt)                = cat(1, frt.T.(tt), eval(['ii_sess.f_sacc_rt(trls.' char(tt) ')']));
                    end
                end
            end
                    
            if length(trls.Pin) ~= size(POW.prointoVF.powspctrm, 1)
                disp('Rerun this subject for proiotoVF')
            elseif length(trls.Pout) ~= size(POW.prooutVF.powspctrm, 1)
                disp('Rerun this subject for prooutVF')
            elseif length(trls.Ain) ~= size(POW.antiintoVF.powspctrm, 1)
                disp('Rerun this subject for antiintoVF')
            elseif length(trls.Aout) ~= size(POW.antioutVF.powspctrm, 1)
                disp('Rerun this subject for antioutVF')
            end
        else
            disp("Don't run this subject")
        end
        clearvars POW ii_sess ALPHA ALI
    end
end

for tt = ttypes
    [ierr_sort.NT.(tt), idx_e.NT.(tt)]          = sort(ierr.NT.(tt), 'descend', 'MissingPlacement', 'last');
    [irt_sort.NT.(tt), idx_rt.NT.(tt)]          = sort(irt.NT.(tt), 'descend', 'MissingPlacement', 'last');
    [ierr_sort.T.(tt), idx_e.T.(tt)]            = sort(ierr.T.(tt), 'descend', 'MissingPlacement', 'last');
    [irt_sort.T.(tt), idx_rt.T.(tt)]            = sort(irt.T.(tt), 'descend', 'MissingPlacement', 'last');
    idx_e.NT.(tt)(find(isnan(ierr_sort.NT.(tt)))) = [];
    idx_rt.NT.(tt)(find(isnan(irt_sort.NT.(tt)))) = [];
    idx_e.T.(tt)(find(isnan(ierr_sort.T.(tt)))) = [];
    idx_rt.T.(tt)(find(isnan(irt_sort.T.(tt)))) = [];
end

figfolder = '/datc/MD_TMS_EEG/Figures/ALI_trialwise/';
for cc = conds
    for tt = ttypes
        tname = ['ALI error: ' char(cc) '_' char(tt)];
        fname = ['ALI_error_' char(cc) '_' char(tt)];
        figure();
        imagesc(mALI.(cc).(tt)(idx_e.(cc).(tt), :))
        xt = get(gca, 'XTick'); 
        xtlbl = linspace(-0.5, 4.5, numel(xt));                  
        set(gca, 'XTick', xt, 'XTickLabel', round(xtlbl, 2)) 
        caxis([-5 5])
        colorbar;
        title(tname)
        saveas(gcf, [figfolder fname], 'png')
    end
end

subplot(4, 2, 2)
imagesc(mALI.T.Pin(idx_e.T.Pin, :))
subplot(4, 2, 3)
imagesc(mALI.NT.Pout(idx_e.NT.Pout, :))
subplot(4, 2, 4)
imagesc(mALI.T.Pout(idx_e.T.Pout, :))
subplot(4, 2, 5)
imagesc(mALI.NT.Ain(idx_e.NT.Ain, :))
subplot(4, 2, 6)
imagesc(mALI.T.Ain(idx_e.T.Ain, :))
subplot(4, 2, 7)
imagesc(mALI.NT.Aout(idx_e.NT.Aout, :))
subplot(4, 2, 8)
imagesc(mALI.T.Aout(idx_e.T.Aout, :))

figure();
subplot(4, 2, 1)
imagesc(mALI.NT.Pin(idx_rt.NT.Pin, :))
subplot(4, 2, 2)
imagesc(mALI.T.Pin(idx_rt.T.Pin, :))
subplot(4, 2, 3)
imagesc(mALI.NT.Pout(idx_rt.NT.Pout, :))
subplot(4, 2, 4)
imagesc(mALI.T.Pout(idx_rt.T.Pout, :))
subplot(4, 2, 5)
imagesc(mALI.NT.Ain(idx_rt.NT.Ain, :))
subplot(4, 2, 6)
imagesc(mALI.T.Ain(idx_rt.T.Ain, :))
subplot(4, 2, 7)
imagesc(mALI.NT.Aout(idx_rt.NT.Aout, :))
subplot(4, 2, 8)
imagesc(mALI.T.Aout(idx_rt.T.Aout, :))



end
