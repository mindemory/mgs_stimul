clear; close all; clc;
subjID = '02';
day = 3;
block_files = [1, 5];
master_dir = '/d/DATC/datc/MD_TMS_EEG';

addpath /Users/mrugank/Documents/fieldtrip;
ft_defaults;

phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
mgs_data_path = [master_dir '/data/mgs_data/sub' subjID '/day' num2str(day, "%02d")];
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

EEGpath = [master_dir '/EEGData/sub' subjID];
for ii = 1:length(block_files)
    bb = block_files(ii);
    EEGfiles{ii} = ['sub' num2str(subjID, "%02d") '_day' num2str(day, "%02d") '_block' num2str(bb, "%02d") '.vhdr'];
end
%EEGfiles = {['sub' num2str(subjID)_day02.vhdr'], 'sub01_day01_block02.vhdr', 'sub01_day01_block03.vhdr', ...
%    'sub01_day01_block10.vhdr'};
concatfname = ['sub' num2str(subjID, "%02d") '_day' num2str(day, "%02d") '_concat.vhdr'];
concatfilepathname = [EEGpath filesep concatfname];
%if ~exist(concatfilename)
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
%end