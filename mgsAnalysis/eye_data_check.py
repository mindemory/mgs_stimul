# Load the modules
from scipy.io import loadmat
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import os
from scipy.stats import sem, f_oneway
from statsmodels.stats.multicomp import pairwise_tukeyhsd


# Hide deprecation warnings!
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 

subjID = '01'
days = [1, 2, 3]
TMSon = [0, 1, 1]

direct = {}
direct['datc'] =  '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc'
direct['data'] = direct['datc'] + '/data'
direct['analysis'] = direct['datc'] + '/analysis'
direct['Figures'] = direct['datc'] + '/Figures/sub' + subjID 
direct['phosphene'] = direct['data'] + '/phosphene_data/sub' + subjID
direct['mgs'] = direct['data'] + '/mgs_data/sub' + subjID
#taskMapfilename = direct['phosphene'] + '/taskMap_sub' + subjID + '_day' + f'{day:02d}' + '.mat'

# def label_diff(i,j,text,X,Y, ax):
#     x = (X[i]+X[j])/2
#     y = 1.1*max(Y[i], Y[j])
#     dx = abs(X[i]-X[j])

#     props = {'connectionstyle':'bar','arrowstyle':'-',\
#                     'shrinkA':30,'shrinkB':30,'linewidth':1}
#     ax.annotate(text, xy=(x,y+0.25), zorder=10)
#     ax.annotate('', xy=(X[i],y), xytext=(X[j],y), arrowprops=props)

for ii in range(len(days)):
    day = days[ii]
    tms_status = TMSon[ii]
    direct['day'] = direct['mgs'] + '/day' + f'{day:02d}'
    direct['save'] = direct['analysis'] + '/sub' + subjID + '/day' + f'{day:02d}'
    saveNamepro = direct['save'] + '/ii_sess_pro_sub' + subjID + '_day' + f'{day:02d}' + '.mat'
    saveNameanti = direct['save'] + '/ii_sess_anti_sub' + subjID + '_day' + f'{day:02d}' + '.mat'

    # Load the data files
    ii_sess_pro = loadmat(saveNamepro)
    ii_sess_anti = loadmat(saveNameanti)

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
    
    if tms_status == 1:
        trial_type = []
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
        if 'df_tms' in globals():
            df_tms = pd.concat([df_tms, df])
        else:
            df_tms = df
    else:
        trial_type = []
        for ii in range(df['ispro'].shape[0]):
            if df['ispro'][ii] == 1:
                trial_type.append('pro')
            elif df['ispro'][ii] == -1:
                trial_type.append('anti')
        df['trial_type'] = trial_type
        if 'df_notms' in globals():
            df_notms = pd.concat([df_notms, df])
        else:
            df_notms = df


df_tms_goodtrials = df_tms[df_tms['rejtrials'] == 0 & df_tms['i_sacc_err'].notna() & df_tms['f_sacc_err'].notna()]
df_notms_goodtrials = df_notms[df_notms['rejtrials'] == 0 & df_notms['i_sacc_err'].notna() & df_notms['f_sacc_err'].notna()]
df_tms_goodtrials = df_tms_goodtrials[(((df_tms_goodtrials['i_sacc_err'] - df_tms_goodtrials['i_sacc_err'].mean()) 
                / df_tms_goodtrials['i_sacc_err'].std()).abs() < 3) & (((df_tms_goodtrials['f_sacc_err'] - 
                df_tms_goodtrials['f_sacc_err'].mean())  / df_tms_goodtrials['f_sacc_err'].std()).abs() < 3)]
df_notms_goodtrials = df_notms_goodtrials[(((df_notms_goodtrials['i_sacc_err'] - df_notms_goodtrials['i_sacc_err'].mean()) 
                / df_notms_goodtrials['i_sacc_err'].std()).abs() < 3) & (((df_notms_goodtrials['f_sacc_err'] - 
                df_notms_goodtrials['f_sacc_err'].mean())  / df_notms_goodtrials['f_sacc_err'].std()).abs() < 3)]

cat_order_tms = ['prointoVF', 'antiintoVF', 'prooutVF', 'antioutVF']
cat_order_notms = ['pro', 'anti']
# Stats
f_value, p_value = f_oneway(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'pro']['i_sacc_err'],
                    df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'anti']['i_sacc_err'],
                    df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['i_sacc_err'],
                    df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['i_sacc_err'],
                    df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['i_sacc_err'],
                    df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['i_sacc_err'])
print(f'One-way ANOVA for i_sacc_err gives F = {f_value}, p = {p_value}')
f_value, p_value = f_oneway(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'pro']['f_sacc_err'],
                    df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'anti']['f_sacc_err'],
                    df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['f_sacc_err'],
                    df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['f_sacc_err'],
                    df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['f_sacc_err'],
                    df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['f_sacc_err'])
print(f'One-way ANOVA for f_sacc_err gives F = {f_value}, p = {p_value}')


df_concat = pd.concat([df_tms_goodtrials, df_notms_goodtrials])
tukey = pairwise_tukeyhsd(endog=df_concat['i_sacc_err'], groups=df_concat['trial_type'], alpha=0.05)
print('i_sacc_err')
print(tukey)
tukey = pairwise_tukeyhsd(endog=df_concat['f_sacc_err'], groups=df_concat['trial_type'], alpha=0.05)
print('f_sacc_err')
print(tukey)

# Plotting figures
plt.rc('ytick', labelsize = 12)
fig1, ax = plt.subplots()
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'pro']['i_sacc_err']),
    np.mean(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['i_sacc_err']),
    np.mean(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['i_sacc_err'])]
Y2 = [np.mean(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'anti']['i_sacc_err']),
    np.mean(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['i_sacc_err']),
    np.mean(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['i_sacc_err'])]
Yerr1 = [sem(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'pro']['i_sacc_err']),
    sem(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['i_sacc_err']),
    sem(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['i_sacc_err'])]
Yerr2 = [sem(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'anti']['i_sacc_err']),
    sem(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['i_sacc_err']),
    sem(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['i_sacc_err'])]
plt.title('sub' + subjID + ' i_sacc_err', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
#plt.ylim(0, 5)
plt.ylim(0, 2)
plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = 12)
plt.legend()
# Xs = X1 + X2
# Ys = Y1+Y2
# ind1 = [0]
# ind2 = [3]
# ps = [0.0003]
# for ll in range(len(ind1)):
#     if ps[ll] < 0.0001:
#         sig_star = '****'
#     elif ps[ll] < 0.001:
#         sig_star = '***'
#     elif ps[ll] < 0.01:
#         sig_star = '**'
#     elif ps[ll] < 0.05:
#         sig_star = '*'
#     else:
#         sig_star = 'ns'
#     label_diff(ind1[ll], ind2[ll], sig_star, Xs, Ys, ax)
#label_diff(0, 1, '*', X1+X2, Y1+Y2, ax)
plt.ylabel('MGS Error', fontsize = 12)

fig2 = plt.figure()
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'pro']['f_sacc_err']),
    np.mean(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['f_sacc_err']),
    np.mean(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['f_sacc_err'])]
Y2 = [np.mean(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'anti']['f_sacc_err']),
    np.mean(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['f_sacc_err']),
    np.mean(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['f_sacc_err'])]
Yerr1 = [sem(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'pro']['f_sacc_err']),
    sem(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['f_sacc_err']),
    sem(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['f_sacc_err'])]
Yerr2 = [sem(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'anti']['f_sacc_err']),
    sem(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['f_sacc_err']),
    sem(df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['f_sacc_err'])]
plt.title('sub' + subjID + ' f_sacc_err', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
#plt.ylim(0, 2.5)
plt.ylim(0, 2)
plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)


fig3, axs = plt.subplots(1, 2, sharey = True)
sns.violinplot(ax = axs[0], data = df_notms_goodtrials, x = 'trial_type', y = 'i_sacc_err', order = cat_order_notms)
sns.violinplot(ax = axs[1], data = df_tms_goodtrials, x = 'trial_type', y = 'i_sacc_err', order = cat_order_tms)
plt.suptitle('sub '+ subjID)
fig4, axs = plt.subplots(1, 2, sharey = True)
sns.violinplot(ax = axs[0], data = df_notms_goodtrials, x = 'trial_type', y = 'f_sacc_err', order = cat_order_notms)
sns.violinplot(ax = axs[1], data = df_tms_goodtrials, x = 'trial_type', y = 'f_sacc_err', order = cat_order_tms)
plt.suptitle('sub '+ subjID)
isacc_fig_path = direct['Figures'] + '/isacc_errs.png'
fig1.savefig(isacc_fig_path, dpi = fig1.dpi, format='png')
fsacc_fig_path = direct['Figures'] + '/fsacc_errs.png'
fig2.savefig(fsacc_fig_path, dpi = fig2.dpi, format='png')
isacc_violin_fig_path = direct['Figures'] + '/isacc_violin.png'
fig3.savefig(isacc_violin_fig_path, dpi = fig3.dpi, format='png')
fsacc_violin_fig_path = direct['Figures'] + '/fsacc_violin.png'
fig4.savefig(fsacc_violin_fig_path, dpi = fig4.dpi, format='png')
