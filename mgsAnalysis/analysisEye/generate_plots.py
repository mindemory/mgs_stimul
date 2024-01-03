import numpy as np
import pandas as pd
from scipy.stats import sem
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import gaussian_kde as gkde

from helpers import compute_errors, compute_tcount

msize = 10
axes_fontsize = 14
title_fontsize = 18
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
    ['igain', 'fgain', 'ipea', 
                    'fpea', 'itheta', 'iamp', 'idir', 'ftheta', 'famp', 'fdir', 'isacc_peakvel', 'fsacc_peakvel']
    if error_measure == 'fsacc_err' or error_measure == 'ferr':
        t_string = 'Final saccade error'
    elif error_measure == 'isacc_err' or error_measure == 'ierr':
        t_string = 'Initial saccade error'
    elif error_measure == 'fsacc_rt':
        t_string = 'Final saccade reaction time'
    elif error_measure == 'isacc_rt':
        t_string = 'Initial saccade reaction time'
    elif error_measure == 'fgain':
        t_string = 'Final saccade gain'
    elif error_measure == 'igain':
        t_string = 'Initial saccade gain'
    elif error_measure == 'fpea':
        t_string = 'Final saccade pea'
    elif error_measure == 'ipea':
        t_string = 'Initial saccade pea'
    elif error_measure == 'ftheta':
        t_string = 'Final saccade directional error'
    elif error_measure == 'itheta':
        t_string = 'Initial saccade directional error'
    elif error_measure == 'famp':
        t_string = 'Final saccade amplitude error'
    elif error_measure == 'iamp':
        t_string = 'Initial saccade amplitude error'
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
        group_plot_orig(df, Y1, Y2, error_measure, t_string)
        #group_plot(df, Y1, Y2, error_measure, t_string)
   

def tiled_plot(df, Y1, Y2, Yerr1, Yerr2, error_measure, t_string = 'Title goes here'):
    X1 = [0.3, 0.8, 1.3]
    X2 = [round(x + 0.1, 1) for x in X1]
    X_sum = [sum(value) for value in zip(X1, X2)]
    x_tick_pos = [round(x/2, 2) for x in X_sum]
    x_label_names = ['No TMS', 'MGS inVF', 'MGS outVF']
    
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

def calculate_mean_and_se(group):
    mean = group['ierr'].mean()
    se = group['ierr'].sem()
    return pd.Series({'mean_ierr': mean, 'se_ierr': se})

def group_plot(df, Y1, Y2, error_measure, t_string = 'Title goes here'):
    X1 = [0.3, 0.8, 1.3]
    # X2 = [round(x + 0.1, 1) for x in X1]
    # X_sum = [sum(value) for value in zip(X1, X2)]
    # x_tick_pos = [round(x/2, 1) for x in X_sum]
    x_label_names = ['No TMS', 'MGS inVF', 'MGS outVF']
    subjIDs = df['subjID'].unique()
    num_subs = len(subjIDs)
    t_string = t_string + ', #subs = ' + str(num_subs)
    Yerr1 = sem(Y1, axis=0)
    Yerr2 = sem(Y2, axis=0)
    min_y = min(np.nanmin(Y1-Yerr1), np.nanmin(Y2-Yerr2))
    
    max_y = max(np.nanmax(Y1+Yerr1), np.nanmax(Y2+Yerr2))
    fig = plt.figure(figsize = (5, 8))

    print('Prosaccade errors')
    print(np.mean(Y1, axis = 0))
    print(Yerr1)
    #legend = ax.legend(handles=[line], labels=['Legend Label'], loc='upper right')
    
    bars = plt.bar(X1, np.mean(Y1, axis=0), width = 0.2)
    bars[0].set_color("#1B9E77")
    bars[1].set_color("#D95F02")
    bars[2].set_color("#7570B3")
    plt.errorbar(X1, np.mean(Y1, axis=0), yerr=Yerr1, fmt = 'o', ecolor = 'blue', markersize = msize, markerfacecolor = 'blue', markeredgecolor = 'blue', label = 'pro')
    for ss in range(len(subjIDs)):
        plt.plot(X1, Y1[ss, :], marker = 'o', color = 'black', alpha = 0.3, linestyle = 'dashed', markersize = msize*0.5, label = '__no_legend')
        
    plt.xticks(X1, x_label_names, fontsize = 18)
    if error_measure == 'isacc_rt':
        plt.ylabel('RT (s)', fontsize = 18)
        plt.title('Reaction time', fontsize = 24, color='black')
    elif error_measure == 'isacc_err':
        plt.ylabel('MGS error (dva)', fontsize = 18)
        plt.title('Memory error', fontsize = 24, color='black')
    #plt.savefig('/d/DATA/hyper/conferences/Dake_SfN2023/behavior_ierr.eps', format='eps', dpi = 1200)
    plt.show()
    

def group_plot_orig(df, Y1, Y2, error_measure, t_string = 'Title goes here'):
    X1 = [0.3, 0.8, 1.3]
    X2 = [round(x + 0.1, 1) for x in X1]
    X_sum = [sum(value) for value in zip(X1, X2)]
    x_tick_pos = [round(x/2, 2) for x in X_sum]
    x_label_names = ['No TMS', 'MGS inVF', 'MGS outVF']
    subjIDs = df['subjID'].unique()
    num_subs = len(subjIDs)
    t_string = t_string + ', #subs = ' + str(num_subs)
    if error_measure == 'isacc_rt':
        Y1 = Y1 * 1000
        Y2 = Y2 * 1000
    Yerr1 = sem(Y1, axis=0)
    Yerr2 = sem(Y2, axis=0)
    min_y = min(np.nanmin(Y1-Yerr1), np.nanmin(Y2-Yerr2))
    
    max_y = max(np.nanmax(Y1+Yerr1), np.nanmax(Y2+Yerr2))
    fig = plt.figure(figsize = (5, 8))
    
    print('Prosaccade errors')
    print(np.mean(Y1, axis = 0))
    print(Yerr1)

    print('Antisaccade errors')
    print(np.mean(Y2, axis = 0))
    print(Yerr2)
    #legend = ax.legend(handles=[line], labels=['Legend Label'], loc='upper right')
    for ss in range(len(subjIDs)):
        plt.plot(X1, Y1[ss, :], marker = 'o', color = 'white', alpha = 0.2, linestyle = 'dashed', markersize = msize*0.8, label = '__no_legend')
    
    plt.errorbar(X1, np.mean(Y1, axis=0), yerr=Yerr1, fmt = '.', ecolor = 'blue', markersize = msize, markerfacecolor = 'blue', markeredgecolor = 'blue', label = 'pro')
    plt.errorbar(X2, np.mean(Y2, axis=0), yerr=Yerr2, fmt = '.',  ecolor = 'red', markersize = msize, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
    plt.plot(X1, np.mean(Y1, axis=0), marker = 's', color = 'blue', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
        #ax.plot(X1, Y1, marker = 's', color = 'blue', alpha = 0.9, linestyle = 'solid', markersize = msize, label = '__no_legend')
    plt.plot(X2, np.mean(Y2, axis=0), marker = 's',  color = 'red', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    plt.xticks(x_tick_pos, x_label_names, fontsize = axes_fontsize)
    #ax.set_ylabel(error_measure, fontsize = axes_fontsize)
    #ax.set_title(t_string, fontsize = title_fontsize, color='white')
    if error_measure == 'isacc_rt':
        plt.ylabel('RT (ms)', fontsize = axes_fontsize)
        plt.ylim([250, 450])
        plt.title('Reaction time', fontsize = title_fontsize)
    elif error_measure == 'isacc_err':
        plt.ylabel('MGS error (dva)', fontsize = axes_fontsize)
        plt.title('Memory error', fontsize = title_fontsize)
    plt.show()


def distribution_plots(df):
    subjIDs = df['subjID'].unique()
    errs_to_plot = ['ierr', 'ferr', 'igain', 'fgain', 'ipea', 
                    'fpea', 'itheta', 'iamp', 'idir', 'isacc_peakvel']
    
    n_rows = 2
    n_cols = 5
    alpha_val = 0.8
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
        
def daywise_heatmap(df, df_all5, sub_list, metric):

    matrix_df = pd.DataFrame(index=sub_list)
    for sub in sub_list:
        for day in range(1, 6):
            if day < 4:
                df_sub_day = df[(df['subjID'] == sub) & (df['day'] == day)]
            else:
                df_sub_day = df_all5[(df_all5['subjID'] == sub) & (df_all5['day'] == day)]

            for rnum in df_sub_day['rnum'].unique():
                if metric == 'trial_count':
                    metric_summary = df_sub_day[df_sub_day['rnum'] == rnum]['tnum'].count()
                else:
                    metric_summary = df_sub_day[df_sub_day['rnum'] == rnum][metric].mean()
                matrix_df.at[sub, f"Day {day} Block {rnum}"] = metric_summary
    matrix_df.fillna(0, inplace=True)

    day_dfs = {}
    for day in range(1, 6):
        day_columns = [col for col in matrix_df.columns if f"Day {day}" in col]
        day_dfs[day] = matrix_df[day_columns]

    fig, axs = plt.subplots(1, 5, figsize=(20, 10))
    for day, ax in zip(day_dfs.keys(), axs.flatten()):
        if metric == 'trial_count':
            sns.heatmap(day_dfs[day], cmap='viridis', cbar = False, annot=True, ax=ax)
        else:
            cbar_ax = fig.add_axes([0.92, 0.15, 0.02, 0.7])
            sns.heatmap(day_dfs[day], cmap='viridis', cbar = True, cbar_ax = cbar_ax, annot=True, ax=ax)
        ax.set_title(f'Day {day}')
        ax.set_xlabel('Block')
        ax.set_ylabel('Subject')
    plt.show()


def plot_metric(ax, x, y_data, color, label, y_error=None):
    '''
    This function plots data and error as shaded line around it.
    '''
    y_data = y_data.where(y_data != 0, np.nan)
    ax.plot(x, y_data, label=label, color=color)
    if y_error is not None:
        y_error = y_error.where(y_error != 0, np.nan)
        ax.fill_between(x, y_data - y_error, y_data + y_error, color=color, alpha=0.3)

def plot_block_splitters(ax, col_names, df, sub):
    for col_idx, col in enumerate(col_names):
        block_num = int(col.split(' ')[-1])
        day_num = int(col.split(' ')[1])

        block_df = df[(df['day'] == day_num) & (df['rnum'] == block_num) & (df['subjID'] == sub)]
        
        if block_df.shape[0] == 0:
            color = 'white'
        else:
            if block_df['ispro'].iloc[0] == 1:
                color = 'lightblue'
            else:
                color = 'lightcoral'
        
        ax.axvspan(col_idx - 0.5, col_idx + 0.5, facecolor=color, alpha=0.3)

        if col.endswith("Block 1"):
            if block_df['istms'].eq(0).any():
                ax.axvline(x=col_idx-0.5, color='orange', linewidth=2)
            else:
                ax.axvline(x=col_idx-0.5, color='black', linewidth=2)
        else:
            ax.axvline(x=col_idx-0.5, color='grey', linestyle='--')


def daywise_trend(df_calib, df_calib_all5, df_nocalib, df_nocalib_all5, sub_list, metric):

    if metric == 'trial_count':
        mean_errors_calib = compute_tcount(df_calib, df_calib_all5, sub_list)
        mean_errors_nocalib = compute_tcount(df_nocalib, df_nocalib_all5, sub_list)
    else:
        mean_errors_calib, std_errors_calib = compute_errors(df_calib, df_calib_all5, sub_list, metric)
        mean_errors_nocalib, std_errors_nocalib = compute_errors(df_nocalib, df_nocalib_all5, sub_list, metric)
    col_names = mean_errors_calib.columns
    
    fig, axs = plt.subplots(len(sub_list), 1, figsize=(15, 5 * len(sub_list)))
    for idx, sub in enumerate(sub_list):
        ax = axs[idx]
        x = range(len(col_names))

        y_calib = mean_errors_calib.loc[sub]
        y_nocalib = mean_errors_nocalib.loc[sub]
        if metric == 'trial_count':
            plot_metric(ax, x, y_calib, 'black', 'Calib Count')
            plot_metric(ax, x, y_nocalib, 'blue', 'NoCalib Count')
        else:
            yerr_calib = std_errors_calib.loc[sub]
            yerr_nocalib = std_errors_nocalib.loc[sub]
            plot_metric(ax, x, y_calib, 'black', 'Calib Count', yerr_calib)
            plot_metric(ax, x, y_nocalib, 'blue', 'NoCalib Count', yerr_nocalib)

        plot_block_splitters(ax, col_names, df_nocalib, sub)

        ax.set_title(f'Subject {sub}')
        ax.set_xlabel('Day and Block')
        ax.set_ylabel(metric)
        if metric == 'trial_count':
            ax.set_ylim([0, 42])
        elif metric == 'ierr' or metric == 'ferr':
            ax.set_ylim([0, 4])
        elif metric == 'isacc_rt' or metric == 'fsacc_rt':
            ax.set_ylim([0, 1])
        ax.set_xticks(x)
        ax.set_xticklabels(col_names, rotation=90)
        ax.legend()

    plt.tight_layout()
    plt.show()


def daywise_trend_dual_metric(df_calib, df_calib_all5, df_nocalib, df_nocalib_all5, sub_list, metrics):
    metric1, metric2 = metrics
    mean_calib1, std_calib1 = compute_errors(df_calib, df_calib_all5, metric1, sub_list)
    mean_nocalib1, std_nocalib1 = compute_errors(df_nocalib, df_nocalib_all5, metric1, sub_list)
    mean_calib2, std_calib2 = compute_errors(df_calib, df_calib_all5, metric2, sub_list)
    mean_nocalib2, std_nocalib2 = compute_errors(df_nocalib, df_nocalib_all5, metric2, sub_list)
    col_names = mean_calib1.columns

    fig, axs = plt.subplots(len(sub_list), 1, figsize=(15, 5 * len(sub_list)))
    for idx, sub in enumerate(sub_list):
        ax1 = axs[idx]
        ax2 = ax1.twinx()

        x = range(len(col_names))

        y_calib1 = mean_calib1.loc[sub]
        yerr_calib1 = std_calib1.loc[sub]
        y_nocalib1 = mean_nocalib1.loc[sub]
        yerr_nocalib1 = std_nocalib1.loc[sub]
        plot_metric(ax1, x, y_calib1,'black', f'{metric1} Calib', yerr_calib1)
        plot_metric(ax1, x, y_nocalib1,'blue', f'{metric1} Nocalib', yerr_nocalib1)
        

        y_calib2 = mean_calib2.loc[sub]
        yerr_calib2 = std_calib2.loc[sub]
        y_nocalib2 = mean_nocalib2.loc[sub]
        yerr_nocalib2 = std_nocalib2.loc[sub]
        plot_metric(ax1, x, y_calib2,'black', f'{metric2} Calib', yerr_calib2)
        plot_metric(ax1, x, y_nocalib2,'blue', f'{metric2} Nocalib', yerr_nocalib2)

        
        ax1.set_title(f'Subject {sub}')
        ax1.set_xlabel('Day and Block')
        ax1.set_ylabel(metric1)
        ax2.set_ylabel(metric2)

        ax1.set_xticks(x)
        ax1.set_xticklabels(col_names, rotation=90)

        ax1.legend(loc='upper left')
        ax2.legend(loc='upper right')

    plt.tight_layout()
    plt.show()
