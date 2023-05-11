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

%% Load ii_sess files
tic
ii_sess_saveName = [p.save '/ii_sess_sub' p.subjID '_day' num2str(p.day, '%02d')];
ii_sess_saveName_mat = [ii_sess_saveName '.mat'];
if exist(ii_sess_saveName_mat, 'file') == 2
    disp('Loading existing ii_sess file.')
    load(ii_sess_saveName_mat);
else
    disp('ii_sess file does not exist. running ieye')
    ii_sess = RuniEye(p, taskMap, end_block);
    save(ii_sess_saveName,'ii_sess')
end


%% QC plots
% Run QC
which_excl = [20 22];
disp('Running QC')
RunQC_EyeData(ii_sess, p, which_excl);
toc
end