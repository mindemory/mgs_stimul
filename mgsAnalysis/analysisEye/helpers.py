import numpy as np
import pandas as pd

def rotate_to_zero(df):
    TarTheta = np.arctan2(df['TarY'], df['TarX'])
    # Initialize columns to store rotated anlges
    df['TarX_rotated'] = np.zeros(len(df['TarX']))
    df['TarY_rotated'] = np.zeros(len(df['TarX']))
    df['isaccX_rotated'] = np.zeros(len(df['TarX']))
    df['isaccY_rotated'] = np.zeros(len(df['TarX']))
    df['fsaccX_rotated'] = np.zeros(len(df['TarX']))
    df['fsaccY_rotated'] = np.zeros(len(df['TarX']))

    xcols = ['TarX', 'isaccX', 'fsaccX']
    ycols = ['TarY', 'isaccY', 'fsaccY']
    for ii in range(len(TarTheta)):
        # Get angle for target and corresponding rotation matrix
        this_angle = -1 * TarTheta[ii]
        rotation_matrix = np.array([[np.cos(this_angle), -np.sin(this_angle)],
                                    [np.sin(this_angle), np.cos(this_angle)]])
        for idx in range(len(xcols)):
            x = df.loc[ii, [xcols[idx]]]
            y = df.loc[ii, [ycols[idx]]]
            input_points = np.vstack(x, y)
            rotated_points = np.dot(rotation_matrix, input_points)
            df.loc[ii, [xcols[idx] + '_rotated']] = rotated_points[0]
            df.loc[ii, [ycols[idx] + '_rotated']] = rotated_points[1]
    return df