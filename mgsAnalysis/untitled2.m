d% function concatRuns()

%% set parameters
%%% data parameters
params.task = 'mgps';
params.subject = 'cc';
params.session = '2';
params.addExt = 'TMS_tLockCue_kpTrials_new_noDeMean';
params.runSet = {'s1s1loc1_pro' , 's1s1loc1_run03_proi','s1s1loc1_run05_proi'};%{'s1s1loc1_pro' , 's1s1loc1_run03_proi' , 's1s1loc1_run05_proi'};
%%% plot parameters
params.plotTFR.cfg = [];
params.plotTFR.cfg.layout = 'easycapM11.mat';
params.plotTFR.cfg.parameter = 'powspctrm';
params.plotTFR.cfg.baselinetype = 'absolute';
params.plotTFR.cfg.baseline = [-.4 -.2]; 
params.plotTFR.cfg.xlim = [0.130 .420];
params.plotTFR.cfg.ylim = [8 12];
% params.plotTFR.cfg.zlim = [-2e+4 2e+4];

%%% preprocessing parameters
params.prpr.cfg.demean = 'no';
params.prpr.cfg.baselinewindo = [-.5 -.2];
params.prpr.cfg.bpfilter = 'yes';
params.prpr.cfg.bpfreq = [8 35];
params.scoreData = 'no';

%% preprocessing

taskMap_all = [];
for runInd = 1:length(params.runSet)
    
    runID = params.runSet{runInd};
    InputFiles.eegFile = ['/Volumes/hyper/experiments/Masih/TMS/VisualCortex-grant/codes/Analysis/Ver00/RawData/' runID '.eeg'];
    InputFiles.taskMap = ['/Volumes/hyper/experiments/Masih/TMS/VisualCortex-grant/codes/Analysis/Ver00/RawData/' runID '.mat'];
    
    [data_allRuns{runInd},TM] = pipeLine_FieldTrip_TFR_seg(InputFiles,params);
    taskMap_all = [taskMap_all, TM];
end
trialInfo = getTrialInfo(taskMap_all);

cfg = [];
data_tLock = ft_appenddata(cfg, data_allRuns{1}, data_allRuns{2}, data_allRuns{3});

TFR.data.tLock = data_tLock;
TFR.trialInfo = trialInfo;

saveName = ['TFR_' params.subject '_sess' params.session '_' params.task '_' params.addExt];
save(saveName,'TFR','-v7.3')

inds_stimLVF = trialInfo.stimLoc.LVF;
inds_stimRVF = trialInfo.stimLoc.RVF;
inds_saccLVF = trialInfo.saccLoc.LVF;
inds_saccRVF = trialInfo.saccLoc.RVF;

%% run TFR

cfg              = [];
cfg.output       = 'pow'; 
cfg.channel      = 'all';
cfg.method       = 'wavelet';
cfg.taper        = 'hanning';
cfg.keeptrials = 'yes';
cfg.toi          = [-.5 : 0.05 : 4.5];
cfg.foilim       = [8 35];
% cfg.t_ftimwin    = ones(size(cfg.foi)) * 0.5;
 
cfg.trials = inds_stimLVF;
TFR.data.stimLVF = ft_freqanalysis(cfg, data_tLock);
 
cfg.trials = inds_stimRVF;
TFR.data.stimRVF = ft_freqanalysis(cfg, data_tLock);

% if strcmp(params.task , 'mgas')
%     cfg.trials = inds_saccLVF;
%     TFR.data.saccLVF = ft_freqanalysis(cfg, data_tLock);
%     
%     cfg.trials = inds_saccRVF;
%     TFR.data.saccRVF = ft_freqanalysis(cfg, data_tLock);
% end
    
save(saveName,'TFR','-v7.3')

%% plot single channels
% load('saveName');

clear cfg 
cfg = params.plotTFR.cfg;
cfg.colorbar = 'yes';
% cfg.xlim = [0 .3];
% cfg.ylim = [9 11];
% cfg.zlim = [0 1e+4];
cfg.marker = 'labels';        

%%%%%%%%%%%%%%%%%%%%%%% Stim LVF & Stim RVF
% cfg.channel = TFR.data.stimLVF.label;
% cfg.channel(17:18) = [];
% cfg.zlim         = [-.5e+4 .5e+4];
% Fig = figure;
% Fig.Name = 'Stim LVF';
% ft_topoplotTFR(cfg, TFR.data.stimLVF);


cfg.channel = TFR.data.stimLVF.label;
cfg.channel(17:18) = [];
cfg.zlim         = [-.5e+4 .5e+4];
Fig = figure;
Fig.Name = 'Stim RVF';
ft_topoplotTFR(cfg, TFR.data.stimRVF);

%%%%%%%%%%%%%%%%%%%%%%% (stimLVF - stimRVF) 
% cfg = [];
cfg.operation = 'subtract';
cfg.parameter = 'powspctrm';
cfg.zlim         = [-1e+4 1e+4];
difference = ft_math(cfg, TFR.data.stimLVF, TFR.data.stimRVF);

cfg.channel = TFR.data.stimLVF.label;
cfg.channel(17:18) = [];


Fig = figure;
Fig.Name = 'stimLVF - stimRVF';
ft_topoplotTFR(cfg, difference);


%% average accross channels

clear cfg;
cfg = params.plotTFR.cfg;
cfg.xlim = [-4.5 .5]
cfg.marker       = 'labels';	        
cfg.avgoverchan = 'yes';
% cfg.zlim         = [-3e+4 .6e+4];
%%%%%%%%%%%%%%%%%%%%%%% L&R hemispheres
cfg.channel = {'P1','P3','P5','P7','PO3','PO7'};
Fig = figure;
Fig.Name = 'Left Hemisphere';
subplot(2,1,1);ft_singleplotTFR(cfg,TFR.data.stimLVF);pbaspect([1 1 1]); ylabel(['Stim In LVF']);%h = colorbar;
subplot(2,1,2);ft_singleplotTFR(cfg,TFR.data.stimRVF);pbaspect([1 1 1]);ylabel(['Stim In RVF']);%caxis(h.Limits)

cfg.channel = {'P2','P4','P6','P8','PO4','PO8'};
Fig = figure;
Fig.Name = 'Right Hemisphere';
subplot(2,1,1);ft_singleplotTFR(cfg,TFR.data.stimLVF);pbaspect([1 1 1]); ylabel(['Stim In LVF']);%h = colorbar;
subplot(2,1,2);ft_singleplotTFR(cfg,TFR.data.stimRVF);pbaspect([1 1 1]);ylabel(['Stim In RVF']);%caxis(h.Limits)

%%%%%%%%%%%%%%%%%%%%%%% (stimLVF - stimRVF) 
cfg.operation = 'subtract';
cfg.parameter = 'powspctrm';
cfg.zlim         = [-2e+4 .4e+4];
difference = ft_math(cfg, TFR.data.stimLVF, TFR.data.stimRVF);

Fig = figure;
Fig.Name = 'stimLVF - stimRVF';

cfg.channel = {'P1','P3','P5','P7','PO3','PO7'};
subplot(1,2,1);ft_singleplotTFR(cfg,difference);pbaspect([1 1 1]); ylabel(['Left Hemispher']);%h = colorbar;

cfg.channel = {'P2','P4','P6','P8','PO4','PO8'};
subplot(1,2,2);ft_singleplotTFR(cfg,difference);pbaspect([1 1 1]); ylabel(['Right Hemispher']);%h = colorbar;
