function S1_concatenate_eeg(p)
block_files = [1, 9];
master_dir = '/d/DATC/datc/MD_TMS_EEG';


EEGpath = [master_dir '/EEGData/sub' p.subjID '/day' num2str(p.day,"%02d")];
for ii = 1:length(block_files)
    bb = block_files(ii);
    EEGfiles{ii} = ['sub' num2str(p.subjID, "%02d") '_day' num2str(p.day, "%02d") '_block' num2str(bb, "%02d") '.vhdr'];
end

concatfname = ['sub' num2str(p.subjID, "%02d") '_day' num2str(p.day, "%02d") '_concat.vhdr'];
concatfilepathname = [EEGpath filesep concatfname];
data_concat = NaN(63,1);
sample_count = 0;
for ii=1:length(EEGfiles)
    EEGfile = [EEGpath filesep EEGfiles{ii}];
    disp(['Working on file ' EEGfiles{ii}]);
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
ft_write_data(concatfilepathname, data_concat, 'header', hdr, 'event', event_concat);
end
