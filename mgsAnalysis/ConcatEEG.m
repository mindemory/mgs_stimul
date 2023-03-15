function ConcatEEG(p, fName, run_check)
% Created by Mrugank: 12/08/2022: Extracts header, data and event files for
% each subject ran on each day and concatenates them into one file.

if nargin < 3
    run_check = 1;
end

delete([p.EEGData '/._*'])
fNames = dir([p.EEGData '/*.vhdr']);

data_concat = NaN(63,1);
sample_count = 0;
for ii=1:length(fNames)
    EEGfile = [p.EEGData filesep fNames(ii).name];
    disp(['Working on file ' fNames(ii).name]);
    
    % extract header, data and event from EEGfile
    hdr = ft_read_header(EEGfile);
    dat = ft_read_data(EEGfile);
    evt = ft_read_event(EEGfile);
    if ii == 1
        event_concat = evt;
    else
        for jj=1:length(evt)
            evt(jj).sample = evt(jj).sample + sample_count;
        end
        event_concat = [event_concat, evt];
    end
    sample_count = sample_count + hdr.nSamples;
    data_concat = [data_concat, dat(1:63, :)];
end

hdr.nSamples = sample_count;
hdr.nChans = 63;
load('/datc/MD_TMS_EEG/data/mgs_data/sub98/day01/reportFile.mat');
correct_trigs = repelem(reshape(reportFile.trigReport', 1, []), 2);
for ii = 2:length(event_concat)
    trig_val_now = correct_trigs(ii - 1);
    if trig_val_now < 10
        event_concat(ii).value = ['R  ' num2str(trig_val_now)];
    else
        event_concat(ii).value = ['R ' num2str(trig_val_now)];
    end
end
% Chec
if run_check
    disp('Checking timings for flags.')
    flags = check_flags(hdr, event_concat);
    save([p.save '/EEGflags.mat'],'flags')
else
    disp('Timing of flags not checked. Analyses based on precise time-stamps could be incorrect.')
end

ft_write_data(fName.concat, data_concat, 'header', hdr, 'event', event_concat);
end
