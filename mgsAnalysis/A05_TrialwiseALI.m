function A05_TrialwiseALI(tfr_type)
clearvars -except tfr_type; close all; clc;
warning('off', 'all');

subs                                        = [1 3 5 6 7 10 12 14 15 16 17 22 23 24 25 26 27];
%subs = [1 3];
days                                        = [1 2 3];
t_stamp                                     = [0.5 2 3 4.5];
f_stamp                                     = [8 12];
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
        fName.mALI                                  = '/datc/MD_TMS_EEG/EEGfiles/ALI_evoked.mat';
    elseif strcmp(tfr_type, 'induced')
        fName.mALI                                  = '/datc/MD_TMS_EEG/EEGfiles/ALI_induced.mat';
    end
else
    if strcmp(tfr_type, 'evoked')
        fName.mALI                                  = '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/MD_TMS_EEG/EEGfiles/ALI_evoked.mat';
    elseif strcmp(tfr_type, 'induced')
        fName.mALI                                  = '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/MD_TMS_EEG/EEGfiles/ALI_induced.mat';
    end
end

mALI = [];
trl_mat = [];
if ~exist(fName.mALI, 'file')
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
            load(fName.trl_idx);
            load(fName.flag_data);
    
            tidx_before                     = find((POW.pin.time > t_stamp(1)) ...
                & (POW.pin.time < t_stamp(2)));
            tidx_after                      = find((POW.pin.time > t_stamp(3)) ...
                & (POW.pin.time < t_stamp(4)));
            tidx                            = [tidx_before tidx_after];
            fidx                            = find((POW.pin.freq > f_stamp(1)) ...
                & (POW.pin.freq < f_stamp(2)));
            
            for ii = 1:length(t_types)
                ttype = t_types(ii);
                this_ipsi                   = combineTFRs_ALI(POW.(ttype), this_hemi, 1, fidx);
                this_contra                 = combineTFRs_ALI(POW.(ttype), this_hemi, 0, fidx);
                cfg                         = [];
                cfg.operation               = '(10^(x1/10) - 10^(x2/10)) / (10^(x1/10) + 10^(x2/10))';
%                 cfg.operation               = '(x1-x2)';
                cfg.parameter               = 'powspctrm';
                pow_diff                    = ft_math(cfg, this_contra, this_ipsi);
                tcount                      = size(pow_diff.powspctrm, 1);
                mALI                        = cat(1, mALI, pow_diff.powspctrm);
                
                temp_trl_mat                = NaN(tcount, 5);
                temp_trl_mat(:, 1)          = subjID;
                temp_trl_mat(:, 2)          = day;
                if p.day                    == NoTMSDays(subjID)
                    temp_trl_mat(:, 3)      = 0;
                else
                    temp_trl_mat(:, 3)      = 1;
                end
                temp_trl_mat(:, 4)          = ii;
                disp([subjID day])
                temp_trl_mat(:, 5)          = setdiff(trl_idx.(ttype), trls_to_remove);
                trl_mat                     = [trl_mat; temp_trl_mat];
            end
            
            % Combine TFRs for this subject over all days based on trial and
            % session type
%             if p.day == NoTMSDays(subjID)
%                 disp(['Combining TFRs No TMS, day = ' num2str(p.day)])
%                 [TFR.NT.pin.ipsi, TFR.NT.pin.contra] ...
%                     = combineTFR_notms_ALI(POW, this_hemi, 'pin', 'pout');
%                 
%                 [TFR.NT.ain.ipsi, TFR.NT.ain.contra] ...
%                     = combineTFR_notms_ALI(POW, this_hemi, 'ain', 'aout');
%                 
%             else
%                 disp(['Combining TFRs TMS, day = ' num2str(p.day)])
%                 if ~exist('TFR', 'var') || ~isfield(TFR, 'T')
%                     
% 
%                     TFR.T.pin.ipsi          = combineTFRs_ALI(POW.pin, this_hemi, 1);
%                     TFR.T.pin.contra        = combineTFRs_ALI(POW.pin, this_hemi, 0);
%                     TFR.T.pout.ipsi         = combineTFRs_ALI(POW.pout, this_hemi, 1);
%                     TFR.T.pout.contra       = combineTFRs_ALI(POW.pout, this_hemi, 0);
%     
%                     TFR.T.ain.ipsi          = combineTFRs_ALI(POW.ain, this_hemi, 1);
%                     TFR.T.ain.contra        = combineTFRs_ALI(POW.ain, this_hemi, 0);
%                     TFR.T.aout.ipsi         = combineTFRs_ALI(POW.aout, this_hemi, 1);
%                     TFR.T.aout.contra       = combineTFRs_ALI(POW.aout, this_hemi, 0);
%                 else
%                     TFR.T.pin.ipsi          = combineTFRs_ALI(POW.pin, this_hemi, 1, TFR.T.pin.ipsi);
%                     TFR.T.pin.contra        = combineTFRs_ALI(POW.pin, this_hemi, 0, TFR.T.pin.contra);
%                     TFR.T.pout.ipsi         = combineTFRs_ALI(POW.pout, this_hemi, 1, TFR.T.pout.ipsi);
%                     TFR.T.pout.contra       = combineTFRs_ALI(POW.pout, this_hemi, 0, TFR.T.pout.contra);
%     
%                     TFR.T.ain.ipsi          = combineTFRs_ALI(POW.ain, this_hemi, 1, TFR.T.ain.ipsi);
%                     TFR.T.ain.contra        = combineTFRs_ALI(POW.ain, this_hemi, 0, TFR.T.ain.contra);
%                     TFR.T.aout.ipsi         = combineTFRs_ALI(POW.aout, this_hemi, 1, TFR.T.aout.ipsi);
%                     TFR.T.aout.contra       = combineTFRs_ALI(POW.aout, this_hemi, 0, TFR.T.aout.contra);
%                 end
%             end
%         end
%     
%         
%         % Store for combined analysis
%         for cond = conds
%             for ttype = t_types
%                 tcount = size(TFR.(cond).(ttype).powspctrm, 1);
%                 temp_trl_mat = NaN(tcount, 4);
%                 temp_trl_mat(:, 1) = subjID;
%                 temp_trl_mat(:, 2) = strcmp(cond, 'T');
%                 temp_trl_mat(:, 3) = ttype;
%                 temp_trl_mat(:, 4) = setdiff(trl_idx.(cond), trls_to_remove);
%                 mALI = cat(1, mALI, TFR.(cond).(ttype).powspctrm);
% 
%             end
%         end
% 
%         if ~isfield(mALI, 'NT')
%             for tt                          = t_types_in
%                 mALI.NT.(tt).ipsi           = TFR.NT.(tt).ipsi;
%                 mALI.NT.(tt).contra         = TFR.NT.(tt).contra;
%                 mALI.NT.(tt).all            = TFR.NT.(tt).all;
%             end
%             mALI.NT.pout.all                = TFR.NT.pout.all;
%             mALI.NT.aout.all                = TFR.NT.aout.all;
%         else
%             for tt                          = t_types_in
%                 mALI.NT.(tt).ipsi           = subject_level_grouping(mALI.NT.(tt).ipsi, TFR.NT.(tt).ipsi);
%                 mALI.NT.(tt).contra         = subject_level_grouping(mALI.NT.(tt).contra, TFR.NT.(tt).contra);
%                 mALI.NT.(tt).all            = subject_level_grouping(mALI.NT.(tt).all, TFR.NT.(tt).all, 1);
%             end
%             mALI.NT.pout.all                = subject_level_grouping(mALI.NT.pout.all, TFR.NT.pout.all, 1);
%             mALI.NT.aout.all                = subject_level_grouping(mALI.NT.aout.all, TFR.NT.aout.all, 1);
%         end
%     
%         if ~isfield(mALI, 'T')
%             for tt = t_types
%                 mALI.T.(tt).ipsi            = TFR.T.(tt).ipsi;
%                 mALI.T.(tt).contra          = TFR.T.(tt).contra;
%                 mALI.T.(tt).all             = TFR.T.(tt).all;
%             end
%         else
%             for tt = t_types
%                 mALI.T.(tt).ipsi            = subject_level_grouping(mALI.T.(tt).ipsi, TFR.T.(tt).ipsi);
%                 mALI.T.(tt).contra          = subject_level_grouping(mALI.T.(tt).contra, TFR.T.(tt).contra);
%                 mALI.T.(tt).all             = subject_level_grouping(mALI.T.(tt).all, TFR.T.(tt).all, 1);
%             end
%         end
        end
        clearvars POW;
    end
    mALI = squeeze(mALI);
    save(fName.mALI, 'mALI', 'trl_mat', '-v7.3')
else
    disp('Loading existing master ALI file')
    load(fName.mALI)
end

end