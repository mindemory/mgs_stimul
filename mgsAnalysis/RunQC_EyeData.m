function RunQC_EyeData(ii_sess, p, which_excl)
% Created by Mrugank (05/08/2023)
ii_cfg.hz = 1000; % This is a hard-coded hack. Ashamed of this, but well...
p.QCdir_fig = [p.save '/QC/fig'];
p.QCdir_png = [p.save '/QC/png'];

if ~exist(p.QCdir_fig, 'dir')
    mkdir(p.QCdir_fig);
end

if ~exist(p.QCdir_png, 'dir')
    mkdir(p.QCdir_png);
end

ii_sess_pro = struct;
ii_sess_anti = struct;

fieldnames_original = fieldnames(ii_sess);
idx_params = strcmp(fieldnames_original, 'params');
fieldnames_original(idx_params) = [];
for ii = 1:numel(fieldnames_original)
    this_field = fieldnames_original{ii};
    ii_sess_pro.(this_field) = ii_sess.(this_field)(ii_sess.ispro == 1, :);
    ii_sess_anti.(this_field) = ii_sess.(this_field)(ii_sess.ispro == 0, :);
end
ii_sess_pro.params = ii_sess.params;
ii_sess_anti.params = ii_sess.params;

%% Plot QC exclusions
disp('1. Plotting QC exclusions')
% sess pro
fh_excl_pro = ii_plotQC_exclusions(ii_sess_pro,[],which_excl,0, 1);
saveas(fh_excl_pro, [p.QCdir_png '/excl' num2str(1) '_pro_sub' p.subjID '_day' num2str(p.day, '%02d')], 'png');
saveas(fh_excl_pro, [p.QCdir_fig '/excl' num2str(1) '_pro_sub' p.subjID '_day' num2str(p.day, '%02d')], 'fig');

% sess anti
fh_excl_anti = ii_plotQC_exclusions(ii_sess_anti,[],which_excl,0, 1);
saveas(fh_excl_anti, [p.QCdir_png '/excl' num2str(1) '_anti_sub' p.subjID '_day' num2str(p.day, '%02d')], 'png');
saveas(fh_excl_anti, [p.QCdir_fig '/excl' num2str(1) '_anti_sub' p.subjID '_day' num2str(p.day, '%02d')], 'fig');

fh_excl = ii_plotQC_exclusions(ii_sess,[],which_excl,0, 2);
saveas(fh_excl, [p.QCdir_png '/excl' num2str(2) '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'png');
saveas(fh_excl, [p.QCdir_fig '/excl' num2str(2) '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'fig');


%% Plot QC all trials
disp('2. Plotting QC all trials')
fh_trial = ii_plotQC_alltrials(ii_sess,ii_cfg,[], 0);
for ff = 1:length(fh_trial)
    saveas(fh_trial(ff), [p.QCdir_png '/block' num2str(ff) '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'png');
    saveas(fh_trial(ff), [p.QCdir_fig '/block' num2str(ff) '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'fig');
end

% %% Create a reaction time graph
% use_trial = ~cellfun( @any, cellfun( @(a) ismember(a, which_excl), ii_sess.excl_trial, 'UniformOutput',false));
% 
% % plot RT histogram
% rt_fh = figure('Visible','off');
% histogram(ii_sess.i_sacc_rt(use_trial==1),10);
% title(['Analyzing ' num2str(round(mean(use_trial)*100, 2)) '% of trials']);
% xlabel('Response time (s)');
% xlim([0 0.7]);
% saveas(rt_fh, [p.QCdir_png '/RT_' sess_type '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'png');
% saveas(rt_fh, [p.QCdir_fig '/RT_' sess_type '_sub' p.subjID '_day' num2str(p.day, '%02d')], 'fig');


%% Traces for primary, final saccade for each block
%figure('Visible','off');
figure;
ru_pro = unique(ii_sess_pro.r_num); % get run #'s for pro blocks
ru_anti = unique(ii_sess_anti.r_num); % get run #'s for anti blocks
ru_num_total = length(ru_pro) + length(ru_anti); % total # of runs

for rr = 1:ru_num_total
    [p_check, p_idx] = ismember(rr, ru_pro);
    [a_check, a_idx] = ismember(rr, ru_anti);
    if p_check
        subplot(2, 5, p_idx);
    elseif a_check
        subplot(2, 5, 5+a_idx);
    end
    hold on;
    
    % only grab trials we'll use
    thisidx = find(ii_sess.r_num==ru_pro(rr));
    mycolors = lines(length(thisidx)); % color for each trial
    
    for tt = 1:length(thisidx)
        
        % plot trace(s) & endpoint(s)
        plot(ii_sess.i_sacc_trace{thisidx(tt)}(:,1),ii_sess.i_sacc_trace{thisidx(tt)}(:,2),'-','LineWidth',1.5,'Color',mycolors(tt,:));
        plot(ii_sess.i_sacc_raw(thisidx(tt),1),ii_sess.i_sacc_raw(thisidx(tt),2),'ko','MarkerFaceColor',mycolors(tt,:),'MarkerSize',5);
        if ~isempty(ii_sess.f_sacc_trace{thisidx(tt)})
            plot(ii_sess.f_sacc_trace{thisidx(tt)}(:,1),ii_sess.f_sacc_trace{thisidx(tt)}(:,2),'-','LineWidth',1.5,'Color',mycolors(tt,:));
            plot(ii_sess.f_sacc_raw(thisidx(tt),1),ii_sess.f_sacc_raw(thisidx(tt),2),'kd','MarkerFaceColor',mycolors(tt,:),'MarkerSize',5);
        end
        
        % plot target
        plot(ii_sess.targ(thisidx(tt),1),ii_sess.targ(thisidx(tt),2),'x','LineWidth',2,'MarkerSize',8,'Color',mycolors(tt,:));
    end
    plot(0,0,'ks','MarkerFaceColor','k','MarkerSize',5); % fixation point
    xlim([-15 15]); ylim([-15 15]);
    axis square off;
    title(['Block:' num2str(rr,'%02d')]);
end
end