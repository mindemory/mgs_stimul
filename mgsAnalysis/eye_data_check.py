from scipy.io import loadmat
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 

subjID = '01'
day = 1
direct = {}
direct['datc'] =  '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc'
direct['data'] = direct['datc'] + '/data'
direct['analysis'] = direct['datc'] + '/analysis'
direct['Figures'] = direct['datc'] + '/Figures'
direct['phosphene'] = direct['data'] + '/phosphene_data/sub' + subjID
direct['mgs'] = direct['data'] + '/mgs_data/sub' + subjID
direct['day'] = direct['mgs'] + '/day' + f'{day:02d}'
direct['save'] = direct['analysis'] + '/sub' + subjID + '/day' + f'{day:02d}'

taskMapfilename = direct['phosphene'] + '/taskMap_sub' + subjID + '_day' + f'{day:02d}' + '.mat'
saveNamepro = direct['save'] + '/ii_sess_pro_sub' + subjID + '_day' + f'{day:02d}' + '.mat'
saveNameanti = direct['save'] + '/ii_sess_anti_sub' + subjID + '_day' + f'{day:02d}' + '.mat'

ii_sess_pro = loadmat(saveNamepro)
ii_sess_anti = loadmat(saveNameanti)

stimVF_pro = ii_sess_pro['ii_sess_pro']['stimVF'][0, 0]
stimVF_anti = ii_sess_anti['ii_sess_anti']['stimVF'][0, 0]
ispro = np.concatenate((np.ones(np.shape(stimVF_pro)[0]), -1*np.ones(np.shape(stimVF_anti)[0]))).astype(int)
stimVF = np.concatenate((stimVF_pro, stimVF_anti))

stimVF_pro = ii_sess_pro['ii_sess_pro']['excl_trial'][0, 0]
stimVF_anti = ii_sess_anti['ii_sess_anti']['excl_trial'][0, 0]

isacc_pro = ii_sess_pro['ii_sess_pro']['i_sacc_err'][0, 0]
isacc_anti = ii_sess_anti['ii_sess_anti']['i_sacc_err'][0, 0]
isacc = np.concatenate((isacc_pro, isacc_anti))
fsacc_pro = ii_sess_pro['ii_sess_pro']['f_sacc_err'][0, 0]
fsacc_anti = ii_sess_anti['ii_sess_anti']['f_sacc_err'][0, 0]
fsacc = np.concatenate((fsacc_pro, fsacc_anti))

prointoVF_idx = np.where(stimVF_pro == np.ones(stimVF_pro.shape))[0]
prooutVF_idx = np.where(stimVF_pro == np.zeros(stimVF_anti.shape))[0]
antiintoVF_idx = stimVF_pro.shape[0] + np.where(stimVF_anti == np.zeros(stimVF_anti.shape))[0]
antioutVF_idx = stimVF_pro.shape[0] + np.where(stimVF_anti == np.ones(stimVF_anti.shape))[0]

#df_maker = {'stimVF': stimVF.T, 'isacc': isacc.T}
#df = pd.DataFrame(df_maker)
df = pd.DataFrame(isacc, columns = ['i_sacc_err'])
df['f_sacc_err'] = fsacc
df['stimVF'] = stimVF
df['ispro'] = ispro
df['typesum'] = df['stimVF'] + df['ispro']
a = []
for ii in range(df['typesum'].shape[0]):
    if df['typesum'][ii] == 0:
        a.append('antioutVF')
    elif df['typesum'][ii] == -1:
        a.append('antiintoVF')
    elif df['typesum'][ii] == 1:
        a.append('prooutVF')
    elif df['typesum'][ii] == 2:
        a.append('prointoVF')
df['stimLoc'] = a

cat_order = ['prointoVF', 'prooutVF', 'antiintoVF', 'antioutVF']
plt.figure()
sns.boxplot(data = df, x = 'stimLoc', y = 'i_sacc_err', order = cat_order)
#sns.stripplot(data = df, x = 'stimLoc', y = 'i_sacc_err', palette = "husl", size = 5, order = cat_order)
plt.title('sub' + subjID + '_day' + f'{day:02d}')
plt.show()

# df = pd.DataFrame([isacc_prointoVF; isacc_prooutVF], 
#     columns = ["prointoVF", "prooutVF"])

# print(df.head())
