# Load the modules
from scipy.io import loadmat
import numpy as np
import pandas as pd
import os

# Hide deprecation warnings!
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 

import socket
hostname = socket.gethostname()

from helpers import rotate_to_zero, rotate_to_scale

p = {}
if hostname == 'syndrome' or hostname == 'zod.psych.nyu.edu' or hostname == 'zod':
    p['datc'] =  '/d/DATC/datc/MD_TMS_EEG'
else:
    p['datc'] =  '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/MD_TMS_EEG'
p['data'] = p['datc'] + '/data'
p['analysis'] = p['datc'] + '/analysis'
p['meta'] = p['datc'] + '/analysis/meta_analysis'
p['df_fname'] = p['meta'] + '/master_df.csv'
if not os.path.exists(p['meta']):
    os.makedirs(p['meta'])

if os.path.exists(p['df_fname']):
    print('Loading existing dataframe! If this is not desired, delete the current mater_df.csv')
    master_df = pd.read_csv(p['df_fname'])
else:
    print('Creating a new dataframe.')
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
        day_dirs = [dirname for dirname in sorted(os.listdir(subjdir)) if dirname.startswith("day")]
        days = []
        for dd in range(len(day_dirs)):
            days.append(int(day_dirs[dd][-2:]))
            daydir = subjdir + '/' + day_dirs[dd] # Path to daydir for current subject
            print(f'Running subj = {subjIDs[ii]}, day = {days[dd]}')

            # Check if this was a TMS session
            phosphene_data_path = p['data'] + '/phosphene_data/' + sub_dirs[ii]
            taskMapfilename = phosphene_data_path + '/taskMap_' + sub_dirs[ii] + '_' + day_dirs[dd] + '_antitype_mirror.mat'
            taskMap = loadmat(taskMapfilename)['taskMap']
            tms_status = taskMap[0, 0]['TMScond'][0][0]
            
            # Load the ii_sess files
            sessfName = daydir + '/ii_sess_' + sub_dirs[ii] + '_' + day_dirs[dd] + '.mat'
            ii_sess = loadmat(sessfName)['ii_sess']
            numTrials_pro = np.sum(ii_sess['ispro'][0, 0] == 1)
            numTrials_anti = np.sum(ii_sess['ispro'][0, 0] == 0)
            total_trials = numTrials_pro + numTrials_anti
            print(f"Trial-count: pro = {numTrials_pro}, anti = {numTrials_anti}")
            sess_data = {'subjID': np.full((total_trials,), subjIDs[ii]),
                        'day': np.full((total_trials,), days[dd]),
                        'tnum': ii_sess['t_num'][0, 0].T[0],
                        'rnum': ii_sess['r_num'][0, 0].T[0],
                        'istms': ii_sess['istms'][0, 0].T[0], # 1 if TMS is on
                        'ispro': ii_sess['ispro'][0, 0].T[0], # 1 if block was pro
                        'instimVF': ii_sess['instimVF'][0, 0].T[0], # 1 if saccade is in VF
                        # Trial flags
                        'bad_drift_correct': ii_sess['bad_drift_correct'][0, 0].T[0], # Flag 11
                        'bad_calibration': ii_sess['bad_calibration'][0, 0].T[0], # Flag 12
                        'breakfix': ii_sess['break_fix'][0, 0].T[0], # Flag 13
                        'no_prim_sacc': ii_sess['no_prim_sacc'][0, 0].T[0], # Flag 20
                        'small_sacc': ii_sess['small_sacc'][0, 0].T[0], # Flag 21
                        'large_error': ii_sess['large_error'][0, 0].T[0], # Flag 22
                        'rejtrials': ii_sess['rejtrials'][0, 0].T[0], # Flags 20 and 22, can be updated here directly
                        # Target and eye end-points
                        'TarX': ii_sess['targ'][0, 0][:, 0].T,
                        'TarY': ii_sess['targ'][0, 0][:, 1].T,
                        'isaccX': ii_sess['i_sacc_raw'][0, 0][:, 0].T,
                        'isaccY': ii_sess['i_sacc_raw'][0, 0][:, 1].T,
                        'fsaccX': ii_sess['f_sacc_raw'][0, 0][:, 0].T,
                        'fsaccY': ii_sess['f_sacc_raw'][0, 0][:, 1].T,
                        # errors added
                        'isacc_err': ii_sess['i_sacc_err'][0, 0].T[0], # raw euclidean distance error wrt target for isacc
                        'fsacc_err': ii_sess['f_sacc_err'][0, 0].T[0], # raw euclidean distance error wrt target for fsacc
                        'isacc_theta_err': ii_sess['isacc_theta_err'][0, 0].T[0], # angular error: isacc - targ
                        'fsacc_theta_err': ii_sess['fsacc_theta_err'][0, 0].T[0], # angular error: fsacc - targ
                        'corrected_theta_err': ii_sess['corrected_theta_err'][0, 0].T[0], # angular error: fsacc - isacc
                        'isacc_radius_err': ii_sess['isacc_radius_err'][0, 0].T[0], # radial error: isacc - targ 
                        'fsacc_radius_err': ii_sess['fsacc_radius_err'][0, 0].T[0], # radial error: fsacc - targ
                        'corrected_radius_err': ii_sess['corrected_radius_err'][0, 0].T[0], # radial error: fsacc - isacc
                        'nsacc': ii_sess['n_sacc'][0, 0].T[0],
                        #'calib_err': ii_sess['calib_err'][0, 0].T[0],
                        # Reaction times added
                        'isacc_rt': ii_sess['i_sacc_rt'][0, 0].T[0], # RT for isacc wrt response epoch start
                        'fsacc_rt': ii_sess['f_sacc_rt'][0, 0].T[0], # RT for fsacc wrt response epoch start
                        # Velocities
                        'isacc_peakvel': ii_sess['i_sacc_peakvel'][0, 0].T[0],
                        'fsacc_peakvel': ii_sess['f_sacc_peakvel'][0, 0].T[0],
                        }
            this_sess_df = pd.DataFrame(sess_data)
            if 'master_df' in globals():
                master_df = pd.concat([master_df, this_sess_df])
            else:
                master_df = this_sess_df
            print()

    master_df['trial_type'] = ''
    master_df.loc[(master_df['ispro'] == 1) & (master_df['instimVF'] == 1), 'trial_type'] = 'pro_intoVF'
    master_df.loc[(master_df['ispro'] == 1) & (master_df['instimVF'] == 0), 'trial_type'] = 'pro_outVF'
    master_df.loc[(master_df['ispro'] == 0) & (master_df['instimVF'] == 1), 'trial_type'] = 'anti_intoVF'
    master_df.loc[(master_df['ispro'] == 0) & (master_df['instimVF'] == 0), 'trial_type'] = 'anti_outVF'

    master_df['TMS_condition'] = ''
    master_df.loc[master_df['istms'] == 0, 'TMS_condition'] = 'No TMS'
    master_df.loc[(master_df['istms'] == 1) & (master_df['instimVF'] == 1), 'TMS_condition'] = 'TMS intoVF'
    master_df.loc[(master_df['istms'] == 1) & (master_df['instimVF'] == 0), 'TMS_condition'] = 'TMS outVF'
    master_df = master_df.reset_index(drop = True)
    #master_df, angular_df = rotate_to_scale(master_df)
    #master_df = rotate_to_zero(master_df)
    master_df.to_csv(p['df_fname'], index = False)