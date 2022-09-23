# Load the modules
from scipy.io import loadmat
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import os
from scipy.stats import sem, f_oneway
from statsmodels.stats.multicomp import pairwise_tukeyhsd
from generate_Y import generate_Y

# Hide deprecation warnings!
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 

subjID = '02'
days = [1, 2, 3]

direct = {}
#direct['datc'] =  '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc'
direct['datc'] =  '/d/DATC/datc/MD_TMS_EEG'
direct['data'] = direct['datc'] + '/data'
direct['analysis'] = direct['datc'] + '/analysis'
direct['Figures'] = direct['datc'] + '/Figures/sub' + subjID 
direct['phosphene'] = direct['data'] + '/phosphene_data/sub' + subjID
direct['mgs'] = direct['data'] + '/mgs_data/sub' + subjID

for ii in range(len(days)):
    day = days[ii]
    
    direct['day'] = direct['mgs'] + '/day' + f'{day:02d}'
    direct['save'] = direct['analysis'] + '/sub' + subjID + '/day' + f'{day:02d}'
    saveNamepro = direct['save'] + '/ii_sess_pro_sub' + subjID + '_day' + f'{day:02d}' + '.mat'
    saveNameanti = direct['save'] + '/ii_sess_anti_sub' + subjID + '_day' + f'{day:02d}' + '.mat'
    taskMapfilename = direct['phosphene'] + '/taskMap_sub' + subjID + '_day' + f'{day:02d}' + '.mat'
    
    # Load the data files
    taskMap = loadmat(taskMapfilename)
    ii_sess_pro = loadmat(saveNamepro)
    ii_sess_anti = loadmat(saveNameanti)

    # Check if this is a TMS session
    tms_status = taskMap['taskMap'][0, 0]['TMScond'][0][0]
    print(tms_status)
    # Find the stimulus VF
    stimVF_pro = ii_sess_pro['ii_sess_pro']['stimVF'][0, 0]
    stimVF_anti = ii_sess_anti['ii_sess_anti']['stimVF'][0, 0]
    ispro = np.concatenate((np.ones(np.shape(stimVF_pro)[0]), -1*np.ones(np.shape(stimVF_anti)[0]))).astype(int)
    stimVF = np.concatenate((stimVF_pro, stimVF_anti))
    numTrials_pro = len(ii_sess_pro['ii_sess_pro']['stimVF'][0, 0])
    numTrials_anti = len(ii_sess_anti['ii_sess_anti']['stimVF'][0, 0])

    # Find trials to be rejected! Conditions used: no primary saccade or large saccade error
    ii_sess_pro_rejtrials = np.where((ii_sess_pro['ii_sess_pro']['prim_sacc'][0, 0] == 0) | 
                                        (ii_sess_pro['ii_sess_pro']['large_error'] == 1))[0]
    ii_sess_anti_rejtrials = numTrials_pro + np.where((ii_sess_anti['ii_sess_anti']['prim_sacc'][0, 0] == 0) | 
                                        (ii_sess_anti['ii_sess_anti']['large_error'] == 1))[0]
    rejtrials = np.zeros(numTrials_pro + numTrials_anti)
    rejtrials[ii_sess_pro_rejtrials] = 1
    rejtrials[ii_sess_anti_rejtrials] = 1

    # Get the initial and final saccade errors
    isacc_pro = ii_sess_pro['ii_sess_pro']['i_sacc_err'][0, 0]
    isacc_anti = ii_sess_anti['ii_sess_anti']['i_sacc_err'][0, 0]
    isacc = np.concatenate((isacc_pro, isacc_anti))
    fsacc_pro = ii_sess_pro['ii_sess_pro']['f_sacc_err'][0, 0]
    fsacc_anti = ii_sess_anti['ii_sess_anti']['f_sacc_err'][0, 0]
    fsacc = np.concatenate((fsacc_pro, fsacc_anti))

    # Divide the trials into 4 conditions: prointoVF, prooutVF, antiintoVF, antioutVF
    prointoVF_idx = np.where(stimVF_pro == np.ones(stimVF_pro.shape))[0]
    prooutVF_idx = np.where(stimVF_pro == np.zeros(stimVF_anti.shape))[0]
    antiintoVF_idx = stimVF_pro.shape[0] + np.where(stimVF_anti == np.zeros(stimVF_anti.shape))[0]
    antioutVF_idx = stimVF_pro.shape[0] + np.where(stimVF_anti == np.ones(stimVF_anti.shape))[0]

    # Create a dataframe
    df = pd.DataFrame(isacc, columns = ['i_sacc_err']) # Initial saccade errors
    df['f_sacc_err'] = fsacc # Final saccade errors
    df['instimVF'] = stimVF # Is stimulus in the visual field? 1: yes, 0: no
    df['ispro'] = ispro # Is this a pro-saccade trial? 1: yes, -1: no
    df['typesum'] = df['instimVF'] + df['ispro']
    df['rejtrials'] = rejtrials
    
    trial_type = []
    pro_anti = []
    into_away = []
    for ii in range(df['ispro'].shape[0]):
        if df['ispro'][ii] == 1:
            pro_anti.append('pro')
        elif df['ispro'][ii] == -1:
            pro_anti.append('anti')
    for ii in range(df['instimVF'].shape[0]):
        if df['instimVF'][ii] == 1:
            into_away.append('into')
        elif df['instimVF'][ii] == 0:
            into_away.append('away')
    for ii in range(df['typesum'].shape[0]):
        if df['typesum'][ii] == 0:
            trial_type.append('antioutVF')
        elif df['typesum'][ii] == -1:
            trial_type.append('antiintoVF')
        elif df['typesum'][ii] == 1:
            trial_type.append('prooutVF')
        elif df['typesum'][ii] == 2:
            trial_type.append('prointoVF')
    df['trial_type'] = trial_type
    df['pro_anti'] = pro_anti
    df['into_away'] = into_away

    if tms_status == 1:
        if 'df_tms' in globals():
            df_tms = pd.concat([df_tms, df])
        else:
            df_tms = df
    else:
        if 'df_notms' in globals():
            df_notms = pd.concat([df_notms, df])
        else:
            df_notms = df

# df_tms = df_tms['i_sacc_err'].replace([np.inf, -np.inf], np.nan, inplace = True)
# df_notms = df_notms['i_sacc_err'].replace([np.inf, -np.inf], np.nan, inplace = True)
# df_tms = df_tms['f_sacc_err'].replace([np.inf, -np.inf], np.nan, inplace = True)
# df_notms = df_notms['f_sacc_err'].replace([np.inf, -np.inf], np.nan, inplace = True)

df_tms_goodtrials = df_tms[df_tms['rejtrials'] == 0 & df_tms['i_sacc_err'].notna() & df_tms['f_sacc_err'].notna()]
df_notms_goodtrials = df_notms[df_notms['rejtrials'] == 0 & df_notms['i_sacc_err'].notna() & df_notms['f_sacc_err'].notna()]
df_tms_goodtrials = df_tms_goodtrials[(((df_tms_goodtrials['i_sacc_err'] - df_tms_goodtrials['i_sacc_err'].mean()) 
                / df_tms_goodtrials['i_sacc_err'].std()).abs() < 3) & (((df_tms_goodtrials['f_sacc_err'] - 
                df_tms_goodtrials['f_sacc_err'].mean())  / df_tms_goodtrials['f_sacc_err'].std()).abs() < 3)]
df_notms_goodtrials = df_notms_goodtrials[(((df_notms_goodtrials['i_sacc_err'] - df_notms_goodtrials['i_sacc_err'].mean()) 
                / df_notms_goodtrials['i_sacc_err'].std()).abs() < 3) & (((df_notms_goodtrials['f_sacc_err'] - 
                df_notms_goodtrials['f_sacc_err'].mean())  / df_notms_goodtrials['f_sacc_err'].std()).abs() < 3)]

cat_order_trial_type = ['prointoVF', 'antiintoVF', 'prooutVF', 'antioutVF']
cat_order_pro_anti = ['pro', 'anti']
cat_order_into_away = ['into', 'away']

print('No TMS prointoVF: ', df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'prointoVF'].shape)
print('No TMS prooutVF: ', df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'prooutVF'].shape)
print('TMS prointoVF: ', df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF'].shape)
print('TMS prooutVF: ', df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF'].shape)
print('No TMS antiintoVF: ', df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'antiintoVF'].shape)
print('No TMS antioutVF: ', df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'antioutVF'].shape)
print('TMS antiintoVF: ', df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF'].shape)
print('TMS antioutVF: ', df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF'].shape)
# Stats
# f_value, p_value = f_oneway(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'prointoVF']['i_sacc_err'],
#                     df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'antiintoVF']['i_sacc_err'],
#                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['i_sacc_err'],
#                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['i_sacc_err'],
#                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['i_sacc_err'],
#                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['i_sacc_err'])
# print(f'One-way ANOVA for i_sacc_err gives F = {f_value}, p = {p_value}')
# f_value, p_value = f_oneway(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'prointoVF']['f_sacc_err'],
#                     df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'antiintoVF']['f_sacc_err'],
#                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['f_sacc_err'],
#                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['f_sacc_err'],
#                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['f_sacc_err'],
#                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['f_sacc_err'])
# print(f'One-way ANOVA for f_sacc_err gives F = {f_value}, p = {p_value}')


# df_concat = pd.concat([df_tms_goodtrials, df_notms_goodtrials])
# tukey = pairwise_tukeyhsd(endog=df_concat['i_sacc_err'], groups=df_concat['trial_type'], alpha=0.05)
# print('i_sacc_err')
# print(tukey)
# tukey = pairwise_tukeyhsd(endog=df_concat['f_sacc_err'], groups=df_concat['trial_type'], alpha=0.05)
# print('f_sacc_err')
# print(tukey)

# Plotting figures
plt.rc('ytick', labelsize = 12)
fig, ax = plt.subplots()
X1, X2, x_tick_pos, x_label_names, leg_names, LIMS, Y1, Y2, Yerr1, Yerr2, fname = generate_Y(df_notms_goodtrials, 
                        df_tms_goodtrials, 'trial_type', 'i_sacc_err')
plt.title('sub' + subjID + ' i_sacc_err', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = leg_names[0])
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = leg_names[1])
plt.xlim(0, LIMS[0])
plt.ylim(0, LIMS[1])
plt.xticks(x_tick_pos, x_label_names, fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
fig.savefig(direct['Figures'] + fname, dpi = fig.dpi, format='pdf')

fig, ax = plt.subplots()
X1, X2, x_tick_pos, x_label_names, leg_names, LIMS, Y1, Y2, Yerr1, Yerr2, fname = generate_Y(df_notms_goodtrials, 
                        df_tms_goodtrials, 'trial_type', 'f_sacc_err')
plt.title('sub' + subjID + ' f_sacc_err', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = leg_names[0])
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = leg_names[1])
plt.xlim(0, LIMS[0])
plt.ylim(0, LIMS[1])
plt.xticks(x_tick_pos, x_label_names, fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
fig.savefig(direct['Figures'] + fname, dpi = fig.dpi, format='pdf')

fig, ax = plt.subplots()
X1, X2, x_tick_pos, x_label_names, leg_names, LIMS, Y1, Y2, Yerr1, Yerr2, fname = generate_Y(df_notms_goodtrials, 
                        df_tms_goodtrials, 'pro_anti', 'i_sacc_err')
plt.title('sub' + subjID + ' i_sacc_err', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = leg_names[0])
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = leg_names[1])
plt.xlim(0, LIMS[0])
plt.ylim(0, LIMS[1])
plt.xticks(x_tick_pos, x_label_names, fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
fig.savefig(direct['Figures'] + fname, dpi = fig.dpi, format='pdf')

fig, ax = plt.subplots()
X1, X2, x_tick_pos, x_label_names, leg_names, LIMS, Y1, Y2, Yerr1, Yerr2, fname = generate_Y(df_notms_goodtrials, 
                        df_tms_goodtrials, 'pro_anti', 'f_sacc_err')
plt.title('sub' + subjID + ' f_sacc_err', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = leg_names[0])
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = leg_names[1])
plt.xlim(0, LIMS[0])
plt.ylim(0, LIMS[1])
plt.xticks(x_tick_pos, x_label_names, fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
fig.savefig(direct['Figures'] + fname, dpi = fig.dpi, format='pdf')

fig, ax = plt.subplots()
X1, X2, x_tick_pos, x_label_names, leg_names, LIMS, Y1, Y2, Yerr1, Yerr2, fname = generate_Y(df_notms_goodtrials, 
                        df_tms_goodtrials, 'into_away', 'i_sacc_err')
plt.title('sub' + subjID + ' i_sacc_err', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = leg_names[0])
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = leg_names[1])
plt.xlim(0, LIMS[0])
plt.ylim(0, LIMS[1])
plt.xticks(x_tick_pos, x_label_names, fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
fig.savefig(direct['Figures'] + fname, dpi = fig.dpi, format='pdf')

fig, ax = plt.subplots()
X1, X2, x_tick_pos, x_label_names, leg_names, LIMS, Y1, Y2, Yerr1, Yerr2, fname = generate_Y(df_notms_goodtrials, 
                        df_tms_goodtrials, 'into_away', 'f_sacc_err')
plt.title('sub' + subjID + ' f_sacc_err', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = leg_names[0])
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = leg_names[1])
plt.xlim(0, LIMS[0])
plt.ylim(0, LIMS[1])
plt.xticks(x_tick_pos, x_label_names, fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
fig.savefig(direct['Figures'] + fname, dpi = fig.dpi, format='pdf')

# fig3, axs = plt.subplots(1, 2, sharey = True)
# sns.violinplot(ax = axs[0], data = df_notms_goodtrials, x = 'trial_type', y = 'i_sacc_err', order = cat_order_notms)
# sns.violinplot(ax = axs[1], data = df_tms_goodtrials, x = 'trial_type', y = 'i_sacc_err', order = cat_order_tms)
# plt.suptitle('sub '+ subjID)
# fig4, axs = plt.subplots(1, 2, sharey = True)
# sns.violinplot(ax = axs[0], data = df_notms_goodtrials, x = 'trial_type', y = 'f_sacc_err', order = cat_order_notms)
# sns.violinplot(ax = axs[1], data = df_tms_goodtrials, x = 'trial_type', y = 'f_sacc_err', order = cat_order_tms)
# plt.suptitle('sub '+ subjID)

