import numpy as np
import pandas as pd
from scipy.stats import circmean

def rotate_to_zero(df):
    TarTheta = np.arctan2(df['TarY'], df['TarX'])

    rotated_cols = ['TarX_rotated', 'TarY_rotated', 'isaccX_rotated', 'fsaccX_rotated', 'fsaccY_rotated']
    for col in rotated_cols:
        df[col] = 0.0
    
    for idx in df.index:
        rotation_matrix = np.array(
            [
                [np.cos(-TarTheta[idx]), -np.sin(-TarTheta[idx])],
                [np.sin(-TarTheta[idx]), np.cos(-TarTheta[idx])]
            ]
        )
    for col_prefix in ['Tar', 'isacc', 'fsacc']:
        original_points = np.array([df.at[idx, f'{col_prefix}X'], df.at[idx, f'{col_prefix}Y']])
        rotated_points = rotation_matrix.dot(original_points)
        df.at[idx, f'{col_prefix}X_rotated'] = rotated_points[0]
        df.at[idx, f'{col_prefix}Y_rotated'] = rotated_points[1]
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
    
    tot_trs = 1000
    
    subjIDs = df['subjID'].unique()
    instim_idx = np.empty((len(subjIDs), tot_trs)) # num columns here is hard-coded, this is outright stupid!
    outstim_idx = np.empty((len(subjIDs), tot_trs))
    instim_mean_theta = np.zeros((len(subjIDs), ))
    outstim_mean_theta = np.zeros((len(subjIDs), ))
    instim_theta_range = np.zeros((len(subjIDs), ))
    outstim_theta_range = np.zeros((len(subjIDs, )))

    for ss in range(len(subjIDs)):
        this_subjID = subjIDs[ss]
        inidx = df.index[(df['instimVF']==1) & (df['subjID'] == this_subjID)]
        outidx = df.index[(df['instimVF']==0) & (df['subjID'] == this_subjID)]
        instim_idx[ss, 1:len(inidx)] = inidx
        outstim_idx[ss, 1:len(outidx)] = outidx 
        instim_mean_theta[ss] = circmean(df.loc[inidx, ['TarTheta']], high=np.pi, low=-np.pi)
        outstim_mean_theta[ss] = circmean(df.loc[outidx, ['TarTheta']], high=np.pi, low=-np.pi)
        instim_theta_range[ss] = compute_angular_range(df.loc[inidx, ['TarTheta']])
        outstim_theta_range[ss] = compute_angular_range(df.loc[outidx, ['TarTheta']])
    
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

def compute_errors(df, df_all5, sub_list, metric):
    mean_errors_df = pd.DataFrame(index=sub_list)
    std_errors_df = pd.DataFrame(index=sub_list)
    for sub in sub_list:
        for day in range(1, 6):
            df_sub_day = df[(df['subjID'] == sub) & (df['day'] == day)] if day < 4 else df_all5[(df_all5['subjID'] == sub) & (df_all5['day'] == day)]
            if day < 4:
                max_run = 10
            elif day == 4:
                max_run = 6
            elif day == 5:
                max_run = 7
            for rnum in range(1, max_run+1):
                if rnum in df_sub_day['rnum'].unique():
                    mean_errors_df.at[sub, f"Day {day} Block {rnum}"] = df_sub_day[df_sub_day['rnum'] == rnum][metric].mean()
                    std_error = df_sub_day[df_sub_day['rnum'] == rnum][metric].std() / np.sqrt(df_sub_day[df_sub_day['rnum'] == rnum].shape[0])
                    std_errors_df.at[sub, f"Day {day} Block {rnum}"] = std_error
                else:
                    mean_errors_df.at[sub, f"Day {day} Block {rnum}"] = 0
                    std_errors_df.at[sub, f"Day {day} Block {rnum}"] = 0
    mean_errors_df.fillna(0, inplace=True)
    std_errors_df.fillna(0, inplace=True)
    return mean_errors_df, std_errors_df


def compute_tcount(df, df_all5, sub_list):
    mean_errors_df = pd.DataFrame(index=sub_list)
    for sub in sub_list:
        for day in range(1, 6):
            df_sub_day = df[(df['subjID'] == sub) & (df['day'] == day)] if day < 4 else df_all5[(df_all5['subjID'] == sub) & (df_all5['day'] == day)]
            if day < 4:
                max_run = 10
            elif day == 4:
                max_run = 6
            elif day == 5:
                max_run = 7
            for rnum in range(1, max_run+1):
                if rnum in df_sub_day['rnum'].unique():
                    mean_errors_df.at[sub, f"Day {day} Block {rnum}"] = df_sub_day[df_sub_day['rnum'] == rnum]['tnum'].count()
                else:
                    mean_errors_df.at[sub, f"Day {day} Block {rnum}"] = 0
    mean_errors_df.fillna(0, inplace=True)
    return mean_errors_df