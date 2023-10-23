function new_data = select_trials(data_eeg, trials)
    new_data.label = data_eeg.label;
    new_data.fsample = data_eeg.fsample;
    new_data.cfg = data_eeg.cfg;
    new_data.cfg.trl = new_data.cfg.trl(trials, :);
    new_data.hdr = data_eeg.hdr;
    new_data.trial = data_eeg.trial(1, trials);
    new_data.time = data_eeg.time(1, trials);
    new_data.trialinfo = data_eeg.trialinfo(trials, :);
    new_data.sampleinfo = data_eeg.sampleinfo(trials, :);
end