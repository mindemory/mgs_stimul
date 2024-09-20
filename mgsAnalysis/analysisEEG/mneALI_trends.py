import os, sys, mne, socket, time
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from nilearn import plotting
from itertools import product

from initialization import load_paths
from preprocFuncs import getRawData, getTrials, runTGA, runALI
# from plotters import plotPower, plotRSA, plotDiffRSA
from decodeHelpers import *

def main(subjID):
    # subjID = int(sys.argv[1])
    master_df =  pd.read_csv('/d/DATD/datd/MD_TMS_EEG/analysis/meta_analysis/master_df_calib.csv')
    day = master_df[(master_df['subjID'] == subjID) & (master_df['istms']==0)]['day'].unique()[0]

    master_df['trlIdx'] = (master_df['rnum'] - 1) * 40 + master_df['tnum']
    # Select data for this subejct for targets inside PF only for prosaccade blocks
    thisDF = master_df[(master_df['subjID'] == subjID) & (master_df['instimVF']==1) & (master_df['istms']==0) & (master_df['ispro']==1)]
    thisHemi = thisDF['hemistimulated'].unique()[0]
    thisIERR = thisDF['isacc_err']
    qt_ERR = np.quantile(thisIERR[~np.isnan(thisIERR)], [1, 0.75])
    trlIdx_good = thisDF[thisDF['isacc_err'] < qt_ERR[0]]['trlIdx'] - 1
    trlIdx_bad = thisDF[thisDF['isacc_err'] > qt_ERR[1]]['trlIdx'] - 1

    p = load_paths(subjID, day)
    # Load behavioral data
    behav_df = master_df[(master_df['subjID'] == subjID) & (master_df['day'] == day)]
    # Load raw data
    raw_data = getRawData(p)

    # Define events
    events, tah = mne.events_from_annotations(raw_data)
    events_dict = {
        'BlockStart': 1001,
        'Fixation': 1,
        'Delay1': 2,
        'Delay2': 3,
        'Response': 4,
        'Feedback': 6,
        'ITI': 7,
        'BlockEnd': 8,
    }
    trl_events = {
        'pro_inPF': 11,
        'pro_outPF': 12,
        'anti_inPF': 13,
        'anti_outPF': 14
    }

    # Define electrodes of interest
    left_occ_elecs = ['O1', 'PO3', 'PO7', 'P1', 'P3', 'P7']
    right_occ_elecs = ['O2', 'PO4', 'PO8', 'P2', 'P4', 'P8']
    left_par_elecs = ['P7', 'P5', 'P3', 'CP5', 'CP3', 'CP1', 'C5', 'C3', 'C1']
    right_par_elecs = ['P8', 'P6', 'P4', 'CP6', 'CP4', 'CP2', 'C6', 'C4', 'C2']

    left_elecs = ['O1', 'PO3', 'PO7', 'P1', 'P3', 'P7', 'P5', 'CP5', 'CP3', 'CP1', 'C5', 'C3', 'C1']
    right_elecs = ['O2', 'PO4', 'PO8', 'P2', 'P4', 'P8', 'P6', 'CP6', 'CP4', 'CP2', 'C6', 'C4', 'C2']

    left_occ_elecs = [elec for elec in left_occ_elecs if elec in raw_data.ch_names]
    right_occ_elecs = [elec for elec in right_occ_elecs if elec in raw_data.ch_names]
    left_par_elecs = [elec for elec in left_par_elecs if elec in raw_data.ch_names]
    right_par_elecs = [elec for elec in right_par_elecs if elec in raw_data.ch_names]
    left_elecs = [elec for elec in left_elecs if elec in raw_data.ch_names]
    right_elecs = [elec for elec in right_elecs if elec in raw_data.ch_names]

    # Epoch data
    epochData = mne.Epochs(raw_data, events, event_id=trl_events, tmin=-1, tmax=4.5, baseline=None, preload=True)
    epochDataBasecorr = mne.Epochs(raw_data, events, event_id=trl_events, tmin=-1, tmax=4.5, baseline=(-1, 0), preload=True)

    freq_band = 'alpha'

    if thisHemi == 'Left':
        inElecs = right_occ_elecs
        outElecs = left_occ_elecs
    else:
        inElecs = left_occ_elecs
        outElecs = right_occ_elecs

    t_array = epochData.times
    ALI_good, ALI_bad = runALI(epochData, inElecs, outElecs, freq_band, trlIdx_good, trlIdx_bad)

    return ALI_good, ALI_bad, t_array

if __name__ == '__main__':
    ALI_good, ALI_bad, t_array = main()
