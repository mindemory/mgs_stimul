function calcPhospheneArea(subjID, session, data_dir)

data_path = [data_dir '/tmsRtnTpy_sub' subjID '_sess' session];
load(data_path);

% remove invalid trials and corresponding coil locations
tmsRtnTpy = remove_invalid_trials(tmsRtnTpy);

% Check for unique coil locations
LocInds = unique(tmsRtnTpy.Response.CoilLocation);

% Initialize PhosphReport
PhosphReport = struct;
PhosphReport = repmat(PhosphReport, [1, length(LocInds)]);

parameters = loadParameters(tmsRtnTpy);
% Extract parameters from tmsRtnTpy

conds = ["pro", "anti"];
conds = repmat(conds, [1, parameters.numBlocks/2]);
condsIdx = randperm(length(conds));
condsByBlock = conds(condsIdx);

%% Calculate border and area of each phosphene report
for coilInd = 1:length(LocInds)
    % list of trials for given CoilLocation with detections
    phsphTrials = find(tmsRtnTpy.Response.CoilLocation == coilInd & tmsRtnTpy.Response.Detection == 1);
    PhosphReport(coilInd).trialInd = phsphTrials;
    % compute area and border for each drawing for given CoilLocation
    for trial = 1:length(phsphTrials)
        trialInd = phsphTrials(trial);
        drawing = tmsRtnTpy.Response.Drawing{trialInd};
        [area, border] = analyzeDrawing(drawing, parameters);
        PhosphReport(coilInd).area{trial} = area;
        PhosphReport(coilInd).border{trial} = border;
    end
    
    % calculate the overlapping area across all phosphenes for this coilLocation
    overlap_area = PhosphReport(coilInd).area{1};
    for trial = 2:length(PhosphReport(coilInd).area)
        overlap_area = intersect(overlap_area, PhosphReport(coilInd).area{trial}, 'rows');
    end
    PhosphReport(coilInd).overlapCoords = overlap_area;
    
    %% Calculate Target Sample-space
    overlap_area_mean = [mean(overlap_area(:, 1)) mean(overlap_area(:, 2))];
    % compute buffer of r and polar angle of mean.
    coords_all = sample_space_bounds(overlap_area_mean, parameters); % r in pixel
    
    % compute area for expected bounds
    [area_bound, ~] = analyzeDrawing(coords_all, parameters);
    
    % compute the overlapping area between expected bounds and overlapping
    % phosphene area. This is the StimuliSampleSpace from which stimuli
    % would be drawn.
    area_common = intersect(area_bound, overlap_area, 'rows');
    PhosphReport(coilInd).StimuliSampleSpace = area_common;
    
    % Store coilHemifield
    if overlap_area_mean(1) > parameters.xCenter
        PhosphReport(coilInd).coilHemifield = 1; % Right visual field
    else
        PhosphReport(coilInd).coilHemifield = 2; % Left visual field
    end
    
    % Compute taskMaps
    for block = 1:parameters.numBlocks
        inds = randi(length(area_common),[parameters.numTrials/2 1]);
        % stimulus inside the tms FOV / TMS
        stimLocSetIn = area_common(inds, :);
        % stimulus outside the tms FOV / TMS
        stimLocSetOut = [parameters.screenXpixels parameters.screenYpixels] - stimLocSetIn; % mirror diagonally
        % concat all conditions
        stimLocpix = [stimLocSetIn; stimLocSetOut];
        trialInds = randperm(parameters.numTrials);
        stimLocpix = stimLocpix(trialInds');
        condthisBlock = convertStringsToChars(condsByBlock(block));
        PhosphReport(coilInd).taskMap(block).condition = condthisBlock;
        if strcmp(condthisBlock,'pro')
            saccLocpix = stimLocpix;
        elseif strcmp(condthisBlock,'anti')
            saccLocpix = [parameters.screenXpixels parameters.screenYpixels] - stimLocpix;
        end
        
        PhosphReport(coilInd).taskMap(block).stimLocpix = stimLocpix;
        PhosphReport(coilInd).taskMap(block).saccLocpix = saccLocpix;
    end
end

%% Visualize Phosphene maps
fig1 = figure();
N = length(LocInds);
N1 = [1, 1, 2, 2, 2, 2, 3, 2, 3, 3, 3, 3];
N2 = [1, 2, 2, 2, 3, 3, 3, 4, 3, 4, 4, 4];
if N <= 12
    n1 = N1(N);
    n2 = N2(N);
else
    n1 = ceil(N/5);
    n2 = min([5 N]);
end

for coilInd = 1:N
    subplot(n1,n2,coilInd);
    plot(parameters.xCenter, parameters.yCenter,'+k');
    for trial = 1:length(PhosphReport(coilInd).area)
        axis ij; hold on;
        plot(PhosphReport(coilInd).border{trial}(:,1), PhosphReport(coilInd).border{trial}(:,2));
    end
    plot(PhosphReport(coilInd).overlapCoords(:,1), PhosphReport(coilInd).overlapCoords(:,2), '.k')
    xlim([0 parameters.screenXpixels]);
    ylim([0 parameters.screenYpixels]);
    title(['Coil Location Index : ' num2str(coilInd)]);
    pbaspect([1 1 1]);
end

%% Visualize Stimulus space
fig2 = figure();
for coilInd = 1:N
    subplot(n1,n2,coilInd);
    plot(parameters.xCenter, parameters.yCenter,'+k');
    axis ij;
    hold on; plot(PhosphReport(coilInd).StimuliSampleSpace(:,1), ...
        PhosphReport(coilInd).StimuliSampleSpace(:,2), '.', 'Color', [0, 0, 1, 1])
    
    xlim([0 parameters.screenXpixels]);
    ylim([0 parameters.screenYpixels]);
    title(['Coil Location Index : ' num2str(coilInd)]);
    pbaspect([1 1 1]);
end
%% Save results
saveName_phosph = [data_dir '/PhospheneReport_sub' subjID '_sess' session];
save(saveName_phosph,'PhosphReport')

fig_dir = [data_dir '/Figures/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveName_phosph_fig = [data_dir '/Figures/PhospheneReport_sub' subjID '_sess' session];
saveName_samplespace_fig = [data_dir '/Figures/PhospheneReport_sub' subjID '_sess' session];

saveas(fig1,saveName_phosph_fig,'fig')
saveas(fig1,saveName_phosph_fig,'png')
saveas(fig1,saveName_phosph_fig,'epsc')
saveas(fig2,saveName_samplespace_fig,'fig')
saveas(fig2,saveName_samplespace_fig,'png')
saveas(fig2,saveName_samplespace_fig,'epsc')

