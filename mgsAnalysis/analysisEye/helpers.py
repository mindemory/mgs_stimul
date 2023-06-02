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


def rotate_to_scale(df):
    TarTheta = np.arctan2(df['TarY'], df['TarX'])
    df['TarTheta'] = TarTheta
    df['TarRadius'] = np.sqrt(df['TarX']**2+df['TarY']**2)
    df['isaccTheta'] = np.arctan2(df['isaccY'], df['isaccX'])
    df['isaccRadius'] = np.sqrt(df['isaccX']**2+df['isaccY']**2)
    df['fsaccTheta'] = np.arctan2(df['fsaccY'], df['fsaccX'])
    df['fsaccRadius'] = np.sqrt(df['fsaccX']**2+df['fsaccY']**2)
    subjIDs = df['subjID'].unique()
    instim_idx = np.zeros((len(subjIDs), 600))
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
        instim_theta_range[ss] = df.loc[instim_idx[ss, :], ['TarTheta']].max() - df.loc[instim_idx[ss, :], ['TarTheta']].min()
        outstim_theta_range[ss] = df.loc[outstim_idx[ss, :], ['TarTheta']].max() - df.loc[outstim_idx[ss, :], ['TarTheta']].min()

    # Initialize columns to store rotated anlges
    xcols = ['TarX', 'isaccX', 'fsaccX']
    ycols = ['TarY', 'isaccY', 'fsaccY']
    angluarcols = ['TarTheta', 'isaccTheta', 'fsaccTheta']
    radialcols = ['TarRadius', 'isaccRadius', 'fsaccRadius']
    new_cols = ['TarX_rotated_only', 'TarY_rotated_only', 'isaccX_rotated_only', 'isaccY_rotated_only', 'fsaccX_rotated_only', 'fsaccY_rotated_only']
    for col in new_cols:
        df[col] = 0
    
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
        for idx in range(len(xcols)):
            
            x = df.loc[ii, [xcols[idx]]][0] + radial_error * np.cos(df.loc[ii, [angluarcols[idx]]][0])
            y = df.loc[ii, [ycols[idx]]][0] + radial_error * np.sin(df.loc[ii, [angluarcols[idx]]][0])
            #print(x, y)
            input_points = np.vstack((x, y))
            #print(input_points)
            rotated_points = np.dot(rotation_matrix, input_points)
            df.loc[ii, [xcols[idx] + '_rotated_only']] = rotated_points[0]
            df.loc[ii, [ycols[idx] + '_rotated_only']] = rotated_points[1]
    for iddx in range(len(xcols)):
        df[radialcols[iddx] + '_rotated_only'] = np.sqrt(df[xcols[iddx] + '_rotated_only']**2 + df[ycols[iddx] + '_rotated_only']**2)
        df[angluarcols[iddx] + '_rotated_only'] = np.arctan2(df[ycols[iddx] + '_rotated_only'], df[xcols[iddx] + '_rotated_only']) + np.pi
    
    angular_df = pd.DataFrame({'subjID': subjIDs, 'instim_mean_theta': instim_mean_theta, 'outstim_mean_theta': outstim_mean_theta, 'instim_theta_range': instim_theta_range,
                              'outstim_theta_range': outstim_theta_range})
    return df, angular_df

def variance_error_summary(df):
    subjIDs = df['subjID'].unique()
    new_cols = ['isacc_err_rot', 'fsacc_err_rot', 'isacc_theta_rot', 'fsacc_theta_rot']
    df['isacc_err_rot'] = (df['isaccX_rotated_only']-df['TarX_rotated_only'])**2 + (df['isaccY_rotated_only']-df['TarY_rotated_only'])**2
    df['fsacc_err_rot'] = (df['fsaccX_rotated_only']-df['TarX_rotated_only'])**2 + (df['fsaccY_rotated_only']-df['TarY_rotated_only'])**2
    df['isacc_theta_rot'] = df['isaccTheta_rotated_only'] - df['TarTheta_rotated_only']
    df['fsacc_theta_rot'] = df['fsaccTheta_rotated_only'] - df['TarTheta_rotated_only']
    for cc in new_cols:
        df[cc + '_normed'] = 0

    for ss in range(len(subjIDs)):
        subj_df = df[df['subjID'] == subjIDs[ss]]
        subj_idx = df.index[df['subjID'] == subjIDs[ss]]
        this_subj_norm_factor = subj_df['TarTheta_rotated_only'].max() - subj_df['TarTheta_rotated_only'].min()
        print(subjIDs[ss], this_subj_norm_factor)
        for cc in new_cols:
            df.loc[subj_idx, [cc + '_normed']] = df.loc[subj_idx, [cc]]/this_subj_norm_factor
    return df