function A05_BatchTFStats()
clearvars; close all; clc;
warning('off', 'all');

subs =  [1 3 5 6 7 8 12 24]; %[1 3 5 6 7 8 12 13 14 15 16 17 18 22 23 24];
days = [1, 2, 3];

NT_IVF = cell(1, length(subs));
%NT_OVF = cell(1, length(subs));
T_IVF = cell(1, length(subs));
%T_OVF = cell(1, length(subs));

allsubs_dir = '/datc/MD_TMS_EEG/EEGfiles/allsubs/';
grand_nt_ivf = [allsubs_dir 'grand_nt_ivf.mat'];
grand_nt_ovf = [allsubs_dir 'grand_nt_ovf.mat'];
grand_t_ivf = [allsubs_dir 'grand_t_ivf.mat'];
grand_t_ovf = [allsubs_dir 'grand_t_ovf.mat'];

if ~exist(grand_nt_ivf, 'file') || ~exist(grand_nt_ovf, 'file') || ~exist(grand_t_ivf, 'file') || ...
    ~exist(grand_t_ovf, 'file')
    for subjID = subs
        s_idx = find(subs == subjID);
        temp_T_IVF = struct;
        temp_T_OVF = struct;
        disp(['Running subj = ' num2str(subjID, '%02d')])
        for day = days
            p.subjID = num2str(subjID,'%02d');
            p.day = day;
    
            [p, taskMap] = initialization(p, 'eeg', 0);
            p.figure = [p.datc '/Figures/eeg_analysis'];
            meta_data = readtable([p.analysis '/EEG_TMS_meta - Summary.csv']);
            HemiStimulated = table2cell(meta_data(:, ["HemisphereStimulated"]));
            this_hemisphere = HemiStimulated{subjID};
            NoTMSDays = table2array(meta_data(:, ["NoTMSDay"]));
    
            % File names
            fName.folder = [p.saveEEG '/sub' num2str(p.subjID, '%02d') '/day' num2str(p.day, '%02d')];
            if ~exist(fName.folder, 'dir')
                mkdir(fName.folder)
            end
            fName.general = [fName.folder '/sub' num2str(p.subjID, '%02d') '_day' num2str(p.day, '%02d')];
            fName.load = [fName.general '_raweeg.mat'];
            fName.interp = [fName.general '_interpolated.mat'];
            fName.bandpass = [fName.general '_bandpass.mat'];
            fName.bandpass_TMS = [fName.general '_bandpass_TMS.mat'];
            fName.freqmat_prointoVF = [fName.general '_freqmat_prointoVF.mat'];
            fName.freqmat_prooutVF = [fName.general '_freqmat_prooutVF.mat'];
            fName.freqmat_antiintoVF = [fName.general '_freqmat_antiintoVF.mat'];
            fName.freqmat_antioutVF = [fName.general '_freqmat_antioutVF.mat'];
            fName.freqmat_ipsi_pro = [fName.general '_freqmat_ipsi_pro.mat'];
            fName.freqmat_ipsi_anti = [fName.general '_freqmat_ipsi_anti.mat'];
            fName.freqmat_contra_pro = [fName.general '_freqmat_contra_pro.mat'];
            fName.freqmat_contra_anti = [fName.general '_freqmat_contra_anti.mat'];
            fName.freqmat_prointoVF_normalized = [fName.general '_freqmat_prointoVF_normalized.mat'];

            
            load(fName.freqmat_prointoVF);
            load(fName.freqmat_prooutVF);
            
            if isfield(freqmat_prointoVF, 'elec')
                freqmat_prointoVF = rmfield(freqmat_prointoVF, 'elec');
            end
            if isfield(freqmat_prooutVF, 'elec')
                freqmat_prooutVF = rmfield(freqmat_prooutVF, 'elec');
            end

            cfg = [];
            cfg.operation = '(x1)/(x1+x2)';
            cfg.parameter = 'powspctrm';
            freqmat_prointoVF = ft_math(cfg, freqmat_prointoVF, freqmat_prooutVF);
            freqmat_prooutVF = ft_math(cfg, freqmat_prooutVF, freqmat_prointoVF);
            %load(fName.freqmat_prooutVF);
            if strcmp(this_hemisphere, 'Right')
                electrode_labels = freqmat_prointoVF.label;
                modified_labels = cell(size(electrode_labels));
                pattern = '(\D+)(\d+)$';
                
                for i = 1:numel(electrode_labels)
                    label = electrode_labels{i};
                    [tokens, matches] = regexp(label, pattern, 'tokens', 'match');
                    
                    if ~isempty(matches)
                        electrode_name = tokens{1}{1};
                        electrode_num = str2double(tokens{1}{2});
                        
                        if mod(electrode_num, 2) == 0
                            % If the number is even, subtract 1
                            new_electrode_num = electrode_num - 1;
                        else
                            % If the number is odd, add 1
                            new_electrode_num = electrode_num + 1;
                        end
                        % Construct the new electrode label
                        modified_labels{i} = [electrode_name, num2str(new_electrode_num)];
                    else
                        % No match found, leave the label unchanged
                        modified_labels{i} = label;
                    end
                end
                freqmat_prointoVF.label = modified_labels;
                freqmat_prooutVF.label = modified_labels;
            end
            
            if p.day == NoTMSDays(subjID)
                NT_IVF{s_idx} = freqmat_prointoVF;
                NT_OVF{s_idx} = freqmat_prooutVF;
            else
                if ~isfield(temp_T_IVF, 'f')
                    temp_T_IVF.f(1) = freqmat_prointoVF;
                    temp_T_OVF.f(1) = freqmat_prooutVF;
                else
                    temp_T_IVF.f(2) = freqmat_prointoVF;
                    temp_T_OVF.f(2) = freqmat_prooutVF;
                end
            end
        end
        cfg = []; cfg.keepindividual = 'no';
        T_IVF{s_idx} = ft_freqgrandaverage(cfg, temp_T_IVF.f(1), temp_T_IVF.f(2));
        T_OVF{s_idx} = ft_freqgrandaverage(cfg, temp_T_OVF.f(1), temp_T_OVF.f(2));
    end
    
    cfg = [];
    cfg.keepindividual = 'yes';
    grand_NT_IVF = ft_freqgrandaverage(cfg, NT_IVF{:});
    grand_NT_OVF = ft_freqgrandaverage(cfg, NT_OVF{:});
    grand_T_IVF = ft_freqgrandaverage(cfg, T_IVF{:});
    grand_T_OVF = ft_freqgrandaverage(cfg, T_OVF{:});

    save(grand_nt_ivf, 'grand_NT_IVF', '-v7.3');
    save(grand_nt_ovf, 'grand_NT_OVF', '-v7.3');
    save(grand_t_ivf, 'grand_T_IVF', '-v7.3');
    save(grand_t_ovf, 'grand_T_OVF', '-v7.3');
else
    p.subjID = '01';
    p.day = 1;
    [p, taskMap] = initialization(p, 'eeg', 0);
    load(grand_nt_ivf);
    load(grand_nt_ovf);
    load(grand_t_ivf);
    load(grand_t_ovf);
end
left_occ_elecs = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
right_occ_elecs = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};
occ_elecs = cat(2, left_occ_elecs, right_occ_elecs);

cfg = [];
cfg.method = 'triangulation';
cfg.compress = 'yes';
cfg.layout = 'acticap-64_md.mat';
cfg.feedback = 'yes';
neighbors = ft_prepare_neighbours(cfg, grand_NT_IVF);
% cfg = [];
% cfg.method = 'distance';
% cfg.compress = 'yes';
% cfg.layout = 'acticap-64_md.mat';
% cfg.neighbourdist = 0.0615*5;
% %cfg.projection = 'polar';
% cfg.feedback = 'yes';
% neighbors = ft_prepare_neighbours(cfg, grand_NT_IVF);

cfg = [];
cfg.channel = grand_NT_IVF.label; %occ_elecs;
%cfg.avgoverchan = 'yes';
cfg.latency = [0.5 2];
cfg.frequency = [8 12];
cfg.avgoverfreq = 'yes';
cfg.avgovertime = 'yes';

cfg.method = 'montecarlo';
cfg.statistic = 'ft_statfun_depsamplesT';
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;
% cfg.minnbchan = 'maxsum';
cfg.tail = 0;
cfg.clustertail = 0;
cfg.alpha = 0.05;
cfg.numrandomization = 'all';
cfg.neighbours = neighbors;
nsubs = length(subs);
design = zeros(2, nsubs);
for i = 1:nsubs
    design(1, i) = i;
end
for i = 1:nsubs
    design(1, nsubs+i) = i;
end
design(2, 1:nsubs) = 1;
design(2, nsubs+1:2*nsubs) = 2;
cfg.design = design;
cfg.uvar = 1;
cfg.ivar = 2;
[stat] = ft_freqstatistics(cfg, grand_NT_IVF, grand_NT_OVF);

cfg = [];
cfg.channel = grand_NT_IVF.label;
cfg.latency     = [0.5 1.5]; 
cfg.frequency   = [8 12];
cfg.avgovertime = 'yes';
cfg.avgoverfreq = 'yes';
cfg.parameter   = 'powspctrm';
cfg.method  = 'analytic';
cfg.correctm = 'no';
cfg.statistic = 'ft_statfun_depsamplesT';
design = zeros(2, nsubs);
for i = 1:nsubs
    design(1, i) = i;
end
for i = 1:nsubs
    design(1, nsubs+i) = i;
end
design(2, 1:nsubs) = 1;
design(2, nsubs+1:2*nsubs) = 2;
cfg.design = design;
cfg.uvar = 1;
cfg.ivar = 2;
[stat] = ft_freqstatistics(cfg, grand_NT_IVF, grand_NT_OVF);

cfg = [];
cfg.alpha = 0.05;
cfg.parameter = 'stat';
%cfg.avgovertime = 'yes';
cfg.layout = 'acticap-64_md.mat';
ft_clusterplot(cfg, stat);


time = [0.5 2];
f_band = [8 12];
timesel_IVF = find(grand_NT_IVF.time >= time(1) & grand_NT_IVF.time <= time(2));
freqsel_IVF = find(grand_NT_IVF.freq >= f_band(1) & grand_NT_IVF.freq <= f_band(2));

%timesel_OVF  = find(grand_NT_OVF.time >= time(1) & grand_NT_OVF.time <= time(2));
nsubs = size(grand_NT_IVF.powspctrm, 1);
nchans = size(grand_NT_IVF.powspctrm, 2);
%OVFminIVF = zeros(1,nsubs);
h = zeros(1,nchans);
p = zeros(1,nchans);
%stat_val= zeros(1,nchans);
for iChan = 1:nchans
    %grand_NT_IVF.powspctrm(:,iChan,freqsel_IVF,timesel_IVF)
    %for isub = 1:nsubs%len(subs)
        OVFminIVF = ...
            mean(grand_NT_IVF.powspctrm(:,iChan,freqsel_IVF,timesel_IVF), [3 4], 'omitnan');
    %end

    [h(iChan), p(iChan), ] = ttest(OVFminIVF, 0, 'alpha', 0.02 , 'tail', 'both'); % test each channel separately
end


cfg = []; cfg.layout = 'acticap-64_md.mat'; cfg.figure = 'gcf';
cfg.ylim = [8 12]; 
cfg.highlight = 'on'; 
cfg.highlightsymbol = 's'; cfg.highlightsize = 8;
cfg.colorbar = 'yes'; cfg.comment = 'no'; 
cfg.colormap = '*RdBu'; cfg.marker = 'on';
%cfg.zlim = [min_pow max_pow];
%cfg.zlim = [0 1];
cfg.interpolatenan = 'no';

cfg.highlightchannel =  find(h);
cfg.xlim = [0.5 2];
ft_topoplotTFR(cfg, grand_NT_IVF)



cfg = []; cfg.layout = 'acticap-64_md.mat'; cfg.figure = 'gcf';
cfg.ylim = [8 12]; 
cfg.highlight = 'off'; 
cfg.highlightsymbol = 's'; cfg.highlightsize = 8;
cfg.colorbar = 'yes'; cfg.comment = 'no'; 
cfg.colormap = '*RdBu'; cfg.marker = 'on';
%cfg.zlim = [min_pow max_pow];
%cfg.zlim = [0 1];
cfg.interpolatenan = 'no';

%cfg.highlightchannel =  find(h);
cfg.xlim = [0.5 2];
ft_topoplotTFR(cfg, freqmat_prointoVF)