function createQC(ii_sess, p, which_excl, sess_type)
% Created by Mrugank (05/08/2023)
ii_cfg.hz = 1000;
p.QCdir_fig = [p.save '/QC/fig'];
p.QCdir_png = [p.save '/QC/png'];

if ~exist(p.QCdir_fig, 'dir')
    mkdir(p.QCdir_fig);
end

if ~exist(p.QCdir_png, 'dir')
    mkdir(p.QCdir_png);
end

% Plot QC exclusions
fh_excl = ii_plotQC_exclusions(ii_sess,[],which_excl,0);
for ff = 1:length(fh_excl)
    saveas(fh_excl(ff), [p.QCdir_png '/excl' num2str(ff) '_' sess_type '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'png');
    saveas(fh_excl(ff), [p.QCdir_fig '/excl' num2str(ff) '_' sess_type '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'fig');
end

% Plot QC all trials
fh_trial = ii_plotQC_alltrials(ii_sess,ii_cfg,[], 0);
for ff = 1:length(fh_trial)
    saveas(fh_trial(ff), [p.QCdir_png '/block' num2str(ff) '_' sess_type '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'png');
    saveas(fh_trial(ff), [p.QCdir_fig '/block' num2str(ff) '_' sess_type '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'fig');
end

% Create a reaction time graph
use_trial = ~cellfun( @any, cellfun( @(a) ismember(a, which_excl), ii_sess.excl_trial, 'UniformOutput',false));

% plot RT histogram
rt_fh = figure('Visible','off');
histogram(ii_sess.i_sacc_rt(use_trial==1),10);
title(['Analyzing ' num2str(round(mean(use_trial)*100, 2)) '% of trials']);
xlabel('Response time (s)');
xlim([0 0.7]);
saveas(rt_fh, [p.QCdir_png '/RT_' sess_type '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'png');
saveas(rt_fh, [p.QCdir_fig '/RT_' sess_type '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'fig');

end