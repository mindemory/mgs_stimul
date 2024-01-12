%function TestingNewPipeline(subjID, day)

%clearvars -except subjID day; close all;
subjID = 1; day = 2;
left_occ_elecs = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_occ_elecs = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

p.subjID = num2str(subjID,'%02d');
p.day = day;

[p, taskMap] = initialization(p, 'eeg', 0);
meta_data = readtable([p.analysis '/EEG_TMS_meta_Summary.csv']);
load([p.analysis '/calib/sub' num2str(subjID, '%02d') '/flagged_trls.mat'])
% Load flagged trials based on timing errors
block_flag = flg.block(flg.day == p.day);
trl_flag = flg.trls(flg.day == p.day);
trls_to_remove = (block_flag - 1) * 40 + trl_flag;

HemiStimulated = table2cell(meta_data(:, ["HemisphereStimulated"]));
NoTMSDays = table2array(meta_data(:, ["NoTMSDay"]));
if day == NoTMSDays(subjID) % If this is a No TMS day
    steps = {'concat', 'raweeg', 'bandpass', 'reepoch', 'erp', 'tfr', 'tfr_induced'};
else % if this is a TMS day
    steps = {'concat', 'raweeg', 'remove_pulse', 'bandpass', 'reepoch', 'erp', 'tfr', 'tfr_induced'};
end

% List of files to be saved
% Step 1: Loading data 'subXX_dayXX_raweeg.mat'
% Step 2: Remove low frequency drifts 'subXX_dayXX_highpass.mat'
% Step 3: Epoch data 'subXX_dayXX_epoched.mat'

% File names
fName.folder                    = [p.saveEEG '/sub' p.subjID '/day' num2str(p.day,'%02d')];
if ~exist(fName.folder, 'dir')
    mkdir(fName.folder)
end
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
fName.TFR_induced               = [fName.general '_TFR_induced.mat'];
fName.TMS_TFR_induced           = [fName.general '_TMS_TFR_induced.mat'];
%% Concatenate EEG data
if any(strcmp(steps, 'concat'))
    if ~exist(fName.concat, 'file')
        disp('Concatenated file does not exist. Concatenating EEG data.')
        ConcatEEG(p, fName);
    else
        disp('Concatenated file exists. Skipping this step.')
    end
end

cfg = [];
cfg.hpfilter = 'yes';
cfg.hpfreq = 1;
cfg.dataset = fName.concat;
data_eeg_raw = ft_preprocessing(cfg);
cfg                           = [];
cfg.channel                   = setdiff(data_eeg_raw.label, {'LM', 'RM', 'TP9', 'TP10'});
data_eeg_raw                      = ft_selectdata(cfg, data_eeg_raw);

bad_chans = [];
var_mat = var(data_eeg_raw.trial{1}, [], 2);

cfg = [];
cfg.resamplefs = 200;
cfg.detrend = 'no';
data_eeg_resamp = ft_resampledata(cfg, data_eeg_raw);

cfg = []; cfg.method = 'fastica'; %cfg.numcomponent = 20;
comp = ft_componentanalysis(cfg, data_eeg_resamp);

figure
cfg = [];
cfg.component = 1:20;       
cfg.layout    = 'acticap-64_md.mat'; 
cfg.comment   = 'no';
ft_topoplotIC(cfg, comp)


cfg = [];
cfg.component = [1 8]; 
data_eeg_ica = ft_rejectcomponent(cfg, comp, data_eeg_raw);


cfg = []; cfg.viewmode = 'vertical'; cfg.ylim = [-100 100]; 
ft_databrowser(cfg, data_eeg_raw)
ft_databrowser(cfg, data_eeg_resamp)
ft_databrowser(cfg, data_eeg_resamp_ica)

%% Reading segmented data
% stim-locked:
%   'S 11': prointoVF
%   'S 12': prooutVF
%   'S 13': antiintoVF
%   'S 14': antioutVF
% fixation: 1s
% sample: 0.5s
% delay1: 2s
% delay2: 2s
% response: 0.85s
% feedback: 0.8s
% iti: 1/2s
if any(strcmp(steps, 'raweeg'))
    %if ~exist(fName.bandpass, 'file')
    % Reading segmented data
    disp('Reading segmented data.')
    cfg                           = [];
    cfg.dataset                   = fName.concat;
    cfg.trialdef.prestim          = 1.5;
    cfg.trialdef.poststim         = 5.5;
    cfg.trialdef.eventtype        = 'Stimulus';
    cfg.trialdef.eventvalue       = {'S 11', 'S 12', 'S 13', 'S 14'};
    cfg                           = ft_definetrial(cfg);
    cfg.continuous                = 'yes';
    cfg.bpfilter                  = 'yes';
    cfg.bpfreq                    = [0.5 50];
    data_eeg                      = ft_preprocessing(cfg);

    % Removing LM and RM electrodes which were not used and bad trials
    % with timing issues
    cfg                           = [];
    cfg.channel                   = setdiff(data_eeg.label, {'LM', 'RM'});
    data_eeg                      = ft_selectdata(cfg, data_eeg);
    %end
end

% cfg = []; cfg.preproc.demean = 'yes'; cfg.keeptrials = 'no';
% data_eeg_avg = ft_timelockanalysis(cfg, data_eeg);
% cfg = []; cfg.viewmode = 'vertical';
% ft_databrowser(cfg, data_eeg_avg);
%
% cfg                    = [];
% cfg.viewmode           = 'butterfly';
% %cfg.trl                = sampleinfo(union(find(data_tms.trialinfo ==11), find(data_tms.trialinfo == 12)), :);
% cfg.channel            = union(left_occ_elecs, right_occ_elecs);
% ft_databrowser(cfg, data_eeg);

% cfg = []; cfg.viewmode = 'vertical'; ft_databrowser(cfg, data_eeg)
% unrolled_data = data_eeg

flg_trls = [];

cfg                            = [];
cfg.reref                      = 'yes';
cfg.refchannel                 = {'TP9', 'TP10'};
cfg.refmethod                  = 'avg';
cfg.implicitref                = 'Cz';
data_eeg                       = ft_preprocessing(cfg, data_eeg);

% Select good trials for each epoched data type
cfg                            = [];
cfg.channel                    = 'all';
% good epoc prointoVF
prointoVF_trls                 = find(data_eeg.trialinfo == 11);
cfg.trials                     = setdiff(prointoVF_trls, flg_trls);
epoc_prointoVF                 = ft_selectdata(cfg, data_eeg);

% good epoc prooutVF
prooutVF_trls                  = find(data_eeg.trialinfo == 12);
cfg.trials                     = setdiff(prooutVF_trls, flg_trls);
epoc_prooutVF                  = ft_selectdata(cfg, data_eeg);

% good epoc antiintoVF
antiintoVF_trls                = find(data_eeg.trialinfo == 13);
cfg.trials                     = setdiff(antiintoVF_trls, flg_trls);
epoc_antiintoVF                = ft_selectdata(cfg, data_eeg);

% good epoc antioutVF
antioutVF_trls                 = find(data_eeg.trialinfo == 14);
cfg.trials                     = setdiff(antioutVF_trls, flg_trls);
epoc_antioutVF                 = ft_selectdata(cfg, data_eeg);

[ERP.prointoVF, ERP.prooutVF]                   = compute_ERPs(epoc_prointoVF, epoc_prooutVF);
[ERP.antiintoVF, ERP.antioutVF]                 = compute_ERPs(epoc_antiintoVF, epoc_antioutVF);

% cfg = [];
% cfg.channel = left_occ_elecs;
% cfg.figure = 'gcf';
% cfg.xlim = [0 4.5];
% figure();
% subplot(2, 2, 1)
% ft_singleplotER(cfg, ERP.prointoVF)
% subplot(2, 2, 2)
% ft_singleplotER(cfg, ERP.antiintoVF)
% subplot(2, 2, 3)
% ft_singleplotER(cfg, ERP.prooutVF)
% subplot(2, 2, 4)
% ft_singleplotER(cfg, ERP.antioutVF)

[POW.prointoVF, ITC.prointoVF, PHASE.prointoVF]          = compute_TFRs(epoc_prointoVF, 1);
[POW.prooutVF, ITC.prooutVF, PHASE.prooutVF]             = compute_TFRs(epoc_prooutVF, 1);
[POW.antiintoVF, ITC.antiintoVF, PHASE.antiintoVF]       = compute_TFRs(epoc_antiintoVF, 1);
[POW.antioutVF, ITC.antioutVF, PHASE.antioutVF]          = compute_TFRs(epoc_antioutVF, 1);


epoc_prointoVF_minus_ERP                                 = epoc_prointoVF;
for k = 1:numel(epoc_prointoVF.trial)
    epoc_prointoVF_minus_ERP.trial{k}                    = epoc_prointoVF.trial{k} - ERP.prointoVF.avg;
end
epoc_prooutVF_minus_ERP                                  = epoc_prooutVF;
for k = 1:numel(epoc_prooutVF.trial)
    epoc_prooutVF_minus_ERP.trial{k}                     = epoc_prooutVF.trial{k} - ERP.prooutVF.avg;
end
epoc_antiintoVF_minus_ERP                                = epoc_antiintoVF;
for k = 1:numel(epoc_antiintoVF.trial)
    epoc_antiintoVF_minus_ERP.trial{k}                   = epoc_antiintoVF.trial{k} - ERP.antiintoVF.avg;
end
epoc_antioutVF_minus_ERP                                 = epoc_antioutVF;
for k = 1:numel(epoc_antioutVF.trial)
    epoc_antioutVF_minus_ERP.trial{k}                    = epoc_antioutVF.trial{k} - ERP.antioutVF.avg;
end
[POW.prointoVF, ITC.prointoVF, PHASE.prointoVF]          = compute_TFRs(epoc_prointoVF_minus_ERP, 1);
[POW.prooutVF, ITC.prooutVF, PHASE.prooutVF]             = compute_TFRs(epoc_prooutVF_minus_ERP, 1);
[POW.antiintoVF, ITC.antiintoVF, PHASE.antiintoVF]       = compute_TFRs(epoc_antiintoVF_minus_ERP, 1);
[POW.antioutVF, ITC.antioutVF, PHASE.antioutVF]          = compute_TFRs(epoc_antioutVF_minus_ERP, 1);
%end