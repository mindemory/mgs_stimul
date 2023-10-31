import numpy as np
import pandas as pd
from scipy.stats import circmean

def rotate_to_zero(df):
    
    TarTheta = np.arctan2(df['TarY'], df['TarX'])
    df['TarTheta'] = TarTheta
    df['TarRadius'] = np.sqrt(df['TarX']**2+df['TarY']**2)
    df['isaccTheta'] = np.arctan2(df['isaccY'], df['isaccX'])
    df['isaccRadius'] = np.sqrt(df['isaccX']**2+df['isaccY']**2)
    df['fsaccTheta'] = np.arctan2(df['fsaccY'], df['fsaccX'])
    df['fsaccRadius'] = np.sqrt(df['fsaccX']**2+df['fsaccY']**2)
    # Initialize columns to store rotated anlges
    df['TarX_rotated'] = np.zeros(len(df['TarX']))
    df['TarY_rotated'] = np.zeros(len(df['TarX']))
    df['isaccX_rotated'] = np.zeros(len(df['TarX']))
    df['isaccY_rotated'] = np.zeros(len(df['TarX']))
    df['fsaccX_rotated'] = np.zeros(len(df['TarX']))
    df['fsaccY_rotated'] = np.zeros(len(df['TarX']))

    xcols = ['TarX', 'isaccX', 'fsaccX']
    ycols = ['TarY', 'isaccY', 'fsaccY']
    angluarcols = ['TarTheta', 'isaccTheta', 'fsaccTheta']
    for ii in range(len(TarTheta)):
        # Get angle for target and corresponding rotation matrix
        this_angle = -1 * TarTheta[ii]
        radial_error = np.max(df['TarRadius']) - df.loc[ii, ['TarRadius']][0]
        #radial_error = 0 - df.loc[ii, ['TarRadius']][0]
        
        rotation_matrix = np.array([[np.cos(this_angle), -np.sin(this_angle)],
                                    [np.sin(this_angle), np.cos(this_angle)]])
        for idx in range(len(xcols)):
            x = df.loc[ii, [xcols[idx]]] + radial_error * np.cos(df.loc[ii, [angluarcols[idx]]][0])
            y = df.loc[ii, [ycols[idx]]] + radial_error * np.sin(df.loc[ii, [angluarcols[idx]]][0])
            input_points = np.vstack((x, y))
            rotated_points = np.dot(rotation_matrix, input_points)
            df.loc[ii, [xcols[idx] + '_rotated']] = rotated_points[0]
            df.loc[ii, [ycols[idx] + '_rotated']] = rotated_points[1]
    return df

def compute_angular_range(angle_vals):
    # Created by Mrugank (06/03/2023) while on a 15 hour flight!
    # First step is making all angles positive
    #print(angle_vals[0])
    angle_vals = np.asarray(angle_vals.values)
    #print(angle_vals)
    angle_vals = angle_vals+np.pi 
    min_val = np.min(angle_vals)
    max_val = np.max(angle_vals)
    #print(min_val, max_val)
    if max_val - min_val < np.pi:
        # if the two are in the same hemicircle, then angular_width is simply the difference between the maximum and minimum
        angular_width = max_val - min_val
    else:
        idx_pi_plus = np.where(angle_vals>np.pi)
        angle_vals[idx_pi_plus] = -(2*np.pi - angle_vals[idx_pi_plus])
        min_rotated_val = np.min(angle_vals)
        max_rotated_val = np.max(angle_vals)
        angular_width = max_rotated_val - min_rotated_val
    return angular_width

def rotate_to_scale(df):
    metrics = ['Tar', 'isacc', 'fsacc']
    for mm in metrics:
        df[mm + 'Radius'] = np.sqrt(df[mm+'Y']**2 + df[mm+'X']**2)
        df[mm + 'Theta'] = np.arctan2(df[mm+'Y'], df[mm+'X'])
        # Initialize columns to store rotated anlges
        df[mm + 'X_rotated']=0
        df[mm + 'Y_rotated']=0
    
    subjIDs = df['subjID'].unique()
    instim_idx = np.zeros((len(subjIDs), 600)) # num columns here is hard-coded, this is outright stupid!
    outstim_idx = np.zeros((len(subjIDs), 600))
    instim_mean_theta = np.zeros((len(subjIDs), ))
    outstim_mean_theta = np.zeros((len(subjIDs), ))
    instim_theta_range = np.zeros((len(subjIDs), ))
    outstim_theta_range = np.zeros((len(subjIDs, )))

    for ss in range(len(subjIDs)):
        this_subjID = subjIDs[ss]
        instim_idx[ss, :] = df.index[(df['instimVF']==1) & (df['subjID'] == this_subjID)]
        outstim_idx[ss :] = df.index[(df['instimVF']==0) & (df['subjID'] == this_subjID)]
        instim_mean_theta[ss] = circmean(df.loc[instim_idx[ss, :], ['TarTheta']], high=np.pi, low=-np.pi)
        outstim_mean_theta[ss] = circmean(df.loc[outstim_idx[ss, :], ['TarTheta']], high=np.pi, low=-np.pi)
        instim_theta_range[ss] = compute_angular_range(df.loc[instim_idx[ss, :], ['TarTheta']])
        outstim_theta_range[ss] = compute_angular_range(df.loc[outstim_idx[ss, :], ['TarTheta']])
    
    for ii in range(len(df['TarTheta'])):
        subj_idx = np.where(subjIDs == df.loc[ii, ['subjID'][0]])[0][0]
        # Get angle for target and corresponding rotation matrix
        if ii in instim_idx[subj_idx, :]:
            this_angle = -1 * instim_mean_theta[subj_idx]
        elif ii in outstim_idx[subj_idx, :]:
            this_angle = -1 * outstim_mean_theta[subj_idx]
        radial_error = np.max(df['TarRadius']) - df.loc[ii, ['TarRadius']][0]
        rotation_matrix = np.array([[np.cos(this_angle), -np.sin(this_angle)],
                                    [np.sin(this_angle), np.cos(this_angle)]])
        for mm in metrics:
            
            x = df.loc[ii, [mm+'X']][0] + radial_error * np.cos(df.loc[ii, [mm+'Theta']][0])
            y = df.loc[ii, [mm+'Y']][0] + radial_error * np.sin(df.loc[ii, [mm+'Theta']][0])
            
            input_points = np.vstack((x, y))
            rotated_points = np.dot(rotation_matrix, input_points)
            df.loc[ii, [mm + 'X_rotated']] = rotated_points[0]
            df.loc[ii, [mm + 'Y_rotated']] = rotated_points[1]
    for mm in metrics:
        df[mm + 'Radius_rotated'] = np.sqrt(df[mm + 'Y_rotated']**2 + df[mm + 'X_rotated']**2)
        df[mm + 'Theta_rotated'] = np.arctan2(df[mm + 'Y_rotated'], df[mm + 'X_rotated']) + np.pi
    
    angular_df = pd.DataFrame({'subjID': subjIDs, 'instim_mean_theta': instim_mean_theta, 'outstim_mean_theta': outstim_mean_theta, 'instim_theta_range': instim_theta_range,
                              'outstim_theta_range': outstim_theta_range})
    return df, angular_df

def variance_error_summary(df):
    subjIDs = df['subjID'].unique()
    new_cols = ['isacc_err_rot', 'fsacc_err_rot', 'isacc_theta_rot', 'fsacc_theta_rot']
    df['isacc_err_rot'] = (df['isaccX_rotated']-df['TarX_rotated'])**2 + (df['isaccY_rotated']-df['TarY_rotated'])**2
    df['fsacc_err_rot'] = (df['fsaccX_rotated']-df['TarX_rotated'])**2 + (df['fsaccY_rotated']-df['TarY_rotated'])**2
    df['isacc_theta_rot'] = df['isaccTheta_rotated'] - df['TarTheta_rotated']
    df['fsacc_theta_rot'] = df['fsaccTheta_rotated'] - df['TarTheta_rotated']
    for cc in new_cols:
        #df[cc + '_normed'] = 0
        temp_normed = np.zeros((len(df['TarX']), 1))
        for ss in range(len(subjIDs)):
            subj_df = df[df['subjID'] == subjIDs[ss]]
            subj_idx = df.index[df['subjID'] == subjIDs[ss]]
            this_subj_norm_factor = subj_df['TarTheta_rotated'].max() - subj_df['TarTheta_rotated'].min()
            temp_normed[subj_idx] = df.loc[subj_idx, [cc]]/this_subj_norm_factor
            # print(subjIDs[ss], this_subj_norm_factor, len(subj_idx))
            # print(cc)
        df[cc + '_normed'] = temp_normed
    return df