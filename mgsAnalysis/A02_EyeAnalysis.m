clear; close all; clc;

%% Initialization
p.subjID = '01';
p.day = 1;
end_block = 12;
[p, taskMap] = initialization(p, 'eye');

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
    [ii_sess_pro, ii_sess_anti] = I01_run_iEye(p, taskMap, end_block);
    save(saveNamepro,'ii_sess_pro')
    save(saveNameanti,'ii_sess_anti')
end
toc

% %% Run EEG preprocessing
% prointoVF_idx = find(ii_sess_pro.stimVF == 1);
% prooutVF_idx = find(ii_sess_pro.stimVF == 0);
% antiintoVF_idx = find(ii_sess_anti.stimVF == 0);
% antioutVF_idx = find(ii_sess_anti.stimVF == 1);
% prointoVF_idx_EEG = protrialNum(prointoVF_idx);
% prooutVF_idx_EEG = protrialNum(prooutVF_idx);
% antiintoVF_idx_EEG = antitrialNum(antiintoVF_idx);
% antioutVF_idx_EEG = antitrialNum(antioutVF_idx);

% saccloc = 1 refers to stimulus in VF


% anti_real = [];
% pro_real = [];
% for ii = 1:5
%     anti_real = [anti_real, real_error_dict.block_anti(ii).fsacc_theta'];
%     pro_real = [pro_real, real_error_dict.block_pro(ii).fsacc_theta'];
% end
% anti_real = anti_real';
% pro_real = pro_real';
% figure();
% plot(ii_sess_anti.f_sacc_err, anti_real, 'ro-')
% figure();
% plot(ii_sess_pro.f_sacc_err, pro_real, 'ko-')
% 
% anti_real = [];
% pro_real = [];
% for ii = 1:5
%     anti_real = [anti_real, real_error_dict.block_anti(ii).fsacc_r'];
%     pro_real = [pro_real, real_error_dict.block_pro(ii).fsacc_r'];
% end
% anti_real = anti_real';
% pro_real = pro_real';
% figure();
% plot(ii_sess_anti.f_sacc_err, anti_real, 'ro-')
% figure();
% plot(ii_sess_pro.f_sacc_err, pro_real, 'ko-')
% 
% 
% anti_real = [];
% pro_real = [];
% for ii = 1:5
%     anti_real = [anti_real, real_error_dict.block_anti(ii).isacc_theta'];
%     pro_real = [pro_real, real_error_dict.block_pro(ii).isacc_theta'];
% end
% anti_real = anti_real';
% pro_real = pro_real';
% figure();
% plot(ii_sess_anti.i_sacc_err, anti_real, 'ro-')
% figure();
% plot(ii_sess_pro.i_sacc_err, pro_real, 'ko-')