# Load the modules
from scipy.io import loadmat
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import os
from scipy.stats import sem, f_oneway
from statsmodels.stats.multicomp import pairwise_tukeyhsd
from generate_Y import generate_Y, generate_plot

# Hide deprecation warnings!
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 

import socket
hostname = socket.gethostname()

p = {}
if hostname == 'syndrome':
    p['datc'] =  '/d/DATC/datc/MD_TMS_EEG'
else:
    p['datc'] =  '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc'
p['data'] = p['datc'] + '/data'
p['analysis'] = p['datc'] + '/analysis'
p['Figures'] = p['datc'] + '/Figures/meta_analysis'

# Find subjects and days that have been run so far
sub_dirs = [dirname for dirname in os.listdir(p['analysis']) if dirname.startswith("sub0") or dirname.startswith("sub1")  or dirname.startswith("sub2")  or dirname.startswith("sub3")]
subjIDs = []
num_subs = len(sub_dirs) # Number of subjects
print(f"We have {num_subs} subjects so far: {sub_dirs}")
print()

# Create a master dataframe
for ii in range(len(sub_dirs)):
    subjIDs.append(int(sub_dirs[ii][-2:]))
    subjdir = p['analysis'] + '/' + sub_dirs[ii] # Path of current subject directory
    day_dirs = [dirname for dirname in os.listdir(subjdir) if dirname.startswith("day")]
    days = []
    for dd in range(len(day_dirs)):
        days.append(int(day_dirs[dd][-2:]))
        daydir = subjdir + '/' + day_dirs[dd] # Path to daydir for current subject
        print(f'Running subj = {subjIDs[ii]}, day = {days[dd]}')

        # Check if this was a TMS session
        phosphene_data_path = p['data'] + '/phosphene_data/' + sub_dirs[ii]
        taskMapfilename =phosphene_data_path + '/taskMap_' + sub_dirs[ii] + '_' + day_dirs[dd] + '_antitype_mirror.mat'
        taskMap = loadmat(taskMapfilename)['taskMap']
        tms_status = taskMap[0, 0]['TMScond'][0][0]
        
        # Load the ii_sess files
        profName = daydir + '/ii_sess_pro_' + sub_dirs[ii] + '_' + day_dirs[dd] + '.mat'
        antifName = daydir + '/ii_sess_anti_' + sub_dirs[ii] + '_' + day_dirs[dd] + '.mat'
        ii_sess_pro = loadmat(profName)['ii_sess_pro']
        ii_sess_anti = loadmat(antifName)['ii_sess_anti']
        numTrials_pro = len(ii_sess_pro['stimVF'][0, 0])
        numTrials_anti = len(ii_sess_anti['stimVF'][0, 0])
        total_trials = numTrials_pro + numTrials_anti
        print(f"Trial-count: pro = {numTrials_pro}, anti = {numTrials_anti}")
        pro_data = {'subjID': np.full((numTrials_pro,), subjIDs[ii]),
                     'day': np.full((numTrials_pro,), days[dd]),
                      'tnum': ii_sess_pro['t_num'][0, 0].T[0],
                     'tms': np.full((numTrials_pro,), tms_status),
                     'ispro': np.full((numTrials_pro), 1),
                     'instimVF': ii_sess_pro['stimVF'][0, 0].T[0],
                     'isacc_err': ii_sess_pro['i_sacc_err'][0, 0].T[0],
                     'fsacc_err': ii_sess_pro['f_sacc_err'][0, 0].T[0],
                     'isacc_rt': ii_sess_pro['i_sacc_rt'][0, 0].T[0],
                     'fsacc_rt': ii_sess_pro['f_sacc_rt'][0, 0].T[0],
                     'breakfix': ii_sess_pro['break_fix'][0, 0].T[0],
                     'prim_sacc': ii_sess_pro['prim_sacc'][0, 0].T[0],
                     'small_sacc': ii_sess_pro['small_sacc'][0, 0].T[0],
                     'large_error': ii_sess_pro['large_error'][0, 0].T[0]
                    }
        this_prodf = pd.DataFrame(pro_data)

        anti_data = {'subjID': np.full((numTrials_anti,), subjIDs[ii]),
                     'day': np.full((numTrials_anti,), days[dd]),
                      'tnum': ii_sess_anti['t_num'][0, 0].T[0],
                     'tms': np.full((numTrials_anti,), tms_status),
                     'ispro': np.full((numTrials_anti), 0),
                     'instimVF': ii_sess_anti['stimVF'][0, 0].T[0],
                     'isacc_err': ii_sess_anti['i_sacc_err'][0, 0].T[0],
                     'fsacc_err': ii_sess_anti['f_sacc_err'][0, 0].T[0],
                     'isacc_rt': ii_sess_anti['i_sacc_rt'][0, 0].T[0],
                     'fsacc_rt': ii_sess_anti['f_sacc_rt'][0, 0].T[0],
                     'breakfix': ii_sess_anti['break_fix'][0, 0].T[0],
                     'prim_sacc': ii_sess_anti['prim_sacc'][0, 0].T[0],
                     'small_sacc': ii_sess_anti['small_sacc'][0, 0].T[0],
                     'large_error': ii_sess_anti['large_error'][0, 0].T[0]
                    }
        this_antidf = pd.DataFrame(anti_data)

        if 'master_df' in globals():
            master_df = pd.concat([master_df, this_prodf, this_antidf])
        else:
            master_df = pd.concat([this_prodf, this_antidf])
        print()

# Flag trials for rejection: no primary saccade or a large saccade error
master_df['rejtrials'] = (master_df['prim_sacc']==0)+(master_df['breakfix']==1)*1
master_df['typesum'] = master_df['ispro'] + master_df['instimVF']  #pro-intoVF: 2, pro-outVF: 1; anti-intoVF: 0; anti-outVF: -1
conditions = [
    master_df['typesum'] == 2,
    master_df['typesum'] == 1,
    master_df['typesum'] == 0,
    master_df['typesum'] == -1
]
vals = ['pro_intoVF', 'pro_outVF', 'anti_intoVF', 'anti_outVF']
master_df['trial_type'] = np.select(conditions, vals)


    





#p['phosphene'] = p['data'] + '/phosphene_data/sub' + subjID
#p['mgs'] = p['data'] + '/mgs_data/sub' + subjID



# # df_tms = df_tms['i_sacc_err'].replace([np.inf, -np.inf], np.nan, inplace = True)
# # df_notms = df_notms['i_sacc_err'].replace([np.inf, -np.inf], np.nan, inplace = True)
# # df_tms = df_tms['f_sacc_err'].replace([np.inf, -np.inf], np.nan, inplace = True)
# # df_notms = df_notms['f_sacc_err'].replace([np.inf, -np.inf], np.nan, inplace = True)

# df_tms_goodtrials = df_tms[df_tms['rejtrials'] == 0 & df_tms['i_sacc_err'].notna() & df_tms['f_sacc_err'].notna()]
# df_notms_goodtrials = df_notms[df_notms['rejtrials'] == 0 & df_notms['i_sacc_err'].notna() & df_notms['f_sacc_err'].notna()]
# df_tms_goodtrials = df_tms_goodtrials[(((df_tms_goodtrials['i_sacc_err'] - df_tms_goodtrials['i_sacc_err'].mean()) 
#                 / df_tms_goodtrials['i_sacc_err'].std()).abs() < 3) & (((df_tms_goodtrials['f_sacc_err'] - 
#                 df_tms_goodtrials['f_sacc_err'].mean())  / df_tms_goodtrials['f_sacc_err'].std()).abs() < 3)]
# df_notms_goodtrials = df_notms_goodtrials[(((df_notms_goodtrials['i_sacc_err'] - df_notms_goodtrials['i_sacc_err'].mean()) 
#                 / df_notms_goodtrials['i_sacc_err'].std()).abs() < 3) & (((df_notms_goodtrials['f_sacc_err'] - 
#                 df_notms_goodtrials['f_sacc_err'].mean())  / df_notms_goodtrials['f_sacc_err'].std()).abs() < 3)]

# cat_order_trial_type = ['prointoVF', 'antiintoVF', 'prooutVF', 'antioutVF']
# cat_order_pro_anti = ['pro', 'anti']
# cat_order_into_away = ['into', 'away']

# print('No TMS prointoVF: ', df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'prointoVF'].shape)
# print('No TMS prooutVF: ', df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'prooutVF'].shape)
# print('TMS prointoVF: ', df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF'].shape)
# print('TMS prooutVF: ', df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF'].shape)
# print('No TMS antiintoVF: ', df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'antiintoVF'].shape)
# print('No TMS antioutVF: ', df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'antioutVF'].shape)
# print('TMS antiintoVF: ', df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF'].shape)
# print('TMS antioutVF: ', df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF'].shape)
# # Stats
# # f_value, p_value = f_oneway(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'prointoVF']['i_sacc_err'],
# #                     df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'antiintoVF']['i_sacc_err'],
# #                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['i_sacc_err'],
# #                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['i_sacc_err'],
# #                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['i_sacc_err'],
# #                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['i_sacc_err'])
# # print(f'One-way ANOVA for i_sacc_err gives F = {f_value}, p = {p_value}')
# # f_value, p_value = f_oneway(df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'prointoVF']['f_sacc_err'],
# #                     df_notms_goodtrials[df_notms_goodtrials['trial_type'] == 'antiintoVF']['f_sacc_err'],
# #                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prointoVF']['f_sacc_err'],
# #                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antiintoVF']['f_sacc_err'],
# #                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'prooutVF']['f_sacc_err'],
# #                     df_tms_goodtrials[df_tms_goodtrials['trial_type'] == 'antioutVF']['f_sacc_err'])
# # print(f'One-way ANOVA for f_sacc_err gives F = {f_value}, p = {p_value}')


# # df_concat = pd.concat([df_tms_goodtrials, df_notms_goodtrials])
# # tukey = pairwise_tukeyhsd(endog=df_concat['i_sacc_err'], groups=df_concat['trial_type'], alpha=0.05)
# # print('i_sacc_err')
# # print(tukey)
# # tukey = pairwise_tukeyhsd(endog=df_concat['f_sacc_err'], groups=df_concat['trial_type'], alpha=0.05)
# # print('f_sacc_err')
# # print(tukey)

# # Plotting figures
# plt.rc('ytick', labelsize = 12)
# groups_name = ['compound', 'trial_type', 'pro_anti', 'into_away']

# metrics = ['i_sacc_err', 'f_sacc_err']
# for gg in groups_name:
#     for metric in metrics:
#         X1, X2, x_tick_pos, x_label_names, leg_names, LIMS, Y1, Y2, Yerr1, Yerr2, fname = generate_Y(df_notms_goodtrials, 
#                                 df_tms_goodtrials, gg, metric)
#         generate_plot(subjID, metric, X1, X2, Y1, Y2, Yerr1, Yerr2, leg_names, LIMS, 
#                     x_tick_pos, x_label_names, direct, fname)


