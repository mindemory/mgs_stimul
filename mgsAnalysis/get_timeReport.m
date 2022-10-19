function get_timeReport(subjID)
clearvars -except subjID; close all; clc;

if subjID == 1
    end_blocks = [12 10 10];
elseif subjID == 2
    end_blocks = [10 10 10];
elseif subjID == 5
    end_blocks = [7 8 10];
elseif subjID == 0
    end_blocks = [10];
end
subjID = num2str(subjID, "%02d"); 
days = 1;
max_end_block = max(end_blocks);
start_block = 1;

subjID = num2str(subjID, "%02d");
tmp = pwd; tmp2 = strfind(tmp,filesep);
direct.master = tmp(1:(tmp2(end)-1));
[ret, hostname] = system('hostname');
if ret ~= 0
    hostname = getenv('hostname');
end
hostname = strtrim(hostname);

if strcmp(hostname, 'syndrome') % If running on Syndrome
    direct.datc = '/d/DATC/datc/MD_TMS_EEG';
else % If running on World's best MacBook
    direct.datc = '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc';
end
direct.data = [direct.datc '/data']; 
direct.analysis = [direct.datc '/analysis'];
% direct.iEye = [direct.master '/iEye'];
direct.phosphene = [direct.data '/phosphene_data/sub' subjID];
direct.mgs = [direct.data '/mgs_data/sub' subjID];

%addpath(genpath(direct.iEye));
%addpath(genpath(phosphene_data_path));
addpath(genpath(direct.data));

%taskMapfilename = [direct.phosphene '/taskMap_sub' subjID '_day' num2str(day, "%02d") '.mat'];
%load(taskMapfilename);
sampleDuration = NaN(days, max_end_block, 40);
delay1Duration = NaN(days, max_end_block, 40);
pulseDuration = NaN(days, max_end_block, 40);
delay2Duration = NaN(days, max_end_block, 40);
respCueDuration = NaN(days, max_end_block, 40);
respDuration = NaN(days, max_end_block, 40);
feedbackDuration = NaN(days, max_end_block, 40);
itiDuration = NaN(days, max_end_block, 40);
trialDuration = NaN(days, max_end_block, 40);
for day = 1:days
    direct.day = [direct.mgs '/day' num2str(day, "%02d")];
    end_block = end_blocks(day);
    for block = start_block:end_block
        block_path = [direct.day '/block' num2str(block, "%02d")];
        matfiledeets = dir([block_path '/*.mat']);
        matfileName = matfiledeets(end).name;
        load([block_path filesep matfileName]);
        timeReport = matFile.timeReport;
        sampleDuration(day, block, :) = timeReport.sampleDuration;
        delay1Duration(day, block, :) = timeReport.delay1Duration;
        pulseDuration(day, block, :) = timeReport.pulseDuration;
        delay2Duration(day, block, :) = timeReport.delay2Duration;
        respCueDuration(day, block, :) = timeReport.respCueDuration;
        respDuration(day, block, :) = timeReport.respDuration;
        feedbackDuration(day, block, :) = timeReport.feedbackDuration;
        itiDuration(day, block, :) = timeReport.itiDuration;
        trialDuration(day, block, :) = timeReport.trialDuration;
        clear matFile;
    end

    
end
nbinss = 50;
figure(); histogram(rmmissing(sampleDuration(:)), 'BinWidth', 0.005); title('sampleDuration');
figure(); histogram(rmmissing(delay1Duration(:)), 'BinWidth', 0.005); title('delay1Duration');
figure(); histogram(rmmissing(pulseDuration(:)), 'BinWidth', 0.005); title('pulseDuration');
figure(); histogram(rmmissing(delay2Duration(:)), 'BinWidth', 0.005); title('delay2Duration');
figure(); histogram(rmmissing(respCueDuration(:)), 'BinWidth', 0.005); title('respCueDuration');
figure(); histogram(rmmissing(respDuration(:)), 'BinWidth', 0.005); title('respDuration');
figure(); histogram(rmmissing(feedbackDuration(:)), 'BinWidth', 0.005); title('feedbackDuration');
figure(); histogram(rmmissing(itiDuration(:)), 'BinWidth', 0.005); title('itiDuration');
figure(); histogram(rmmissing(trialDuration(:)), 'BinWidth', 0.005); title('trialDuration');