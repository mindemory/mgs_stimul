import os, sys, mne, socket, time
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from nilearn import plotting
from itertools import product

from initialization import load_paths
from preprocFuncs import getRawData, getTrials, runTGA
# from plotters import plotPower, plotRSA, plotDiffRSA
from decodeHelpers import *

def main():
    subjID = int(sys.argv[1])
    master_df =  pd.read_csv('/d/DATD/datd/MD_TMS_EEG/analysis/meta_analysis/master_df_calib.csv')
    day = master_df[(master_df['subjID'] == subjID) & (master_df['istms']==0)]['day'].unique()[0]

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

    elecs = left_occ_elecs+right_occ_elecs
    freq_band = 'alpha'
    # POWPHASE = ['pow', 'phase']
    # TYPECOND = ['byPF_pro', 'byPF_anti', 'byPF_stimin', 'byPF_respin', 'byTrlType']
    POWPHASE = ['pow']
    TYPECOND = ['byPF_pro']

    for pow_or_phase, typeCond in product(POWPHASE, TYPECOND):
        scores_mean, t_down = runTGA(epochData, elecs, freq_band, pow_or_phase, typeCond)
        np.savez(f"{p['EEGroot']}_{pow_or_phase}_{typeCond}.npy", scores_mean=scores_mean, t_array_down=t_down)

if __name__ == '__main__':
    main()
