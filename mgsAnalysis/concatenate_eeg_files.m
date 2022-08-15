clear; close all; clc;
subjID = '01';
day = 1;
master_dir = '/d/DATC/datc/MD_TMS_EEG';

addpath /Users/mrugank/Documents/fieldtrip;
ft_defaults;

phosphene_data_path = [master_dir '/data/phosphene_data/sub' subjID];
mgs_data_path = [master_dir '/data/mgs_data/sub' subjID '/day' num2str(day, "%02d")];
addpath(genpath(phosphene_data_path));
addpath(genpath(mgs_data_path));

EEGpath = [master_dir '/EEGData/sub' subjID];
EEGfiles = ["sub01_day01_block01.vhdr", "sub01_day01_block02.vhdr", "sub01_day01_block03.vhdr", ...
    "sub01_day01_block10.vhdr"];
concatfilename = [EEGpath '/sub01_day01.vhdr'];
%if ~exist(concatfilename)
    data_concat = NaN(63,1);
    sample_count = 0;
    for ii=1:length(EEGfiles)
        EEGfile = [EEGpath filesep char(EEGfiles(ii))];
        disp(['Working on file ' char(EEGfiles(ii))]);
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
        data_concat = [data_concat, dat];
    end
    hdr.nSamples = sample_count;
    ft_write_data(concatfilename, data_concat, 'header', hdr, 'event', event_concat);
%end