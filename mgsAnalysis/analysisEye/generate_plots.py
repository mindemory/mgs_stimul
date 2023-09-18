import numpy as np
import pandas as pd
from scipy.stats import sem
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import gaussian_kde as gkde

msize = 10
axes_fontsize = 12
title_fontsize = 16
#sns.set()
def subject_wise_error_plot(df, error_measure, normalizer = False, indiv_summary = False, remove_outliers = False):
    TMSconds = ['No TMS', 'TMS intoVF', 'TMS outVF']
    subjIDs = df['subjID'].unique()
    Y1 = np.zeros((len(subjIDs), len(TMSconds)))
    Y2 = np.zeros((len(subjIDs), len(TMSconds)))
    Yerr1 = np.zeros((len(subjIDs), len(TMSconds)))
    Yerr2 = np.zeros((len(subjIDs), len(TMSconds)))

    for ss in range(len(subjIDs)):
        for ii in range(len(TMSconds)):
            this_prodf = df[(df['subjID'] == subjIDs[ss]) & 
                            (df['TMS_condition'] == TMSconds[ii]) &
                            ((df['ispro'] == 1))]
            this_antidf = df[(df['subjID'] == subjIDs[ss]) & 
                            (df['TMS_condition'] == TMSconds[ii]) &
                            ((df['ispro'] == 0))]
            
            # individualized normalizer is intended to detrend the data to make comparisons across subjects more meaningful
            if normalizer == 'individualized' or normalizer == 'both':
                this_df = df[(df['subjID'] == subjIDs[ss])]
                this_mean = np.nanmean(this_df[error_measure])
                this_prodf.loc[:, error_measure] -= this_mean
                this_antidf.loc[:, error_measure] -= this_mean

            # remove outliers for each subject for pro and anti for each condition that are 3 stdevs away from mean
            if remove_outliers == True:
                stdev_pro = np.nanstd(this_prodf[error_measure])
                stdev_anti = np.nanstd(this_antidf[error_measure])
                mean_pro = np.nanmean(this_prodf[error_measure])
                mean_anti = np.nanmean(this_antidf[error_measure])
                nstdevs = 2
                this_prodf = this_prodf[(this_prodf[error_measure] > mean_pro-nstdevs*stdev_pro) &
                                        (this_prodf[error_measure] < mean_pro+nstdevs*stdev_pro)]
                this_antidf = this_antidf[(this_antidf[error_measure] > mean_anti-nstdevs*stdev_anti) &
                                          (this_antidf[error_measure] < mean_anti+nstdevs*stdev_anti)]

            Y1[ss, ii] = np.nanmean(this_prodf[error_measure])
            Y2[ss, ii] = np.nanmean(this_antidf[error_measure])
            
            Yerr1[ss, ii] = sem(this_prodf[error_measure], nan_policy='omit')
            Yerr2[ss, ii] = sem(this_antidf[error_measure], nan_policy='omit')
        if normalizer == 'group_level' or normalizer == 'both':
            normalizer_val_pro = Y1[ss, 0]
            normalizer_val_anti = Y2[ss, 0]
            Y1[ss, :] = (Y1[ss, :] - normalizer_val_pro) / normalizer_val_pro + (normalizer_val_pro - normalizer_val_pro)
            Y2[ss, :] = (Y2[ss, :] - normalizer_val_anti) / normalizer_val_anti + (normalizer_val_anti - normalizer_val_pro)
            #Y1[ss, :] = np.abs(Y1[ss, :] - normalizer_val_pro) / normalizer_val_pro + (normalizer_val_pro - normalizer_val_pro)
            #Y2[ss, :] = np.abs(Y2[ss, :] - normalizer_val_anti) / normalizer_val_anti + (normalizer_val_anti - normalizer_val_pro)
    
    if error_measure == 'fsacc_err':
        t_string = 'Final saccade error'
    elif error_measure == 'isacc_err':
        t_string = 'Initial saccade error'
    elif error_measure == 'fsacc_rt':
        t_string = 'Final saccade reaction time'
    elif error_measure == 'isacc_rt':
        t_string = 'Initial saccade reaction time'
    elif error_measure == 'fsacc_radius_err':
        t_string = 'Final saccade radial error'
    elif error_measure == 'isacc_radius_err':
        t_string = 'Initial saccade radial error'
    elif error_measure == 'fsacc_theta_err':
        t_string = 'Final saccade angular error'
    elif error_measure == 'isacc_theta_err':
        t_string = 'Initial saccade angular error'
    elif error_measure == 'corrected_theta_err':
        t_string = 'Corrected angular error'
    elif error_measure == 'corrected_radius_err':
        t_string = 'Corrected radial error'
    if indiv_summary == True:
        if normalizer == 'individualized':
            t_string = t_string + ', normalizer = individualized'
        elif normalizer == 'group_level':
            t_string = t_string + ', normalizer = group-level'

        tiled_plot(df, Y1, Y2, Yerr1, Yerr2, error_measure, t_string)
    else:
        group_plot(df, Y1, Y2, error_measure, t_string)
    # LIMS_x = max(X2) + 0.2
    #LIMS_y = max(max(max(Y1)), max(max(Y2))) * 1.2
    # LIMS = [LIMS_x, LIMS_y]
    
    # fig = plt.figure(figsize = (7, 9))
    # if len(subjIDs) == 1:
    #     plt.title(subjIDs, fontsize = title_fontsize)
    # else:
    #     plt.title(error_measure +' across ' + str(len(subjIDs)) + ' subjects', fontsize = title_fontsize)
    # for ss in range(len(subjIDs)):
    #     plt.plot(X1, Y1[ss, :], color = ccols[0], linestyle = 'dashdot', label = '__no_legend', markersize = msize)
    #     plt.plot(X2, Y2[ss, :], color = wcols[0], linestyle = 'dashdot', label = '__no_legend', markersize = msize)
    
    # if len(subjIDs) < 3:
    #     plt.errorbar(X1, Y1[ss, :], yerr = Yerr1[ss, :], fmt = '.', ecolor = 'blue', markersize = msize, markerfacecolor = 'blue', markeredgecolor = 'blue', label = 'pro')
    #     plt.errorbar(X2, Y2[ss, :], yerr = Yerr2[ss, :], fmt = '.', ecolor = 'red', markersize = msize, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
    #     plt.plot(X1, np.mean(Y1, axis=0), marker = 's', color = 'blue', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    #     plt.plot(X2, np.mean(Y2, axis=0), marker = 's',  color = 'red', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    # else:
    #     plt.errorbar(X1, np.mean(Y1, axis=0), yerr=sem(Y1, axis=0), fmt = '.', ecolor = 'blue', markersize = msize, markerfacecolor = 'blue', markeredgecolor = 'blue', label = 'pro')
    #     plt.errorbar(X2, np.mean(Y2, axis=0), yerr=sem(Y2, axis=0), fmt = '.',  ecolor = 'red', markersize = msize, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
    #     plt.plot(X1, np.mean(Y1, axis=0), marker = 's', color = 'blue', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    #     plt.plot(X2, np.mean(Y2, axis=0), marker = 's',  color = 'red', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    # plt.xticks(x_tick_pos, x_label_names, fontsize = axes_fontsize)
    # plt.ylabel(error_measure, fontsize = axes_fontsize)
    # plt.legend()
    # plt.show()

def tiled_plot(df, Y1, Y2, Yerr1, Yerr2, error_measure, t_string = 'Title goes here'):
    X1 = [0.3, 0.8, 1.3]
    X2 = [round(x + 0.1, 1) for x in X1]
    X_sum = [sum(value) for value in zip(X1, X2)]
    x_tick_pos = [round(x/2, 1) for x in X_sum]
    x_label_names = ['No TMS', 'MGS inVF', 'MGS outVF']
    #x_label_names = ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF']
    # warm_colors = plt.get_cmap('OrRd')
    # cool_colors = plt.get_cmap('Blues')
    # wcols = warm_colors(np.linspace(0.3, 0.7, len(subjIDs)))
    # ccols = cool_colors(np.linspace(0.3, 0.7, len(subjIDs)))
    
    
    TMSconds = ['No TMS', 'TMS intoVF', 'TMS outVF']
    subjIDs = df['subjID'].unique()
    N1 = [1, 1, 2, 2, 2, 2, 2, 2, 3, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4] # num rows for tiled plot
    N2 = [1, 2, 2, 2, 3, 3, 4, 4, 3, 5, 4, 4, 5, 5, 5, 4, 5, 5, 5, 5] # num cols for tiled plot
    nrows = N1[len(subjIDs)-1]
    ncols = N2[len(subjIDs)-1]

    fig, axes = plt.subplots(nrows=nrows, ncols=ncols, figsize=(20, 20))
    max_y = max(np.nanmax(Y1+Yerr1), np.nanmax(Y2+Yerr2))
    min_y = min(np.nanmin(Y1-Yerr1), np.nanmin(Y2-Yerr2))
    print(min_y)
    for ss in range(len(subjIDs)):
        ax = axes[ss // ncols, ss % ncols]
        ax.errorbar(X1, Y1[ss, :], yerr = Yerr1[ss, :], fmt = '.', ecolor = 'blue', markersize = msize, markerfacecolor = 'blue', markeredgecolor = 'blue', label = 'pro')
        ax.errorbar(X2, Y2[ss, :], yerr = Yerr2[ss, :], fmt = '.', ecolor = 'red', markersize = msize, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
        ax.plot(X1, Y1[ss, :], marker = 'o', color = 'blue', linestyle = 'solid', markersize = msize, label = '__no_legend')
        ax.plot(X2, Y2[ss, :], marker = 'o',  color = 'red', linestyle = 'solid', markersize = msize, label = '__no_legend')
        ax.set_ylabel(error_measure, fontsize = axes_fontsize)
        ax.set_title('subjID: ' +  str(subjIDs[ss]), fontsize = axes_fontsize)
        ax.set_xticks(x_tick_pos, x_label_names, fontsize = axes_fontsize)
        if min_y > 0:
            ax.set_ylim(0.8*min_y, 1.2*max_y)
        else:
            ax.set_ylim(1.2*min_y, 1.2*max_y)
        #ax.set_aspect('equal')
    plt.tight_layout()
    
    plt.suptitle(t_string, fontsize = title_fontsize, y = 0, fontweight = 'bold')
    #plt.legend('Location', )
    plt.show()

def group_plot(df, Y1, Y2, error_measure, t_string = 'Title goes here'):
    X1 = [0.3, 0.8, 1.3]
    X2 = [round(x + 0.1, 1) for x in X1]
    X_sum = [sum(value) for value in zip(X1, X2)]
    x_tick_pos = [round(x/2, 1) for x in X_sum]
    x_label_names = ['No TMS', 'MGS inVF', 'MGS outVF']
    subjIDs = df['subjID'].unique()
    num_subs = len(subjIDs)
    t_string = t_string + ', #subs = ' + str(num_subs)
    Yerr1 = sem(Y1, axis=0)
    Yerr2 = sem(Y2, axis=0)
    min_y = min(np.nanmin(Y1-Yerr1), np.nanmin(Y2-Yerr2))
    
    max_y = max(np.nanmax(Y1+Yerr1), np.nanmax(Y2+Yerr2))
    fig = plt.figure(figsize = (5, 8))
    fig.patch.set_facecolor((33/255, 33/255, 33/255))
    ax = fig.add_subplot(111)
    ax.set_facecolor((33/255, 33/255, 33/255))
    ax.spines['bottom'].set_color('white')
    ax.spines['top'].set_color('white')
    ax.spines['left'].set_color('white')
    ax.spines['right'].set_color('white')
    ax.xaxis.label.set_color('white')
    ax.yaxis.label.set_color('white')
    ax.tick_params(axis='x', colors='white')
    ax.tick_params(axis='y', colors='white')

    #legend = ax.legend(handles=[line], labels=['Legend Label'], loc='upper right')
    
    ax.errorbar(X1, np.mean(Y1, axis=0), yerr=Yerr1, fmt = '.', ecolor = 'blue', markersize = msize, markerfacecolor = 'blue', markeredgecolor = 'blue', label = 'pro')
    ax.errorbar(X2, np.mean(Y2, axis=0), yerr=Yerr2, fmt = '.',  ecolor = 'red', markersize = msize, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
    ax.plot(X1, np.mean(Y1, axis=0), marker = 's', color = 'blue', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    ax.plot(X2, np.mean(Y2, axis=0), marker = 's',  color = 'red', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    ax.set_xticks(x_tick_pos, x_label_names, fontsize = axes_fontsize)
    ax.set_ylabel(error_measure, fontsize = axes_fontsize)
    ax.set_title(t_string, fontsize = title_fontsize, color='white')
    if min_y > 0:
        ax.set_ylim(0.8*min_y, 1.2*max_y)
    else:
        ax.set_ylim(1.2*min_y, 1.2*max_y)
    #plt.ylim([0, max_y])
    legend = ax.legend()
    legend.get_frame().set_facecolor((33 / 255, 33 / 255, 33 / 255))  # Set the legend box color

    for text in legend.get_texts():
        text.set_color('white')
    

    # plt.errorbar(X1, np.mean(Y1, axis=0), yerr=Yerr1, fmt = '.', ecolor = 'blue', markersize = msize, markerfacecolor = 'blue', markeredgecolor = 'blue', label = 'pro')
    # plt.errorbar(X2, np.mean(Y2, axis=0), yerr=Yerr2, fmt = '.',  ecolor = 'red', markersize = msize, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
    # plt.plot(X1, np.mean(Y1, axis=0), marker = 's', color = 'blue', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    # plt.plot(X2, np.mean(Y2, axis=0), marker = 's',  color = 'red', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    # plt.xticks(x_tick_pos, x_label_names, fontsize = axes_fontsize)
    # plt.ylabel(error_measure, fontsize = axes_fontsize)
    # plt.title(t_string, fontsize = title_fontsize)
    # if min_y > 0:
    #     plt.ylim(0.8*min_y, 1.2*max_y)
    # else:
    #     plt.ylim(1.2*min_y, 1.2*max_y)
    # #plt.ylim([0, max_y])
    # plt.legend()
    plt.show()

def quick_visualization(df):
    cols_to_plot = ['fsaccX', 'fsaccY', 'fsacc_err', 'fsacc_theta_err', 'fsacc_radius_err', 'calib_err', 'fsacc_rt', 'fsacc_theta_rot',
                    'fsacc_theta_rot_normed', 'fsacc_err_rot', 'fsacc_err_rot_normed', 'isacc_peakvel', 'fsacc_peakvel', 'TarRadius', 'TarRadius_rotated',
                    'TarTheta', 'TarTheta_rotated']
    # df['trial_type'].replace(['pro_intoVF', 'pro_outVF', 'anti_intoVF', 'anti_outVF'],
    #                          [0, 1, 2, 3], inplace=True)
    # df['TMS_condition'].replace(['No TMS', 'TMS intoVF', 'TMS outVF'],
    #                     [0, 1, 2], inplace=True) 
    pd.plotting.scatter_matrix(df[cols_to_plot], figsize = (25, 25), alpha = 0.8)
    plt.suptitle('Quick overview', fontsize = title_fontsize)
    plt.show()

    # Visualizing data in 2-d, kept out because not sure how it is doing it.
    # pd.plotting.radviz(df[cols_to_plot], 'TMS_condition')
    # plt.suptitle('Quick overview', fontsize = title_fontsize)
    # plt.show()
def distribution_plots(df):
    subjIDs = df['subjID'].unique()
    #df = df[df['fsacc_err']<4]
    errs_to_plot = ['fsacc_err', 'fsacc_theta_err', 'fsacc_theta_rot', 'fsacc_theta_rot_normed',
                    'fsacc_radius_err', 'fsacc_err_rot', 'fsacc_err_rot_normed', 'fsacc_rt', 'isacc_peakvel', 'fsacc_peakvel']
    n_rows = 2
    n_cols = 5
    alpha_val = 0.8
    #tmp_df = df[df['TMS_condition']=='No TMS']
    for ss in range(len(subjIDs)):
        subj_df =  df[df['subjID']==subjIDs[ss]]
        fig, axes = plt.subplots(n_rows, n_cols, figsize = (25, 10))
        plt.suptitle(subjIDs[ss])
        nbins = 50
        this_idx = 0
        for n1 in range(n_rows):
            for n2 in range(n_cols):
                this_err = errs_to_plot[this_idx]
                axes[n1, n2].hist(subj_df[subj_df['TMS_condition']=='No TMS'][this_err], alpha=alpha_val, label='No TMS', bins=nbins)
                axes[n1, n2].hist(subj_df[subj_df['TMS_condition']=='TMS intoVF'][this_err], alpha=alpha_val, label='TMS intoVF', bins=nbins)
                axes[n1, n2].hist(subj_df[subj_df['TMS_condition']=='TMS outVF'][this_err], alpha=alpha_val, label='TMS outVF', bins=nbins)
                axes[n1, n2].legend()
                axes[n1, n2].set_xlabel(this_err)
                this_idx += 1
        plt.show()

        fig2, axes = plt.subplots(n_rows, n_cols, figsize = (20, 10))
        plt.suptitle(subjIDs[ss])
        this_idx = 0
        for n1 in range(n_rows):
            for n2 in range(n_cols):
                this_err = errs_to_plot[this_idx]
                sns.violinplot(data = subj_df, x = 'TMS_condition', y=this_err, ax = axes[n1, n2], hue = 'ispro', split = 'inner')
                this_idx+=1
        plt.show()
        #sns.histplot(data=tmp_df, x=tmp_df['fsacc_err'], alpha = 0.5, label='No TMS')
        # sns.histplot(data=df, x=df[df['TMS_condition']=='TMS intoVF']['fsacc_err'], alpha = 0.5, label='TMS intoVF')
        # sns.histplot(data=df, x=df[df['TMS_condition']=='TMS outVF']['fsacc_err'], alpha = 0.5, label='TMS outVF')
        


        
        


