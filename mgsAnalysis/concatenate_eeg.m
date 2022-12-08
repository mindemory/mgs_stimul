function concatenate_eeg(p, fName)
% Created by Mrugank: 12/08/2022: Extracts header, data and event files for
% each subject ran on each day and concatenates them into one file. 
delete([p.EEGData '/._*'])
fNames = dir([p.EEGData '/*.vhdr']);

data_concat = NaN(63,1);
sample_count = 0;
for ii=1:length(fNames)
    EEGfile = [p.EEGData filesep fNames(ii).name];
    disp(['Working on file ' fNames(ii).name]);
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
ft_write_data(fName.concat, data_concat, 'header', hdr, 'event', event_concat);
end
