function A01_GetTimeReport(subjID)
% Created by Mrugank (02/24/2022): The file 
clearvars -except subjID; close all; clc;

if subjID == 1
    end_blocks = [12 10 10];
elseif subjID == 2
    end_blocks = [10 10 10];
elseif subjID == 5
    end_blocks = [7 8 10];
elseif subjID == 0
    end_blocks = [10];
elseif subjID == 98
    end_blocks = [10 10 10];
elseif subjID == 99
    end_blocks = [10, 10, 10];
elseif subjID == 10
    end_blocks = [2, 0, 2];
end
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
direct.analysis = [direct.datc '/analysis/sub' subjID];
direct.figures = [direct.datc '/Figures'];
direct.phosphene = [direct.data '/phosphene_data/sub' subjID];
direct.mgs = [direct.data '/mgs_data/sub' subjID];

addpath(genpath(direct.data));
% For plotting
nbinss = 50;

% Directory to save plots
fig_dir = [direct.figures '/sub' subjID '/timeStruct'];
if exist(direct.analysis, 'dir') ~= 7
    mkdir(direct.analysis)
end

if exist(fig_dir, 'dir') ~= 7
    mkdir(fig_dir)
end

for day = 2:2%1:days
    direct.day = [direct.mgs '/day' num2str(day, "%02d")];
    end_block = end_blocks(day);
    for block = start_block:end_block
        block_path = [direct.day '/block' num2str(block, "%02d")];
        matfiledeets = dir([block_path '/*.mat']);
        matfileName = matfiledeets(end).name;
        load([block_path filesep matfileName]);
        % Load timeReport for this day and block
        timeReport = matFile.timeReport;
        % Get a list of all duration variables and initialize timeStruct
        if day == 2 && block == start_block
            dur_vars = fieldnames(timeReport);
            for ii = 1:length(dur_vars)
                timeStruct.(dur_vars{ii}) = NaN(days, max_end_block, 40);
            end
        end
        % Extract all variables from timeReport for each day and block into
        % timeStruct
        for ii = 1:length(dur_vars)
            timeStruct.(dur_vars{ii})(day, block, :) = timeReport.(dur_vars{ii});
        end
        clear matFile;
    end
    % Generate a figure of time stamps
    figure;
    h = suptitle(['sub' subjID '_ day' num2str(day, "%02d") ]);
    set(h, 'Position', [0.5, -0.03, 0]);
    for ii = 1:length(dur_vars)
        subplot(3, 3, ii)
        histogram(rmmissing(timeStruct.(dur_vars{ii})(day,:)), 'BinWidth', 0.005);
        title(dur_vars{ii});
        xlabel('Time (s)')
        ylabel('# of Trials')
    end
    fig_fname = [fig_dir '/timeStruct_sub' subjID '_day' num2str(day, "%02d") '.png'];
    print(gcf, '-dpng', fig_fname); 
end

time_fname = [direct.analysis '/timeStruct.mat'];
save(time_fname, 'timeStruct');
end