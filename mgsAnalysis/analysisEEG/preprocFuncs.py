import os, mne
import numpy as np
# from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
from multiprocessing import Pool, cpu_count
from scipy.signal import hilbert
from mne.decoding import (
    GeneralizingEstimator,
    GeneralizingEstimator,
    Vectorizer,
    cross_val_multiscore,
)
# Decoding tools
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler, MinMaxScaler

from sklearn.svm import SVC
from scipy.signal import hilbert
from decodeHelpers import gaussian_smooth_1d

montage = mne.channels.make_standard_montage("easycap-M1")

def autoRejectChans(data):
    thresh_qtl = 0.05
    numVars = 10
    var_winSize = data.get_data().shape[1] // numVars
    var_ch = []
    for start in range(0, data.get_data().shape[1], var_winSize):
        var_ch.append(np.var(data.get_data()[:, start:start+var_winSize], axis=1))
    mean_var = np.mean(var_ch, axis=0)
    
    quantiles_var = np.quantile(mean_var, [thresh_qtl, 1-thresh_qtl])
    for idx, chan in enumerate(data.ch_names):
        if mean_var[idx] < quantiles_var[0] or mean_var[idx] > quantiles_var[1]:
            data.info['bads'].append(chan)
    # Eliminate bad channels
    data.drop_channels(data.info['bads'])
    print(f'Dropped {len(data.info["bads"])} channels')
    return data
        

def getRawData(p):
    # List all the files in the directory
    f_list = os.listdir(p['EEGfiles'])
    f_list = [f for f in f_list if f.endswith('.vhdr')]
    if len(f_list) == 1:
        # raw_fpath = os.path.join(p['EEGpy'], f_list[0].replace('.vhdr', '.fif'))
        if os.path.exists(p['fif_path']):
            print(f"Loading pre-existing data ...")
            raw_data = mne.io.read_raw_fif(p['fif_path'], preload=True)
        else:
            print(f"Running pre-processing ...")
            raw_data = mne.io.read_raw_brainvision(p['EEGfiles'] + '/' + f_list[0], preload=True)
            raw_data.drop_channels(['LM', 'RM'])
            raw_data.set_montage(montage)


            # Adding ICA to raw data and removing blinks automatically using Fp1
            print(f"Running ICA ...")
            raw_filtered = raw_data.copy().filter(l_freq=1, h_freq=40, fir_design='firwin', verbose=False)
            ica = mne.preprocessing.ICA(n_components=20, random_state=42, max_iter=800)
            ica.fit(raw_filtered)
            eogblink_inds, _ = ica.find_bads_eog(raw_filtered, ch_name='Fp1', threshold=3, verbose=False)
            eogsaccade_inds, _ = ica.find_bads_eog(raw_filtered, ch_name='F7', threshold=3, verbose=False)
            ica.exclude = list(set(eogblink_inds) | set(eogsaccade_inds))
            ica.apply(raw_data)

            # raw_data.filter(l_freq=0.5, h_freq=55, verbose=False, n_jobs=-1)
            # raw_data = autoRejectChans(raw_data)
            raw_data.save(p['fif_path'], overwrite=False)
    return raw_data

def interp_trial(data, time_points, events, pulse_flag, interpolation_samples):
    from scipy.interpolate import interp1d
    from scipy.interpolate import PchipInterpolator
    from scipy.signal import savgol_filter
    for ii, event in enumerate(events):
        event_time, _, event_id = event
        if event_id == pulse_flag:
            # Find the time range for the current event
            start_sample = event_time
            end_sample = start_sample + interpolation_samples
            sample_mask = np.arange(start_sample, end_sample)

            # for channel in range(data.shape[0]):
            #     ts = data[channel, :]
            #     valid_idx = np.ones(ts.shape, dtype=bool)
            #     valid_idx[sample_mask] = False
            #     f = interp1d(time_points[valid_idx], ts[valid_idx], kind='cubic', fill_value='extrapolate')
            #     data[channel, sample_mask] = f(time_points[sample_mask])

            for channel in range(data.shape[0]):
                ts = data[channel, :]
                ts_smooth = savgol_filter(ts, 51, 3)
                valid_idx = np.ones(ts.shape, dtype=bool)
                valid_idx[sample_mask] = False
                f = PchipInterpolator(time_points[valid_idx], ts_smooth[valid_idx])
                data[channel, sample_mask] = f(time_points[sample_mask])
    return data


def remove_pulse(raw_data):
    from scipy.interpolate import interp1d
    pulse_flag = 3
    interpolation_window = 0.3
    sfreq = raw_data.info['sfreq']
    interpolation_samples = int(interpolation_window * sfreq)

    data = raw_data.get_data()
    time_points = raw_data.times

    events, tah = mne.events_from_annotations(raw_data)
    events_flag = events[events[:, 2] == pulse_flag]
    print(f"Found {len(events_flag)} pulse events")

    for event in events_flag:
        event_time, _, event_id = event
        if event_id == pulse_flag:
            # Find the time range for the current event
            start_sample = event_time
            end_sample = start_sample + interpolation_samples
            sample_mask_ts = np.arange(start_sample, end_sample)
            wider_mask = np.arange(start_sample - 1000, end_sample + 1000)
            sample_mask = np.arange(1000, end_sample - start_sample + 1000)

            for channel in range(data.shape[0]):
                chunk_data = data[channel, wider_mask]
                chunk_time = time_points[wider_mask]
                valid_idx = np.ones(chunk_data.shape, dtype=bool)
                valid_idx[sample_mask] = False
                f = interp1d(chunk_time[valid_idx], chunk_data[valid_idx], kind='cubic', fill_value='extrapolate')
                data[channel, sample_mask_ts] = f(time_points[sample_mask_ts])
    cleaned_raw = mne.io.RawArray(data, raw_data.info)
    return cleaned_raw


def getTrials(raw_data, events_dict, events):
    block_onset_id = events_dict['BlockOnset']
    block_end_id = events_dict['BlockEnd']
    # Find the start and end events
    startBlock_events = events[events[:, 2] == block_onset_id]
    endBlock_events = events[events[:, 2] == block_end_id]
    sampBuffer = 1000
    # Create custom epochs
    # block_epochs_list = []
    trials_list = []

    for blkIdx, startBlock_event in enumerate(startBlock_events):
        print(f"Running block {blkIdx + 1} of {len(startBlock_events)}")
        # Find the next end event after the current start event
        endBlock_event = endBlock_events[endBlock_events[:, 0] > startBlock_event[0]][0]

        # Create events_block to be used for trial definition
        events_block = events[(events[:, 0] > startBlock_event[0]) & (events[:, 0] < endBlock_event[0])]

        # Define the time window for the block epoch and epoch the block
        tminBlock = (startBlock_event[0] - raw_data.first_samp) / raw_data.info['sfreq']
        tmaxBlock = (endBlock_event[0] - raw_data.first_samp) / raw_data.info['sfreq']
        block = raw_data.copy().crop(tminBlock, tmaxBlock)
        # Apply a highpass filter to the block
        # Find the start and end events for each trial
        startTrial_events = events_block[events_block[:, 2] == events_dict['Fixation']]
        endTrial_events = events_block[events_block[:, 2] == events_dict['Feedback']]

        # for startTrial_event in startTrial_events:
        for trlIdx, startTrial_event in enumerate(startTrial_events):
            print(f"    Running trial {trlIdx + 1} of {len(startTrial_events)}")
            # Find the next end event after the current start event
            endTrial_event = endTrial_events[endTrial_events[:, 0] > startTrial_event[0]][0]

            # Define the time window for the trial epoch
            tminTrial = (startTrial_event[0] - sampBuffer - block.first_samp) / block.info['sfreq']
            tmaxTrial = (endTrial_event[0] + sampBuffer - block.first_samp) / block.info['sfreq']

            # Create the trial epoch
            trial = block.copy().crop(tminTrial, tmaxTrial)
            trials_list.append(trial)
    return trials_list


def RunRSA(data, behav_df, freqband, cond, typeElecs, trange=[0,4.5], baseCorr=True):
    if freqband == 'alpha':
        freqs = np.arange(8, 13, 0.5)
    elif freqband == 'beta':
        freqs = np.arange(14, 25, 0.5)
    n_cycles = freqs / 2

    if cond == 'byPF':
        cond1_trials = behav_df[behav_df['stimPF'] == 1].index
        cond2_trials = behav_df[behav_df['stimPF'] == 0].index
        condDict = {'inPF': cond1_trials, 'outPF': cond2_trials}
    elif cond == 'byOri':
        cond1_trials = behav_df[behav_df['oriCategory'] == 30].index
        cond2_trials = behav_df[behav_df['oriCategory'] == 60].index
        cond3_trials = behav_df[behav_df['oriCategory'] == 120].index
        cond4_trials = behav_df[behav_df['oriCategory'] == 150].index
        condDict = {'30': cond1_trials, '60': cond2_trials, '120': cond3_trials, '150': cond4_trials}
    elif cond == 'byOriandPF':
        cond1_trials = behav_df[(behav_df['oriCategory'] == 30) & (behav_df['stimPF'] == 1)].index
        cond2_trials = behav_df[(behav_df['oriCategory'] == 60) & (behav_df['stimPF'] == 1)].index
        cond3_trials = behav_df[(behav_df['oriCategory'] == 120) & (behav_df['stimPF'] == 1)].index
        cond4_trials = behav_df[(behav_df['oriCategory'] == 150) & (behav_df['stimPF'] == 1)].index
        cond5_trials = behav_df[(behav_df['oriCategory'] == 30) & (behav_df['stimPF'] == 0)].index
        cond6_trials = behav_df[(behav_df['oriCategory'] == 60) & (behav_df['stimPF'] == 0)].index
        cond7_trials = behav_df[(behav_df['oriCategory'] == 120) & (behav_df['stimPF'] == 0)].index
        cond8_trials = behav_df[(behav_df['oriCategory'] == 150) & (behav_df['stimPF'] == 0)].index
        condDict = {'30 inPF': cond1_trials, '60 inPF': cond2_trials, '120 inPF': cond3_trials, '150 inPF': cond4_trials,
                    '30 outPF': cond5_trials, '60 outPF': cond6_trials, '120 outPF': cond7_trials, '150 outPF': cond8_trials}
    elif cond == 'byOri_broad':
        cond1_trials = behav_df[(behav_df['oriCategory'] == 30) | (behav_df['oriCategory'] == 60)].index
        cond2_trials = behav_df[(behav_df['oriCategory'] == 120) | (behav_df['oriCategory'] == 150)].index
        condDict = {'30-60': cond1_trials, '120-150': cond2_trials}

    if typeElecs == 'occ_hemi':
        leftElecs = ['O1', 'PO3', 'PO7', 'P1', 'P3', 'P7']
        rightElecs = ['O2', 'PO4', 'PO8', 'P2', 'P4', 'P8']
    elif typeElecs == 'par_hemi':
        leftElecs = ['CP1', 'CP3', 'CP5', 'P1', 'P3', 'P5']
        rightElecs = ['CP2', 'CP4', 'CP6', 'P2', 'P4', 'P6']
    elif typeElecs == 'occ':
        Elecs = ['O1', 'PO3', 'PO7', 'P1', 'P3', 'P7', 'O2', 'PO4', 'PO8', 'P2', 'P4', 'P8']
    elif typeElecs == 'par':
        Elecs = ['CP1', 'CP3', 'CP5', 'P1', 'P3', 'P5', 'CP2', 'CP4', 'CP6', 'P2', 'P4', 'P6']

    data = {}

    if 'hemi' in typeElecs:
        for condIdx in range(len(condDict)):
            leftBandPower = mne.time_frequency.tfr_morlet(data[condDict[condIdx]],
                                                    freqs=freqs, n_cycles=n_cycles, use_fft=True, return_itc=False, average=False, picks=leftElecs, decim=3, n_jobs=7)
            rightBandPower = mne.time_frequency.tfr_morlet(data[condDict[condIdx]],
                                                    freqs=freqs, n_cycles=n_cycles, use_fft=True, return_itc=False, average=False, picks=rightElecs, decim=3, n_jobs=7)
            dataLeft = leftBandPower.data.mean(axis=(1, 2))  # Mean across freqs and channels
            dataRight = rightBandPower.data.mean(axis=(1, 2))  # Mean across freqs and channels
            if baseCorr:
                base_tstart = leftBandPower.time_as_index(-1)[0]
                base_tend = leftBandPower.time_as_index(0)[0]
                dataLeft_baseline = dataLeft[:, base_tstart:base_tend].mean(axis=1)
                dataRight_baseline = dataRight[:, base_tstart:base_tend].mean(axis=1)
                dataLeft = 10 * np.log10(dataLeft[:, trange[0]:trange[1]] / dataLeft_baseline[:, np.newaxis])
                dataRight = 10 * np.log10(dataRight[:, trange[0]:trange[1]] / dataRight_baseline[:, np.newaxis])
            else:
                dataLeft = 10 * np.log10(dataLeft[:, trange[0]:trange[1]])
                dataRight = 10 * np.log10(dataRight[:, trange[0]:trange[1]])
            # data{}


def runTGA(epochData, elecs, freq_band, pow_or_phase, typeCond):
    w_size = 1.5
    down_wsize = 50

    if freq_band == 'alpha':
        lf, hf = 8, 14
    elif freq_band == 'beta':
        lf, hf = 14, 20
    elif freq_band == 'theta':
        lf, hf = 4, 8

    t_array = epochData.times
    tempData = epochData.get_data(copy=True)

    tempData = (tempData - tempData.mean(axis=0)) / tempData.std(axis=0)
    X = mne.filter.filter_data(tempData, sfreq=epochData.info['sfreq'], l_freq=lf, h_freq=hf, verbose=True, n_jobs=-1)
    if pow_or_phase == 'pow':
        X = np.abs(hilbert(X)) ** 2
    elif pow_or_phase == 'phase':
        X = np.angle(hilbert(X))

    # occ_elecs =  left_occ_elecs + right_occ_elecs 
    # occ_elecs = left_par_elecs + right_par_elecs 
    # occ_elecs = left_elecs + right_elecs
    ElecsIdx = [epochData.ch_names.index(elec) for elec in elecs]
    X = X[:, ElecsIdx, :]
    y = epochData.events[:, 2].copy()

    if typeCond == 'byPF_pro':
        X = X[(y == 11) | (y == 12), :, :]
        y = y[(y == 11) | (y == 12)]
        y__ = np.array([1 if y == 11 else 0 for y in y]) # 1 for inPF, 0 for outPF
    elif typeCond == 'byPF_anti':
        X = X[(y == 13) | (y == 14), :, :]
        y = y[(y == 13) | (y == 14)]
        y__ = np.array([1 if y == 13 else 0 for y in y]) # 1 for inPF, 0 for outPF
    elif typeCond == 'byPF_stimin':
        X = X[(y == 11) | (y == 13), :, :]
        y = y[(y == 11) | (y == 13)]
        y__ = np.array([1 if y == 11 else 0 for y in y])
    elif typeCond == 'byPF_respin':
        X = X[(y == 11) | (y == 14), :, :]
        y = y[(y == 11) | (y == 14)]
        y__ = np.array([1 if y == 11 else 0 for y in y])
    elif typeCond == 'byTrlType':
        y__ = np.array([1 if y == 11 or y == 12 else 0 for y in y])
    
    # Downsample the data and then smooth it
    X_down, t_down  = X[:, :, down_wsize:-down_wsize:down_wsize], t_array[down_wsize:-down_wsize:down_wsize]
    X_smooth = gaussian_smooth_1d(X_down, sigma=w_size)

    clf = make_pipeline(
        Vectorizer(),
        # StandardScaler(),
        SVC(kernel='rbf', C=1),
    )
    gen_decod = GeneralizingEstimator(clf, n_jobs=-1, scoring='roc_auc', verbose=True)
    scores = cross_val_multiscore(gen_decod, X_smooth, y__, cv=5, n_jobs=-1)
    scores_mean = np.mean(scores, axis=0)
    return scores_mean, t_down

def runTGA_TMS(epochData1, epochData2, elecs, freq_band, pow_or_phase, typeCond):
    w_size = 1.5
    down_wsize = 50

    if freq_band == 'alpha':
        lf, hf = 8, 14
    elif freq_band == 'beta':
        lf, hf = 14, 20
    elif freq_band == 'theta':
        lf, hf = 4, 8

    t_array = epochData1.times
    tempData1 = epochData1.get_data(copy=True)
    tempData2 = epochData2.get_data(copy=True)

    tempData1 = (tempData1 - tempData1.mean(axis=0)) / tempData1.std(axis=0)
    tempData2 = (tempData2 - tempData2.mean(axis=0)) / tempData2.std(axis=0)
    tempData = np.concatenate((tempData1, tempData2), axis=0)
    X = mne.filter.filter_data(tempData, sfreq=epochData1.info['sfreq'], l_freq=lf, h_freq=hf, verbose=True, n_jobs=-1)
    if pow_or_phase == 'pow':
        X = np.abs(hilbert(X)) ** 2
    elif pow_or_phase == 'phase':
        X = np.angle(hilbert(X))

    # occ_elecs =  left_occ_elecs + right_occ_elecs 
    # occ_elecs = left_par_elecs + right_par_elecs 
    # occ_elecs = left_elecs + right_elecs
    ElecsIdx = [epochData1.ch_names.index(elec) for elec in elecs]
    X = X[:, ElecsIdx, :]
    y1 = epochData1.events[:, 2].copy()
    y2 = epochData2.events[:, 2].copy()
    y = np.concatenate((y1, y2), axis=0)

    if typeCond == 'byPF_pro':
        X = X[(y == 11) | (y == 12), :, :]
        y = y[(y == 11) | (y == 12)]
        y__ = np.array([1 if y == 11 else 0 for y in y]) # 1 for inPF, 0 for outPF
    elif typeCond == 'byPF_anti':
        X = X[(y == 13) | (y == 14), :, :]
        y = y[(y == 13) | (y == 14)]
        y__ = np.array([1 if y == 13 else 0 for y in y]) # 1 for inPF, 0 for outPF
    elif typeCond == 'byPF_stimin':
        X = X[(y == 11) | (y == 13), :, :]
        y = y[(y == 11) | (y == 13)]
        y__ = np.array([1 if y == 11 else 0 for y in y]) # 1 for pro, 0 for anti
    elif typeCond == 'byPF_respin':
        X = X[(y == 11) | (y == 14), :, :]
        y = y[(y == 11) | (y == 14)]
        y__ = np.array([1 if y == 11 else 0 for y in y]) # 1 for pro, 0 for anti
    elif typeCond == 'byTrlType':
        y__ = np.array([1 if y == 11 or y == 12 else 0 for y in y]) # 1 for pro, 0 for anti
    
    # Downsample the data and then smooth it
    X_down, t_down  = X[:, :, down_wsize:-down_wsize:down_wsize], t_array[down_wsize:-down_wsize:down_wsize]
    X_smooth = gaussian_smooth_1d(X_down, sigma=w_size)

    clf = make_pipeline(
        Vectorizer(),
        # StandardScaler(),
        SVC(kernel='rbf', C=1),
    )
    gen_decod = GeneralizingEstimator(clf, n_jobs=-1, scoring='roc_auc', verbose=True)
    scores = cross_val_multiscore(gen_decod, X_smooth, y__, cv=5, n_jobs=-1)
    scores_mean = np.mean(scores, axis=0)
    return scores_mean, t_down