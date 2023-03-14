clear; close all; clc;
load('/datc/MD_TMS_EEG/data/mgs_data/sub98/day01/reportFile.mat');
load('/datc/MD_TMS_EEG/analysis/sub98/day01/EEGflags.mat');

flags.type(2:2:end) = [];
flags.num(2:2:end) = [];
flags.sample(2:2:end) = [];
flags.time(2:2:end) = [];
flags.matlabTime = zeros(1, 3220);
eegTime = reportFile.masterTimeReport;
blocks = 10;
trs = 40;
counter = 1;
fieldss = fieldnames(eegTime);
for block = 1:blocks
    flags.matlabTime(counter) = eegTime.blockstart(block);
    counter = counter + 1;
    for tr = 1:trs
        for f = 2:9
            flags.matlabTime(counter) = eegTime.(fieldss{f})(block, tr);
            counter = counter + 1;
        end
    end
    flags.matlabTime(counter) = eegTime.blockend(block);
    counter = counter+1;
end
blockstartsample = [1];%, 323, 645, 967, 1289, 1611, 1933, 2255, 2577, 2899, 3221];
flags.EEGsync = zeros(1, 3220);
flags.matlabsync = zeros(1, 3220);
for ii = 1:3218
    if ismember(ii, blockstartsample)
        t0EEG = flags.sample(ii);
        t0Matlab = flags.matlabTime(ii);
    end
    flags.EEGsync(ii) = (flags.sample(ii) - t0EEG)/1000;
    flags.matlabsync(ii) = (flags.matlabTime(ii) - t0Matlab);
end

error = flags.EEGsync - flags.matlabsync;
fig = figure;
plot(error*1000, 'k-')
hold on;
for x = blockstartsample
    plot([x x], ylim, 'r--')
end
xlabel('Flags')
ylabel('Time EEG - Time Matlab (in ms)')
%saveas(fig, '/datc/MD_TMS_EEG/Figures/sub98/timing_tester.png');