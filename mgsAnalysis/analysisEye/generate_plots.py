import numpy as np
import pandas as pd
from scipy.stats import sem
import matplotlib.pyplot as plt
import seaborn as sns
msize = 12
axes_fontsize = 12
title_fontsize = 14
#sns.set()
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
    wcols = warm_colors(np.linspace(0.4, 0.8, len(subjIDs)))
    ccols = cool_colors(np.linspace(0.4, 0.8, len(subjIDs)))
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

    x_label_names = ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF']

    X_sum = [sum(value) for value in zip(X1, X2)]
    x_tick_pos = [round(x/2, 1) for x in X_sum]
    # LIMS_x = max(X2) + 0.2
    # LIMS_y = max(max(Y1), max(Y2)) * 1.2
    # LIMS = [LIMS_x, LIMS_y]
    
    fig = plt.figure(figsize = (7, 9))
    plt.title(error_measure +' across subjects', fontsize = title_fontsize)
    for ss in range(len(subjIDs)):
        plt.errorbar(X1, Y1[ss, :], yerr = Yerr1[ss, :], fmt = '.', ecolor = ccols[ss], 
                    markersize = msize, markerfacecolor = ccols[ss], markeredgecolor = ccols[ss], label = str(subjIDs[ss])+'_pro')
        plt.errorbar(X2, Y2[ss, :], yerr = Yerr2[ss, :], fmt = '.', ecolor = wcols[ss], 
                    markersize = msize, markerfacecolor = wcols[ss], markeredgecolor = wcols[ss], label = str(subjIDs[ss])+'_anti')
        plt.plot(X1, Y1[ss, :], color = ccols[ss], linestyle = 'dashdot', label = '__no_legend', markersize = msize)
        plt.plot(X2, Y2[ss, :], color = wcols[ss], linestyle = 'dashdot', label = '__no_legend', markersize = msize)
    
    if len(subjIDs) < 3:
        plt.plot(X1, np.mean(Y1, axis=0), marker = 's', color = 'blue', linestyle = 'solid', markersize = msize*1.2)
        plt.plot(X2, np.mean(Y2, axis=0), marker = 's',  color = 'red', linestyle = 'solid', markersize = msize*1.2)

    plt.xticks(x_tick_pos, x_label_names, fontsize = axes_fontsize)
    plt.ylabel(error_measure, fontsize = axes_fontsize)
    plt.legend()
    plt.show()

def quick_visualization(df):
    cols_to_plot = ['subjID', 'TMS_condition', 'trial_type', 'isacc_err', 'fsacc_err', 'isacc_rt', 'fsacc_rt']
    df['trial_type'].replace(['pro_intoVF', 'pro_outVF', 'anti_intoVF', 'anti_outVF'],
                             [0, 1, 2, 3], inplace=True)
    df['TMS_condition'].replace(['No TMS', 'TMS intoVF', 'TMS outVF'],
                        [0, 1, 2], inplace=True) 
    pd.plotting.scatter_matrix(df[cols_to_plot], figsize = (10, 10), alpha = 0.8)
    plt.suptitle('Quick overview', fontsize = title_fontsize)
    plt.show()

    # Visualizing data in 2-d, kept out because not sure how it is doing it.
    # pd.plotting.radviz(df[cols_to_plot], 'TMS_condition')
    # plt.suptitle('Quick overview', fontsize = title_fontsize)
    # plt.show()
#  def distribution_plots(df):
#     subjIDs = df['subjID'].unique()
#     fig = plt.figure(figsize = (7, 9))
#     for ss in range(len(subjIDs)):


