clear; close all; clc;
subjID = 1;
day = 1;

%% Copying to iMac
% Copy analysis from datc to iMac
disp('Copying analysis from datc to iMac....')
analysis_datc = ['/Users/mrugankdake/remote/datc/MD_TMS_EEG/analysis/sub' num2str(subjID,"%02d") '/'];
analysis_imac = ['/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/analysis/sub' num2str(subjID,"%02d") '/'];
[status, msg] = copyfile(analysis_datc, analysis_imac)
disp('analysis copied from datc to iMac ok!')

% Copy mgsdata from datc to iMac
disp('Copying mgs_data from datc to iMac....')
mgsdata_datc = ['/Users/mrugankdake/remote/datc/MD_TMS_EEG/data/mgs_data/sub' num2str(subjID,"%02d") '/day' num2str(day,"%02d")];
mgsdata_imac = ['/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/data/mgs_data/sub' num2str(subjID,"%02d") '/day' num2str(day,"%02d")];
[status, msg] = copyfile(mgsdata_datc, mgsdata_imac)
disp('data copied from datc to iMac ok!')

% Copy mgsdata from datc to iMac
disp('Copying mgs_data from datc to iMac....')
mgsdata_datc = ['/Users/mrugankdake/remote/datc/MD_TMS_EEG/data/mgs_data/sub' num2str(subjID,"%02d") '/day' num2str(day,"%02d")];
mgsdata_imac = ['/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/data/mgs_data/sub' num2str(subjID,"%02d") '/day' num2str(day,"%02d")];
[status, msg] = copyfile(mgsdata_datc, mgsdata_imac)
disp('data copied from datc to iMac ok!')

% Copy mgsdata from datc to iMac
disp('Copying mgs_data from datc to iMac....')
mgsdata_datc = ['/Users/mrugankdake/remote/datc/MD_TMS_EEG/data/mgs_data/sub' num2str(subjID,"%02d") '/day' num2str(day,"%02d")];
mgsdata_imac = ['/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc/data/mgs_data/sub' num2str(subjID,"%02d") '/day' num2str(day,"%02d")];
[status, msg] = copyfile(mgsdata_datc, mgsdata_imac)
disp('data copied from datc to iMac ok!')

% Copy EEGData from datc to iMac
eegfiles_datc = ['/Users/mrugankdake/remote/datc/MD_TMS_EEG/EEGData/sub' ...
    num2str(subjID, "%02d") '/sub' num2str(subjID, "%02d") '_day' ...
    num2str(day, "%02d") '_concat*'];
eegfiles_imac = ['/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc' ...
    '/EEGData/sub' num2str(subjID, "%02d")];
copyfile(eegfiles_datc, eegfiles_imac)

%% Sending data from iMac