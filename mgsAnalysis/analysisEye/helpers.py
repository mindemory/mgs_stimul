import numpy as np
import pandas as pd

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
    radiuscols = ['TarRadius', 'isaccRadius', 'fsaccRadius']
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
            #print(input_points)
            rotated_points = np.dot(rotation_matrix, input_points)
            df.loc[ii, [xcols[idx] + '_rotated']] = rotated_points[0]
            df.loc[ii, [ycols[idx] + '_rotated']] = rotated_points[1]
    return df