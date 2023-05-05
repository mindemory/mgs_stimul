function A02_EyeAnalysis(subjID, day, end_block, prac_status)
% Created by Mrugank (04/09/2023) 
clearvars -except subjID day end_block prac_status;
close all; clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 3
    end_block = 10; % default number of blocks on any given day
end
if nargin < 4
    prac_status = 0; % default is no practice aka actual run
end
p.subjID = num2str(subjID, '%02d');
p.day = day;

% Initialize all the relevant paths
[p, taskMap] = initialization(p, 'eye', prac_status);

% Determine trial number of pro and anti trials for all blocks
for blurb = 1:length(taskMap)
    if strcmp(taskMap(blurb).condition, 'pro')
        if ~exist('protrialNum', 'var')
            protrialNum = (blurb-1)*40+1:blurb*40;
        else
            protrialNum = [protrialNum;(blurb-1)*40+1:blurb*40];
        end
    elseif strcmp(taskMap(blurb).condition, 'anti')
        if ~exist('antitrialNum', 'var')
            antitrialNum = (blurb-1)*40+1:blurb*40;
        else
            antitrialNum = [antitrialNum;(blurb-1)*40+1:blurb*40];
        end
    end
end

% convert the pro and anti trials into an array
protrialNum = reshape(protrialNum', [], 1);
antitrialNum = reshape(antitrialNum', [], 1);

%% Load ii_sess files
tic
saveNamepro = [p.save '/ii_sess_pro_sub' p.subjID '_day' num2str(p.day, '%02d')];
saveNameanti = [p.save '/ii_sess_anti_sub' p.subjID '_day' num2str(p.day, '%02d')];
saveNamepromat = [saveNamepro '.mat'];
saveNameantimat = [saveNameanti '.mat'];
if exist(saveNamepromat, 'file') == 2 && exist(saveNameantimat, 'file') == 2
    disp('Loading existing ii_sess files.')
    load(saveNamepromat);
    load(saveNameantimat);
else
    disp('ii_sess files do not exist. running ieye')
    [ii_sess_pro, ii_sess_anti] = RuniEye(p, taskMap, end_block);
    save(saveNamepro,'ii_sess_pro')
    save(saveNameanti,'ii_sess_anti')
end

%% QC plots
% Check for how many excl flags
fh_excl = ii_plotQC_exclusions(ii_sess,ii_cfg);
which_excl = [20 22];
use_trial = ~cellfun( @any, cellfun( @(a) ismember(a, which_excl), ii_sess_pro.excl_trial, 'UniformOutput',false));

% check RT
use_trial(ii_sess_pro.i_sacc_rt < 0.1) = 0;

% see how many trials we're keeping
fprintf('Analyzing %0.03f%% of trials\n',mean(use_trial)*100);

% FIRST: plot RT histogram
figure;
histogram(ii_sess_pro.i_sacc_rt,10);
xlabel('Response time (s)');
xlim([0 0.7]); % 700 ms is longest allowed RT
toc