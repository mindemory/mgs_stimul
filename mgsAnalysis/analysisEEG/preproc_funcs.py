import os
import mne
import numpy as np

def concat_eeg(data_path, output_fname, run_check=True):
    # Listing all .vhdr files
    eeg_files = [f for f in os.listdir(data_path) if f.endswith('.vhdr') and ~f.startswith('.')]
    
    raws = []
    events = []
    event_id = 0

    for eeg_file in eeg_files:
        print(f'Working on file {eeg_file}')
        raw = mne.io.read_raw_brainvision(os.path.join(data_path, eeg_file), preload=True)
        e = mne.find_events(raw, shortest_event=0, stim_channel=None)
        
        if len(raws) > 0:
            e[:, 0] += raws[-1].last_samp + 1  # Adjust event sample numbers

        raws.append(raw)
        events.append(e)
        
    # Concatenating all the data
    raw_concat = mne.concatenate_raws(raws)
    
    # Concatenating and adjusting events
    events_concat = np.concatenate(events, axis=0)

    # Optional: run checks and remove certain events, adapt from original MATLAB code
    if run_check:
        # Implement the specific checks and event removals here
        pass

    # Writing the concatenated data
    mne.io.write_raw_brainvision(raw_concat, output_fname)

    return raw_concat, events_concat
