function A06_TrialwiseCDA()
clearvars; close all; clc;
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
left_occ_elecs = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_occ_elecs = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('HOSTNAME');
end
hostname = strtrim(hostname);
if strcmp(hostname, 'zod')
    fName.mCDA                              = ['/d/DATD/datd/MD_TMS_EEG/EEGfiles/CDA.mat'];
else
    fName.mCDA                              = ['/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datd/MD_TMS_EEG/EEGfiles/CDA.mat'];
end

mCDA = [];
trl_mat = [];
if ~exist(fName.mCDA, 'file')
    for sidx                                = 1:length(subs)
        subjID                              = subs(sidx);
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
            fName.erp_trialwise             = [fName.general '_erp_trialwise.mat'];

            
            % Load relevant files
            load(fName.erp_trialwise);
            load(fName.trl_idx);
            load(fName.flag_data);
    
%             tidx_before                     = find((ERP.pin.time > t_stamp(1)) ...
%                 & (ERP.pin.time < t_stamp(2)));
%             tidx_after                      = find((ERP.pin.time > t_stamp(3)) ...
%                 & (ERP.pin.time < t_stamp(4)));
%             tidx                            = [tidx_before tidx_after];

            % Setting electrodes ipsi vs contra relative to inPF 
            if strcmp(HemiStimulated{subjID}, 'Left')
                ipsi_idx                    = find(ismember(ERP.pin.label, right_occ_elecs));
                contra_idx                  = find(ismember(ERP.pin.label, left_occ_elecs));
            else
                ipsi_idx                    = find(ismember(ERP.pin.label, left_occ_elecs));
                contra_idx                  = find(ismember(ERP.pin.label, right_occ_elecs));
            end

            for ii = 1:length(t_types)
                ttype = t_types(ii);
                this_ipsi                   = mean(ERP.(ttype).avg(ipsi_idx, :), 1, 'omitnan');
                this_contra                 = mean(ERP.(ttype).avg(contra_idx, :), 1, 'omitnan');
                this_cda                    = this_contra - this_ipsi;
                %tcount                      = size(this_cda.powspctrm, 1);
                mCDA(sidx, day, ii, :)      = this_cda;
                
%                 temp_trl_mat                = NaN(tcount, 5);
%                 temp_trl_mat(:, 1)          = subjID;
%                 temp_trl_mat(:, 2)          = day;
%                 if p.day                    == NoTMSDays(subjID)
%                     temp_trl_mat(:, 3)      = 0;
%                 else
%                     temp_trl_mat(:, 3)      = 1;
%                 end
%                 temp_trl_mat(:, 4)          = ii;
%                 disp([subjID day])
%                 temp_trl_mat(:, 5)          = setdiff(trl_idx.(ttype), trls_to_remove);
%                 trl_mat                     = [trl_mat; temp_trl_mat];
            end
        end
        clearvars ERP;
    end
    %mCDA = squeeze(mCDA);
    save(fName.mCDA, 'mCDA', '-v7.3')
else
    disp('Loading existing master ALI file')
    load(fName.mCDA)
end

end