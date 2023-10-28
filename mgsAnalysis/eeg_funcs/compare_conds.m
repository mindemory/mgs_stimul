function compare_conds(TFR, tidx, fidx, bl_type)

% left_elecs                                                   = {'O1', 'PO3', 'PO7', 'P1', 'P3', 'P5', 'P7'};
% right_elecs                                                  = {'O2', 'PO4', 'PO8', 'P2', 'P4', 'P6', 'P8'};

conditions                                                   = {'NT', 'T'};
t_types                                                      = {[bl_type 'in'], [bl_type 'out']};
stim_types                                                   = {'ipsi', 'contra'};

max_values                                                   = [];
min_values                                                   = [];

for i                                                        = 1:length(conditions)
    condition                                                = conditions{i};
    for k                                                    = 1:length(stim_types)
        stim_type                                            = stim_types{k};
        if strcmp(condition, 'NT')
            temp_pow                                         = TFR.(condition).(t_types{1}).(stim_type).powspctrm;
            this_pow                                         = reshape(squeeze(temp_pow), [1, size(temp_pow, 3), size(temp_pow, 4)]);
            TFR.(condition).(t_types{1}).(stim_type).label            = {'lol'};
            TFR.(condition).(t_types{1}).(stim_type).dimord           = 'chan_freq_time';
            TFR.(condition).(t_types{1}).(stim_type).powspctrm        = this_pow;
            max_values                                       = [max_values, max(this_pow(:, fidx, tidx), [], 'all', 'omitnan')];
            min_values                                       = [min_values, min(this_pow(:, fidx, tidx), [], 'all', 'omitnan')];
        else
            for j                                            = 1:length(t_types)
                t_type                                       = t_types{j};
                stim_type                                    = stim_types{k};
                temp_pow                                     = TFR.(condition).(t_type).(stim_type).powspctrm;
                this_pow                                     = reshape(squeeze(temp_pow), [1, size(temp_pow, 3), size(temp_pow, 4)]);

                TFR.(condition).(t_type).(stim_type).label   = {'lol'};
                TFR.(condition).(t_type).(stim_type).dimord  = 'chan_freq_time';
                TFR.(condition).(t_type).(stim_type).powspctrm   = this_pow;
                max_values                                   = [max_values, max(this_pow(:, fidx, tidx), [], 'all', 'omitnan')];
                min_values                                   = [min_values, min(this_pow(:, fidx, tidx), [], 'all', 'omitnan')];
            end
        end
    end
end


% Calculate the overall maximum and minimum values
max_pow                                                      = max(max_values);
min_pow                                                      = min(min_values);

%% Compute TFR differences
% Create figure
figure('Renderer', 'painters', 'Position', [0 1000 1600 800])
cfg                                              = [];
cfg.operation                                    = '(10^(x1/10) - 10^(x2/10)) / (10^(x1/10) + 10^(x2/10))';
cfg.parameter                                    = 'powspctrm';
TFRcontrast.NT                                   = ft_math(cfg, TFR.NT.(t_types{1}).contra, TFR.NT.(t_types{1}).ipsi);
TFRcontrast.T.(t_types{1})                       = ft_math(cfg, TFR.T.(t_types{1}).contra, TFR.T.(t_types{1}).ipsi);
TFRcontrast.T.(t_types{2})                       = ft_math(cfg, TFR.T.(t_types{2}).contra, TFR.T.(t_types{2}).ipsi);


cfg                                              = [];
cfg.figure                                       = 'gcf';
% cfg.channel                                      = left_elecs;
cfg.ylim                                         = [5 50];
cfg.xlim                                         = [-0.5 5];
cfg.colormap                                     = 'parula'; 

cfg.colorbartext                                 = 'ALI (dB)';
subplot(3, 3, 3)
ft_singleplotTFR(cfg, TFRcontrast.NT)
xlabel('Time (s)')
ylabel('Frequency (Hz)')
subplot(3, 3, 6)
ft_singleplotTFR(cfg, TFRcontrast.T.(t_types{1}))
xlabel('Time (s)')
ylabel('Frequency (Hz)')
subplot(3, 3, 9)
ft_singleplotTFR(cfg, TFRcontrast.T.(t_types{2}))
xlabel('Time (s)')
ylabel('Frequency (Hz)')

cfg.zlim                                         = [min_pow max_pow];
cfg.colorbartext                                 = 'ERSP (dB)';
subplot(3, 3, 1)
ft_singleplotTFR(cfg, TFR.NT.(t_types{1}).ipsi);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
subplot(3, 3, 2)
ft_singleplotTFR(cfg, TFR.NT.(t_types{1}).contra);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
subplot(3, 3, 4)
ft_singleplotTFR(cfg, TFR.T.(t_types{1}).ipsi);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
subplot(3, 3, 5)
ft_singleplotTFR(cfg, TFR.T.(t_types{1}).contra);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
subplot(3, 3, 7)
ft_singleplotTFR(cfg, TFR.T.(t_types{2}).ipsi);
xlabel('Time (s)')
ylabel('Frequency (Hz)')
subplot(3, 3, 8)
ft_singleplotTFR(cfg, TFR.T.(t_types{2}).contra);
xlabel('Time (s)')
ylabel('Frequency (Hz)')




% cfg = [];
% cfg.figure = 'gcf';
% cfg.xlim = [0.5, 4.5];
% cfg.ylim = [5, 35];
% cfg.zlim = [min_pow, max_pow];
% cfg.colormap = '*RdBu';
% cfg.fontsize = 13;
% subplot(2, 2, 1)
% cfg.title = 'contra (left)';
% ft_singleplotTFR(cfg, NoTMS_intoVF_contra)
%
% subplot(2, 2, 2)
% cfg.title = 'ipsi (right)';
% ft_singleplotTFR(cfg, NoTMS_intoVF_ipsi)
%
% subplot(2, 2, 3)
% cfg.title = 'contra (left)';
% ft_singleplotTFR(cfg, TMS_intoVF_contra)
%
% subplot(2, 2, 4)
% cfg.title = 'ipsi (right)';
% ft_singleplotTFR(cfg, TMS_intoVF_ipsi)

end