import numpy as np
import pandas as pd
from scipy.stats import sem
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import gaussian_kde as gkde

msize = 12
axes_fontsize = 12
title_fontsize = 14
sns.set()
def subject_wise_error_plot(df, error_measure):
    X1 = [0.3, 0.8, 1.3]
    X2 = [round(x + 0.1, 1) for x in X1]
    TMSconds = ['No TMS', 'TMS intoVF', 'TMS outVF']
    subjIDs = df['subjID'].unique()
    Y1 = np.zeros((len(subjIDs), len(TMSconds)))
    Y2 = np.zeros((len(subjIDs), len(TMSconds)))
    Yerr1 = np.zeros((len(subjIDs), len(TMSconds)))
    Yerr2 = np.zeros((len(subjIDs), len(TMSconds)))

    warm_colors = plt.get_cmap('OrRd')
    cool_colors = plt.get_cmap('Blues')
    wcols = warm_colors(np.linspace(0.3, 0.7, len(subjIDs)))
    ccols = cool_colors(np.linspace(0.3, 0.7, len(subjIDs)))
    for ss in range(len(subjIDs)):
        for ii in range(len(TMSconds)):
            this_prodf = df[(df['subjID'] == subjIDs[ss]) & 
                            (df['TMS_condition'] == TMSconds[ii]) &
                            ((df['ispro'] == 1))]
            this_antidf = df[(df['subjID'] == subjIDs[ss]) & 
                            (df['TMS_condition'] == TMSconds[ii]) &
                            ((df['ispro'] == 0))]
            Y1[ss, ii] = np.nanmean(this_prodf[error_measure])
            Y2[ss, ii] = np.nanmean(this_antidf[error_measure])
            
            Yerr1[ss, ii] = sem(this_prodf[error_measure])
            Yerr2[ss, ii] = sem(this_antidf[error_measure])
        # normalizer_val = Y1[ss, 0]
        # Y1[ss, :] = Y1[ss, :] / normalizer_val
        # Y2[ss, :] = Y2[ss, :] / normalizer_val
    x_label_names = ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF']

    X_sum = [sum(value) for value in zip(X1, X2)]
    x_tick_pos = [round(x/2, 1) for x in X_sum]
    # LIMS_x = max(X2) + 0.2
    #LIMS_y = max(max(max(Y1)), max(max(Y2))) * 1.2
    # LIMS = [LIMS_x, LIMS_y]
    
    fig = plt.figure(figsize = (7, 9))
    #plt.title(error_measure +' across ' + str(len(subjIDs)) + ' subjects', fontsize = title_fontsize)
    plt.title(subjIDs, fontsize = title_fontsize)
    for ss in range(len(subjIDs)):
        # plt.errorbar(X1, Y1[ss, :], yerr = Yerr1[ss, :], fmt = '.', ecolor = ccols[0], 
        #             markersize = msize, markerfacecolor = ccols[0], markeredgecolor = ccols[0], label = '__no_legend')
        # plt.errorbar(X2, Y2[ss, :], yerr = Yerr2[ss, :], fmt = '.', ecolor = wcols[0], 
        #             markersize = msize, markerfacecolor = wcols[0], markeredgecolor = wcols[0], label = '__no_legend')
        plt.plot(X1, Y1[ss, :], color = ccols[0], linestyle = 'dashdot', label = '__no_legend', markersize = msize)
        plt.plot(X2, Y2[ss, :], color = wcols[0], linestyle = 'dashdot', label = '__no_legend', markersize = msize)
    
    if len(subjIDs) < 3:
        plt.plot(X1, np.mean(Y1, axis=0), marker = 's', color = 'blue', linestyle = 'solid', markersize = msize*1.2, label = 'pro')
        plt.plot(X2, np.mean(Y2, axis=0), marker = 's',  color = 'red', linestyle = 'solid', markersize = msize*1.2, label = 'anti')
    else:
        plt.errorbar(X1, np.mean(Y1, axis=0), yerr=sem(Y1, axis=0), fmt = '.', ecolor = 'blue', markersize = msize, markerfacecolor = 'blue', markeredgecolor = 'blue', label = 'pro')
        plt.errorbar(X2, np.mean(Y2, axis=0), yerr=sem(Y2, axis=0), fmt = '.',  ecolor = 'red', markersize = msize, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
        plt.plot(X1, np.mean(Y1, axis=0), marker = 's', color = 'blue', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
        plt.plot(X2, np.mean(Y2, axis=0), marker = 's',  color = 'red', linestyle = 'solid', markersize = msize*1.2, label = '__no_legend')
    #plt.ylim([0, LIMS_y])
    plt.xticks(x_tick_pos, x_label_names, fontsize = axes_fontsize)
    plt.ylabel(error_measure, fontsize = axes_fontsize)
    plt.legend()
    plt.show()

def quick_visualization(df):
    cols_to_plot = ['isaccX', 'isaccY', 'fsaccX', 'fsaccY', 'isacc_err',
       'fsacc_err', 'isacc_theta_err', 'fsacc_theta_err',
       'corrected_theta_err', 'isacc_radius_err', 'fsacc_radius_err',
       'corrected_radius_err', 'nsacc', 'calib_err', 'isacc_rt', 'fsacc_rt',
       'isacc_peakvel', 'fsacc_peakvel']
    # df['trial_type'].replace(['pro_intoVF', 'pro_outVF', 'anti_intoVF', 'anti_outVF'],
    #                          [0, 1, 2, 3], inplace=True)
    # df['TMS_condition'].replace(['No TMS', 'TMS intoVF', 'TMS outVF'],
    #                     [0, 1, 2], inplace=True) 
    pd.plotting.scatter_matrix(df[cols_to_plot], figsize = (20, 20), alpha = 0.8)
    plt.suptitle('Quick overview', fontsize = title_fontsize)
    plt.show()

    # Visualizing data in 2-d, kept out because not sure how it is doing it.
    # pd.plotting.radviz(df[cols_to_plot], 'TMS_condition')
    # plt.suptitle('Quick overview', fontsize = title_fontsize)
    # plt.show()
def distribution_plots(df):
    subjIDs = df['subjID'].unique()
    #df = df[df['fsacc_err']<4]
    errs_to_plot = ['fsacc_err', 'fsacc_theta_err', 'corrected_theta_err', 'fsacc_radius_err', 
                    'corrected_radius_err', 'nsacc', 'calib_err', 'fsacc_rt', 'isacc_peakvel', 'fsacc_peakvel']
    n_rows = 2
    n_cols = 5
    alpha_val = 0.8
    #tmp_df = df[df['TMS_condition']=='No TMS']
    for ss in range(len(subjIDs)):
        subj_df =  df[df['subjID']==subjIDs[ss]]
        fig, axes = plt.subplots(n_rows, n_cols, figsize = (20, 10))
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
        


        
        


