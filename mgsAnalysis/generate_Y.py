import numpy as np
import pandas as pd
from scipy.stats import sem
def generate_Y(df1, df2, variable, error_measure):
    if variable == 'trial_type':
        X1 = [0.3, 0.8, 1.3, 1.8]
        Y1 = [np.median(df1[df1['trial_type'] == 'prointoVF'][error_measure]),
            np.median(df1[df1['trial_type'] == 'prooutVF'][error_measure]),
            np.median(df2[df2['trial_type'] == 'prointoVF'][error_measure]),
            np.median(df2[df2['trial_type'] == 'prooutVF'][error_measure])]
        Y2 = [np.median(df1[df1['trial_type'] == 'antiintoVF'][error_measure]),
            np.median(df1[df1['trial_type'] == 'antioutVF'][error_measure]),
            np.median(df2[df2['trial_type'] == 'antiintoVF'][error_measure]),
            np.median(df2[df2['trial_type'] == 'antioutVF'][error_measure])]
        Yerr1 = [sem(df1[df1['trial_type'] == 'prointoVF'][error_measure]),
            sem(df1[df1['trial_type'] == 'prooutVF'][error_measure]),
            sem(df2[df2['trial_type'] == 'prointoVF'][error_measure]),
            sem(df2[df2['trial_type'] == 'prooutVF'][error_measure])]
        Yerr2 = [sem(df1[df1['trial_type'] == 'antiintoVF'][error_measure]),
            sem(df1[df1['trial_type'] == 'antioutVF'][error_measure]),
            sem(df2[df2['trial_type'] == 'antiintoVF'][error_measure]),
            sem(df2[df2['trial_type'] == 'antioutVF'][error_measure])]
        x_label_names = ['No TMS\n into VF', 'No TMS\n away VF', 'MGS into\n TMS VF', 'MGS away\n from TMS VF']
        leg_names = ['pro', 'anti']
    elif variable == 'pro_anti':
        X1 = [0.3, 0.8]
        Y1 = [np.median(df1[df1['pro_anti'] == 'pro'][error_measure]),
            np.median(df2[df2['pro_anti'] == 'pro'][error_measure])]
        Y2 = [np.median(df1[df1['pro_anti'] == 'anti'][error_measure]),
            np.median(df2[df2['pro_anti'] == 'anti'][error_measure])]
        Yerr1 = [sem(df1[df1['pro_anti'] == 'pro'][error_measure]),
            sem(df2[df2['pro_anti'] == 'pro'][error_measure])]
        Yerr2 = [sem(df1[df1['pro_anti'] == 'anti'][error_measure]),
            sem(df2[df2['pro_anti'] == 'anti'][error_measure])]
        x_label_names = ['No TMS', 'TMS']
        leg_names = ['pro', 'anti']
    elif variable == 'into_away':
        X1 = [0.3, 0.8]
        Y1 = [np.median(df1[df1['into_away'] == 'into'][error_measure]),
            np.median(df2[df2['into_away'] == 'into'][error_measure])]
        Y2 = [np.median(df1[df1['into_away'] == 'away'][error_measure]),
            np.median(df2[df2['into_away'] == 'away'][error_measure])]
        Yerr1 = [sem(df1[df1['into_away'] == 'into'][error_measure]),
            sem(df2[df2['into_away'] == 'into'][error_measure])]
        Yerr2 = [sem(df1[df1['into_away'] == 'away'][error_measure]),
            sem(df2[df2['into_away'] == 'away'][error_measure])]
        x_label_names = ['No TMS', 'TMS']
        leg_names = ['into VF', 'away VF']
    X2 = [round(x + 0.1, 1) for x in X1]
    X_sum = [sum(value) for value in zip(X1, X2)]
    x_tick_pos = [round(x/2, 1) for x in X_sum]
    LIMS_x = max(X2) + 0.2
    LIMS_y = max(max(Y1), max(Y2)) * 1.2
    LIMS = [LIMS_x, LIMS_y]
    print(Y1)
    print(Y2)
    fname = '/' + error_measure + variable + '.pdf'
    return X1, X2, x_tick_pos, x_label_names, leg_names, LIMS, Y1, Y2, Yerr1, Yerr2, fname