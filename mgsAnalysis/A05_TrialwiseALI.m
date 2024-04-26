function A05_TrialwiseALI(tfr_type, base_corr)
clearvars -except tfr_type base_corr; close all; clc;
warning('off', 'all');

subs                                        = [1 3 5 6 7 10 12 14 15 16 17 22 23 25 26 27];
%subs = [1 3];
days                                        = [1 2 3];
t_stamp                                     = [0.5 2 3 4.5];
f_stamp                                     = [8 12];
conds                                       = ["NT", "T"];
t_types                                     = ["pin", "pout", "ain", "aout"];
t_types                                     = ["pin", "pout"];
t_types_in                                  = ["pin", "ain"];
locs                                        = ["ipsi", "contra"];
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);
if strcmp(hostname, 'zod')
    fName.mALI                              = ['/d/DATD/datd/MD_TMS_EEG/EEGfiles/ALI_' tfr_type '_basecorr' num2str(base_corr) '.mat'];
else
    fName.mALI                              = ['/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datd/MD_TMS_EEG/EEGfiles/ALI_' tfr_type '_basecorr' num2str(base_corr) '.mat'];
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
            fName.TFR_evoked_basecorr       = [fName.general '_TFR_evoked_basecorr.mat'];
            fName.TFR_induced_basecorr      = [fName.general '_TFR_induced_basecorr.mat'];

            %[~, flg_chans]                  = flagged_trls_chans(subjID, day);
            if strcmp(tfr_type, 'induced')
                if base_corr == 0
                    load(fName.TFR_induced, 'POW');
                else
                    load(fName.TFR_induced_basecorr, 'POW');
                end
            elseif strcmp(tfr_type, 'evoked')
                if base_corr == 0
                    load(fName.TFR_evoked, 'POW');
                else
                    load(fName.TFR_evoked_basecorr, 'POW');
                end
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