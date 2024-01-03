import numpy as np
import pandas as pd

def add_metrics(df):
    '''
    This function computes additional metrics:
    i/f refers to initial and final saccade landing points
    i/f errX, errY: horizontal and vertical errors
    i/f err: Euclidean distance of saccade landing points from the target location
    i/f gain: Ratio of saccade vector to target vector
    eccentricity/polang: eccentricity and polar angle of the target from the center
    i/f pea: Percentage error in saccade amplitude, this was adopted from Muri et al., 1996
    i/f ang: Angular deviation of saccade landing point relative to the target point
    i/f theta: Angular difference between the error vector and the target vector
    i/f radial: Radial difference between the error vector and the target fector
    i/f tangential: Tangential difference between the error vector and the target vector
    '''
    # error vectors and magnitudes
    df['ierrX'] = df['isaccX'] - df['TarX']
    df['ierrY'] = df['isaccY'] - df['TarY']
    df['ferrX'] = df['fsaccX'] - df['TarX']
    df['ferrY'] = df['fsaccY'] - df['TarY']
    df['ierr'] = np.sqrt(df['ierrX']**2+df['ierrY']**2)
    df['ferr'] = np.sqrt(df['ferrX']**2+df['ferrY']**2)

    # Saccade gain and Percentage error in amplitude
    df['igain'] = (np.sqrt(df['isaccX']**2+df['isaccY']**2))/(np.sqrt(df['TarX']**2+df['TarY']**2))
    df['fgain'] = (np.sqrt(df['fsaccX']**2+df['fsaccY']**2))/(np.sqrt(df['TarX']**2+df['TarY']**2))
    df['eccentricity'] = np.sqrt(df['TarX']**2+df['TarY']**2)
    df['polang'] = np.arctan2(df['TarY'], df['TarX'])
    df['ipea'] = (df['ierr'] - df['eccentricity'])/df['eccentricity'] # percentage error in amplitude (Muri et al. 1996)
    df['fpea'] = (df['ferr'] - df['eccentricity'])/df['eccentricity'] # percentage error in amplitude (Muri et al. 1996)

    # Angular error
    df['iang'] = np.arctan2(df['isaccY'], df['isaccX']) - np.arctan2(df['TarY'], df['TarX'])
    df['iang'] = np.arctan2(np.sin(df['iang']), np.cos(df['iang']))
    df['iang'] = np.rad2deg(df['iang'])
    df['fang'] = np.arctan2(df['fsaccY'], df['fsaccX']) - np.arctan2(df['TarY'], df['TarX'])
    df['fang'] = np.arctan2(np.sin(df['fang']), np.cos(df['fang']))
    df['fang'] = np.rad2deg(df['fang'])

    # Radial and tangential errors
    itheta = np.arctan2(df['ierrY'], df['ierrX']) - df['polang']
    itheta = np.arctan2(np.sin(itheta), np.cos(itheta))
    df['itheta'] = np.rad2deg(itheta)
    df['iradial'] = df['ierr'] * np.cos(itheta)
    df['itangential'] = df['ierr'] * np.sin(itheta)

    ftheta = np.arctan2(df['ferrY'], df['ferrX']) - df['polang']
    ftheta = np.arctan2(np.sin(ftheta), np.cos(ftheta))
    df['ftheta'] = np.rad2deg(ftheta)
    df['fradial'] = df['ferr'] * np.cos(ftheta)
    df['ftangential'] = df['ferr'] * np.sin(ftheta)
    return df


def filter_data(df):
    # Replace more than one race to white
    df.loc[df['race'] == 'More than one', 'race'] = 'White'
    conds = [
        (df['day'].isin([1, 2, 3]) & (df['istms']==0)), 
        (df['day'].isin([1, 2, 3]) & (df['istms']==1)), 
        df['day'] == 4,             
        df['day'] == 5              
    ]
    choices = ['notms', 'middle', 'early', 'middle_dangit']
    df['TMS_time'] = np.select(conds, choices, default='unknown')

    # Removing trials that had timing issues
    buffer = 0.25  # 2.5% buffer
    conditions = (
        (df['initdur'].between(1 * (1 - buffer), 1 * (1 + buffer))) &
        (df['sampledur'].between(0.5 * (1 - buffer), 0.5 * (1 + buffer))) &
        (df['respdur'].between(0.85 * (1 - buffer), 0.85 * (1 + buffer))) &
        (df['feedbackdur'].between(0.8 * (1 - buffer), 0.8 * (1 + buffer))) &
        (
            ((df['day'].isin([1, 2, 3, 5])) & 
            (df['delay1dur'].between(2 * (1 - buffer), 2 * (1 + buffer))) & 
            (df['delay2dur'].between(2 * (1 - buffer), 2 * (1 + buffer)))) |
            ((df['day'] == 4) & 
            (df['delay1dur'].between(-1e-2, 1e-2)) & 
            (df['delay2dur'].between(4 * (1 - buffer), 4 * (1 + buffer))))
        )
    )

    original_shape = df.shape
    df = df[conditions].dropna()

    # Also remove trials with reaction times that are too small or too big
    df = df[(df['isacc_rt'] > 0.15) & (df['isacc_rt'] < 1.0) & (df['fsacc_rt'] < 1.0)]
    gstats_initial = df.groupby('subjID')['ierr'].agg(['mean', 'std'])
    gstats_final = df.groupby('subjID')['ferr'].agg(['mean', 'std'])
    gstats_initial['ierr_threshold'] = gstats_initial.apply(lambda x: min(x['mean'] + 3 * x['std'], 6), axis=1)
    gstats_final['ferr_threshold'] = gstats_final.apply(lambda x: min(x['mean'] + 3 * x['std'], 6), axis=1)

    df = df.merge(gstats_initial['ierr_threshold'], left_on='subjID', right_index=True)
    df = df.merge(gstats_final['ferr_threshold'], left_on='subjID', right_index=True)
    df = df[(df['ierr'] <= df['ierr_threshold']) & (df['ferr'] <= df['ferr_threshold'])]

    # Removing columns that will not be needed from here on:
    df = df.drop(columns = ['bad_drift_correct', 'bad_calibration', 'breakfix',
        'no_prim_sacc', 'small_sacc', 'large_error', 'rejtrials', 'initdur', 'sampledur',
        'delay1dur', 'delay2dur', 'respdur', 'feedbackdur', 'isacc_err', 'fsacc_err'])
    filtered_shape = df.shape
    print(f'Trials removed = {original_shape[0] - filtered_shape[0]} = {round((original_shape[0] - filtered_shape[0])*100/original_shape[0], 2)}% ')

    # Create a df for subjects that have all 5 days completed
    subject_counts = df.groupby('subjID')['day'].nunique()
    valid_subjects = subject_counts[subject_counts == 5].index
    df_all5 = df[df['subjID'].isin(valid_subjects)  & (df['ispro'] == 1)]
    return df, df_all5

def elim_subs_blocks(df1, df1_all5, df2, df2_all5, sub_rem):
    def remove_low_trial_blocks(df, sub_rem):
        # Remove specified subjects
        df = df[~df['subjID'].isin(sub_rem)]
        # Remove blocks with trials less than 25
        blocks_to_remove = df.groupby(['subjID', 'day', 'rnum']).filter(lambda x: x['tnum'].count() <= 25)[['subjID', 'day', 'rnum']].drop_duplicates()
        df = df[~df.set_index(['day', 'rnum']).index.isin(blocks_to_remove.set_index(['day', 'rnum']).index)]
        return df, blocks_to_remove


    # Remove blocks with low trial count and update summary
    df1, removed_blocks_df1 = remove_low_trial_blocks(df1, sub_rem)
    df1_all5, removed_blocks_df1_all5 = remove_low_trial_blocks(df1_all5, sub_rem)
    df2, removed_blocks_df2 = remove_low_trial_blocks(df2, sub_rem)
    df2_all5, removed_blocks_df2_all5 = remove_low_trial_blocks(df2_all5, sub_rem)

    # Print a summary of subjects and blocks that have been removed
    print(f"Removed subjects: {sub_rem}")
    print("Removed blocks:")
    print(removed_blocks_df1.reset_index(drop=True))

    return df1, df1_all5, df2, df2_all5