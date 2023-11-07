function A06_PhasewithBehav()
clearvars; close all; clc;
warning('off', 'all');

subs                                        = [1 3 5 6 7 8 11 12 13 14 15 16 17 18 22 23 24 25 26 27];
%subs                                        = [1 3 ];
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

addpath('/d/DATA/hyper/spacebox/circStats');
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
            load(fName.TFR, 'PHASE')
        else
            load(fName.TMS_TFR, 'TMSPHASE')
            PHASE                         = TMSPHASE;
            clearvars TMSPHASE;
        end
        
        if subjID == 1 && day == 1
            tidx                                        = find((PHASE.prointoVF.time >= t_stamp(1)) ...
                                                                & (PHASE.prointoVF.time <= t_stamp(2)));
            fidx                                        = find((PHASE.prointoVF.freq >= f_stamp(1)) ...
                                                                & (PHASE.prointoVF.freq <= f_stamp(2)));
            chanlist                                    = PHASE.prointoVF.label;
            
            
        end
        if strcmp(this_hemi, 'Left')
            cidx_i                                  = find(ismember(chanlist, right_occ_elecs));
            cidx_c                                  = find(ismember(chanlist, left_occ_elecs));
        else
            cidx_i                                  = find(ismember(chanlist, left_occ_elecs));
            cidx_c                                  = find(ismember(chanlist, right_occ_elecs));
        end
        
        % Compute alpha power in the time range of interest
        ALPHA.Pin.ipsi                            = get_circmean(PHASE.prointoVF.phaseangle(:, cidx_i, fidx, tidx));
        ALPHA.Pout.ipsi                           = get_circmean(PHASE.prooutVF.phaseangle(:, cidx_i, fidx, tidx));
        ALPHA.Ain.ipsi                            = get_circmean(PHASE.antiintoVF.phaseangle(:, cidx_i, fidx, tidx));
        ALPHA.Aout.ipsi                           = get_circmean(PHASE.antioutVF.phaseangle(:, cidx_i, fidx, tidx));
        
        ALPHA.Pin.contra                          = get_circmean(PHASE.prointoVF.phaseangle(:, cidx_c, fidx, tidx));
        ALPHA.Pout.contra                         = get_circmean(PHASE.prooutVF.phaseangle(:, cidx_c, fidx, tidx));
        ALPHA.Ain.contra                          = get_circmean(PHASE.antiintoVF.phaseangle(:, cidx_c, fidx, tidx));
        ALPHA.Aout.contra                         = get_circmean(PHASE.antioutVF.phaseangle(:, cidx_c, fidx, tidx));

        % Load behavior
        behav_fname = [p.analysis '/sub' p.subjID '/day' num2str(p.day,'%02d') '/ii_sess_sub' p.subjID '_day' num2str(p.day,'%02d') '.mat'];
        load(behav_fname);

        % Load EEG flag sequence
        EEGflags_fname = [p.analysis '/sub' p.subjID '/day' num2str(p.day,'%02d') '/EEGflags.mat'];
        load(EEGflags_fname)
        trl_order = flags.num(flags.num>10);

        % Check if the trial count matches
        if size(PHASE.prointoVF.phaseangle, 1)+size(PHASE.prooutVF.phaseangle, 1) ...
                +size(PHASE.antiintoVF.phaseangle, 1)+size(PHASE.antioutVF.phaseangle, 1) ...
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
            
            side = "contra";

            if day == NoTMSDays(subjID)
                if ~exist('mALI', 'var') || ~isfield(mALI, 'NT')
                    for tt = ttypes
                        mALI.NT.(tt)               = ALPHA.(tt).(side);
                        ierr.NT.(tt)               = eval(['ii_sess.i_sacc_err(trls.' char(tt) ')']);
                        irt.NT.(tt)                = eval(['ii_sess.i_sacc_rt(trls.' char(tt) ')']);
                        ferr.NT.(tt)               = eval(['ii_sess.f_sacc_err(trls.' char(tt) ')']);
                        frt.NT.(tt)                = eval(['ii_sess.f_sacc_rt(trls.' char(tt) ')']);
                    end
                else
                    for tt = ttypes
                        mALI.NT.(tt)               = cat(1, mALI.NT.(tt), ALPHA.(tt).(side));
                        ierr.NT.(tt)               = cat(1, ierr.NT.(tt), eval(['ii_sess.i_sacc_err(trls.' char(tt) ')']));
                        irt.NT.(tt)                = cat(1, irt.NT.(tt), eval(['ii_sess.i_sacc_rt(trls.' char(tt) ')']));
                        ferr.NT.(tt)               = cat(1, ferr.NT.(tt), eval(['ii_sess.f_sacc_err(trls.' char(tt) ')']));
                        frt.NT.(tt)                = cat(1, frt.NT.(tt), eval(['ii_sess.f_sacc_rt(trls.' char(tt) ')']));
                    end
                end
            else
                if ~exist('mALI', 'var') || ~isfield(mALI, 'T')
                    for tt = ttypes
                        mALI.T.(tt)                = ALPHA.(tt).(side);
                        ierr.T.(tt)                = eval(['ii_sess.i_sacc_err(trls.' char(tt) ')']);
                        irt.T.(tt)                 = eval(['ii_sess.i_sacc_rt(trls.' char(tt) ')']);
                        ferr.T.(tt)               = eval(['ii_sess.f_sacc_err(trls.' char(tt) ')']);
                        frt.T.(tt)                = eval(['ii_sess.f_sacc_rt(trls.' char(tt) ')']);
                    end
                else
                    for tt = ttypes
                        mALI.T.(tt)                = cat(1, mALI.T.(tt), ALPHA.(tt).(side));
                        ierr.T.(tt)                = cat(1, ierr.T.(tt), eval(['ii_sess.i_sacc_err(trls.' char(tt) ')']));
                        irt.T.(tt)                 = cat(1, irt.T.(tt), eval(['ii_sess.i_sacc_rt(trls.' char(tt) ')']));
                        ferr.T.(tt)               = cat(1, ferr.T.(tt), eval(['ii_sess.f_sacc_err(trls.' char(tt) ')']));
                        frt.T.(tt)                = cat(1, frt.T.(tt), eval(['ii_sess.f_sacc_rt(trls.' char(tt) ')']));
                    end
                end
            end
                    
            if length(trls.Pin) ~= size(PHASE.prointoVF.phaseangle, 1)
                disp('Rerun this subject for proiotoVF')
            elseif length(trls.Pout) ~= size(PHASE.prooutVF.phaseangle, 1)
                disp('Rerun this subject for prooutVF')
            elseif length(trls.Ain) ~= size(PHASE.antiintoVF.phaseangle, 1)
                disp('Rerun this subject for antiintoVF')
            elseif length(trls.Aout) ~= size(PHASE.antioutVF.phaseangle, 1)
                disp('Rerun this subject for antioutVF')
            end
        else
            disp("Don't run this subject")
        end
        clearvars PHASE ii_sess ALPHA ALI
    end
end

for tt = ttypes
    [ierr_sort.NT.(tt), idx_e.NT.(tt)]          = sort(ierr.NT.(tt), 'descend', 'MissingPlacement', 'last');
    [irt_sort.NT.(tt), idx_rt.NT.(tt)]          = sort(irt.NT.(tt), 'descend', 'MissingPlacement', 'last');
    [ierr_sort.T.(tt), idx_e.T.(tt)]            = sort(ierr.T.(tt), 'descend', 'MissingPlacement', 'last');
    [irt_sort.T.(tt), idx_rt.T.(tt)]            = sort(irt.T.(tt), 'descend', 'MissingPlacement', 'last');

    [ferr_sort.NT.(tt), fdx_e.NT.(tt)]          = sort(ferr.NT.(tt), 'descend', 'MissingPlacement', 'last');
    [frt_sort.NT.(tt), fdx_rt.NT.(tt)]          = sort(frt.NT.(tt), 'descend', 'MissingPlacement', 'last');
    [ferr_sort.T.(tt), fdx_e.T.(tt)]            = sort(ferr.T.(tt), 'descend', 'MissingPlacement', 'last');
    [frt_sort.T.(tt), fdx_rt.T.(tt)]            = sort(frt.T.(tt), 'descend', 'MissingPlacement', 'last');

    idx_e.NT.(tt)(isnan(ierr_sort.NT.(tt))) = [];
    idx_rt.NT.(tt)(isnan(irt_sort.NT.(tt))) = [];
    idx_e.T.(tt)(isnan(ierr_sort.T.(tt))) = [];
    idx_rt.T.(tt)(isnan(irt_sort.T.(tt))) = [];

    fdx_e.NT.(tt)(isnan(ferr_sort.NT.(tt))) = [];
    fdx_rt.NT.(tt)(isnan(frt_sort.NT.(tt))) = [];
    fdx_e.T.(tt)(isnan(ferr_sort.T.(tt))) = [];
    fdx_rt.T.(tt)(isnan(frt_sort.T.(tt))) = [];
    
    ierr_sort.NT.(tt)(isnan(ierr_sort.NT.(tt))) = [];
    irt_sort.NT.(tt)(isnan(irt_sort.NT.(tt))) = [];
    ierr_sort.T.(tt)(isnan(ierr_sort.T.(tt))) = [];
    irt_sort.T.(tt)(isnan(irt_sort.T.(tt))) = [];

    ferr_sort.NT.(tt)(isnan(ferr_sort.NT.(tt))) = [];
    frt_sort.NT.(tt)(isnan(frt_sort.NT.(tt))) = [];
    ferr_sort.T.(tt)(isnan(ferr_sort.T.(tt))) = [];
    frt_sort.T.(tt)(isnan(frt_sort.T.(tt))) = [];
end

crange = [-pi pi];
figfolder = '/datc/MD_TMS_EEG/Figures/PHASE_trialwise/';
t_array = linspace(-0.5, 4.5, size(mALI.NT.Pin, 2));
bt = find(t_array<0);
for cc = conds
    for tt = ttypes
        % Initial saccade error
        tname = ['ALI Ierror: ' char(cc) ' ' char(tt)];
        fname = ['ALI_ierror_' char(cc) '_' char(tt)];
        figure();
        subplot(1, 2, 1)
        position1 = [0.1, 0.1, 0.15, 0.8]; % [left, bottom, width, height]
        set(gca, 'Position', position1);
        barh(1:length(idx_e.(cc).(tt)), ierr_sort.(cc).(tt))
        set(gca, 'YDir', 'reverse');
        ylabel('Trials')
        xlabel('Ierr (dva)')
        subplot(1, 2, 2)
        position2 = [0.3, 0.1, 0.65, 0.8]; % [left, bottom, width, height]
        set(gca, 'Position', position2);
        imagesc(mALI.(cc).(tt)(idx_e.(cc).(tt), :))
        xt = get(gca, 'XTick'); 
        xtlbl = linspace(-0.5, 4.5, numel(xt));                  
        set(gca, 'XTick', xt, 'XTickLabel', round(xtlbl, 2)) 
        yticks([]);
        caxis(crange)
        colorbar;
        xlabel('Time (s)')
        title(tname)
        saveas(gcf, [figfolder fname], 'png')

        % Final saccade error
        tname = ['ALI Ferror: ' char(cc) ' ' char(tt)];
        fname = ['ALI_ferror_' char(cc) '_' char(tt)];
        figure();
        subplot(1, 2, 1)
        position1 = [0.1, 0.1, 0.15, 0.8]; % [left, bottom, width, height]
        set(gca, 'Position', position1);
        barh(1:length(fdx_e.(cc).(tt)), ferr_sort.(cc).(tt))
        set(gca, 'YDir', 'reverse');
        ylabel('Trials')
        xlabel('Ferr (dva)')
        subplot(1, 2, 2)
        position2 = [0.3, 0.1, 0.65, 0.8]; % [left, bottom, width, height]
        set(gca, 'Position', position2);
        imagesc(mALI.(cc).(tt)(fdx_e.(cc).(tt), :))
        xt = get(gca, 'XTick'); 
        xtlbl = linspace(-0.5, 4.5, numel(xt));                  
        set(gca, 'XTick', xt, 'XTickLabel', round(xtlbl, 2)) 
        yticks([]);
        caxis(crange)
        colorbar;
        xlabel('Time (s)')
        title(tname)
        saveas(gcf, [figfolder fname], 'png')

        % Initial saccade reaction time
        tname = ['ALI Irt: ' char(cc) ' ' char(tt)];
        fname = ['ALI_irt_' char(cc) '_' char(tt)];
        figure();
        subplot(1, 2, 1)
        position1 = [0.1, 0.1, 0.15, 0.8]; % [left, bottom, width, height]
        set(gca, 'Position', position1);
        barh(1:length(idx_rt.(cc).(tt)), irt_sort.(cc).(tt))
        set(gca, 'YDir', 'reverse');
        ylabel('Trials')
        xlabel('Irt (s)')
        subplot(1, 2, 2)
        position2 = [0.3, 0.1, 0.65, 0.8]; % [left, bottom, width, height]
        set(gca, 'Position', position2);
        imagesc(mALI.(cc).(tt)(idx_rt.(cc).(tt), :))
        xt = get(gca, 'XTick'); 
        xtlbl = linspace(-0.5, 4.5, numel(xt));                  
        set(gca, 'XTick', xt, 'XTickLabel', round(xtlbl, 2)) 
        yticks([]);
        caxis(crange)
        colorbar;
        xlabel('Time (s)')
        title(tname)
        saveas(gcf, [figfolder fname], 'png')

        % Final saccade reaction time
        tname = ['ALI Frt: ' char(cc) ' ' char(tt)];
        fname = ['ALI_frt_' char(cc) '_' char(tt)];
        figure();
        subplot(1, 2, 1)
        position1 = [0.1, 0.1, 0.15, 0.8]; % [left, bottom, width, height]
        set(gca, 'Position', position1);
        barh(1:length(fdx_rt.(cc).(tt)), frt_sort.(cc).(tt))
        set(gca, 'YDir', 'reverse');
        ylabel('Trials')
        xlabel('Frt (s)')
        subplot(1, 2, 2)
        position2 = [0.3, 0.1, 0.65, 0.8]; % [left, bottom, width, height]
        set(gca, 'Position', position2);
        imagesc(mALI.(cc).(tt)(fdx_rt.(cc).(tt), :))
        xt = get(gca, 'XTick'); 
        xtlbl = linspace(-0.5, 4.5, numel(xt));                  
        set(gca, 'XTick', xt, 'XTickLabel', round(xtlbl, 2)) 
        yticks([]);
        caxis(crange)
        colorbar;
        xlabel('Time (s)')
        title(tname)
        saveas(gcf, [figfolder fname], 'png')
    end
end 

% 
% for cc = conds
%     for tt = ttypes
%         this_ALI = mALI.(cc).(tt);
%         bALI = this_ALI - mean(this_ALI(:, bt), "all", "omitnan");
%         % Initial saccade error
%         tname = ['ALI Ierror: ' char(cc) ' ' char(tt)];
%         fname = ['ALI_ierror_' char(cc) '_' char(tt)];
%         figure();
%         subplot(1, 2, 1)
%         position1 = [0.1, 0.1, 0.15, 0.8]; % [left, bottom, width, height]
%         set(gca, 'Position', position1);
%         barh(1:length(idx_e.(cc).(tt)), ierr_sort.(cc).(tt))
%         set(gca, 'YDir', 'reverse');
%         ylabel('Trials')
%         xlabel('Ierr (dva)')
%         subplot(1, 2, 2)
%         position2 = [0.3, 0.1, 0.65, 0.8]; % [left, bottom, width, height]
%         set(gca, 'Position', position2);
%         imagesc(bALI(idx_e.(cc).(tt), :))
%         xt = get(gca, 'XTick'); 
%         xtlbl = linspace(-0.5, 4.5, numel(xt));                  
%         set(gca, 'XTick', xt, 'XTickLabel', round(xtlbl, 2)) 
%         yticks([]);
%         caxis(crange)
%         colorbar;
%         xlabel('Time (s)')
%         title(tname)
%         saveas(gcf, [figfolder fname], 'png')
% 
%         % Final saccade error
%         tname = ['ALI Ferror: ' char(cc) ' ' char(tt)];
%         fname = ['ALI_ferror_' char(cc) '_' char(tt)];
%         figure();
%         subplot(1, 2, 1)
%         position1 = [0.1, 0.1, 0.15, 0.8]; % [left, bottom, width, height]
%         set(gca, 'Position', position1);
%         barh(1:length(fdx_e.(cc).(tt)), ferr_sort.(cc).(tt))
%         set(gca, 'YDir', 'reverse');
%         ylabel('Trials')
%         xlabel('Ferr (dva)')
%         subplot(1, 2, 2)
%         position2 = [0.3, 0.1, 0.65, 0.8]; % [left, bottom, width, height]
%         set(gca, 'Position', position2);
%         imagesc(bALI(fdx_e.(cc).(tt), :))
%         xt = get(gca, 'XTick'); 
%         xtlbl = linspace(-0.5, 4.5, numel(xt));                  
%         set(gca, 'XTick', xt, 'XTickLabel', round(xtlbl, 2)) 
%         yticks([]);
%         caxis(crange)
%         colorbar;
%         xlabel('Time (s)')
%         title(tname)
%         saveas(gcf, [figfolder fname], 'png')
% 
%         % Initial saccade reaction time
%         tname = ['ALI Irt: ' char(cc) ' ' char(tt)];
%         fname = ['ALI_irt_' char(cc) '_' char(tt)];
%         figure();
%         subplot(1, 2, 1)
%         position1 = [0.1, 0.1, 0.15, 0.8]; % [left, bottom, width, height]
%         set(gca, 'Position', position1);
%         barh(1:length(idx_rt.(cc).(tt)), irt_sort.(cc).(tt))
%         set(gca, 'YDir', 'reverse');
%         ylabel('Trials')
%         xlabel('Irt (s)')
%         subplot(1, 2, 2)
%         position2 = [0.3, 0.1, 0.65, 0.8]; % [left, bottom, width, height]
%         set(gca, 'Position', position2);
%         imagesc(bALI(idx_rt.(cc).(tt), :))
%         xt = get(gca, 'XTick'); 
%         xtlbl = linspace(-0.5, 4.5, numel(xt));                  
%         set(gca, 'XTick', xt, 'XTickLabel', round(xtlbl, 2)) 
%         yticks([]);
%         caxis(crange)
%         colorbar;
%         xlabel('Time (s)')
%         title(tname)
%         saveas(gcf, [figfolder fname], 'png')
% 
%         % Final saccade reaction time
%         tname = ['ALI Frt: ' char(cc) ' ' char(tt)];
%         fname = ['ALI_frt_' char(cc) '_' char(tt)];
%         figure();
%         subplot(1, 2, 1)
%         position1 = [0.1, 0.1, 0.15, 0.8]; % [left, bottom, width, height]
%         set(gca, 'Position', position1);
%         barh(1:length(fdx_rt.(cc).(tt)), frt_sort.(cc).(tt))
%         set(gca, 'YDir', 'reverse');
%         ylabel('Trials')
%         xlabel('Frt (s)')
%         subplot(1, 2, 2)
%         position2 = [0.3, 0.1, 0.65, 0.8]; % [left, bottom, width, height]
%         set(gca, 'Position', position2);
%         imagesc(bALI(fdx_rt.(cc).(tt), :))
%         xt = get(gca, 'XTick'); 
%         xtlbl = linspace(-0.5, 4.5, numel(xt));                  
%         set(gca, 'XTick', xt, 'XTickLabel', round(xtlbl, 2)) 
%         yticks([]);
%         caxis(crange)
%         colorbar;
%         xlabel('Time (s)')
%         title(tname)
%         saveas(gcf, [figfolder fname], 'png')
%     end
% end 
end
