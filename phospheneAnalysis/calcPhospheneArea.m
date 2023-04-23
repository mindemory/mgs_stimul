function calcPhospheneArea(subjID, session, data_dir, figures_dir, anti_type)


data_path = [data_dir '/tmsRtnTpy_sub' subjID '_sess' session];
load(data_path);

% remove invalid trials and corresponding coil locations
tmsRtnTpy = remove_invalid_trials(tmsRtnTpy);

% Check for unique coil locations
LocInds = unique(tmsRtnTpy.Response.CoilLocation);
%LocInds = [1 2 3 4 5];
% Initialize PhosphReport
PhosphReport = struct;
PhosphReport = repmat(PhosphReport, [1, length(LocInds)]);

% Extract parameters from tmsRtnTpy
parameters = loadParameters(tmsRtnTpy);
tms_notms = [0, 1, 1];
tms_notms_Idx = randperm(length(tms_notms));
tms_notms = tms_notms(tms_notms_Idx);
VAs = zeros(length(LocInds), 1);

%% Calculate border and area of each phosphene report
for coilInd = 1:length(LocInds)
    % list of trials for given CoilLocation with detections
    phsphTrials = find(tmsRtnTpy.Response.CoilLocation == coilInd & tmsRtnTpy.Response.Detection == 1);
    PhosphReport(coilInd).trialInd = phsphTrials;
    % compute area and border for each drawing for given CoilLocation
    for trial = 1:length(phsphTrials)
        trialInd = phsphTrials(trial);
        drawing = tmsRtnTpy.Response.Drawing{trialInd};
        poly_shape = rmholes(polyshape(drawing));
        PhosphReport(coilInd).polyshape{trial} = poly_shape;
    end
    
    % calculate the overlapping area across all phosphenes for this coilLocation
    overlap_polyshape = PhosphReport(coilInd).polyshape{1};
    for trial = 2:length(PhosphReport(coilInd).polyshape)
        overlap_polyshape = intersect(overlap_polyshape, PhosphReport(coilInd).polyshape{trial});
    end
    overlap_polyshape = rmholes(overlap_polyshape);
    PhosphReport(coilInd).overlapPolyshape = overlap_polyshape;
    
    %% Calculate Target Sample-space
    [X_mean, Y_mean] = centroid(overlap_polyshape);
    PhosphReport(coilInd).polyshape_centroid = [X_mean, Y_mean];
    % compute buffer of r and polar angle of mean.
    [va, coords_all] = sample_space_bounds(X_mean, Y_mean, parameters); % r in pixel
    VAs(coilInd) = va;
    % compute area for expected bounds
    polyshape_bound = rmholes(polyshape(coords_all));
    % compute the overlapping area between expected bounds and overlapping
    % phosphene area. This is the StimuliSampleSpace from which stimuli
    % would be drawn.
    polyshape_common = intersect(polyshape_bound, overlap_polyshape);
    
    StimuliSampleSpace = fillshape(polyshape_common, parameters.screenYpixels);
    PhosphReport(coilInd).StimuliSampleSpace = StimuliSampleSpace;
    
    % Store coilHemifield
    if X_mean > parameters.xCenter
        PhosphReport(coilInd).coilHemifield = 1; % Right visual field
    else
        PhosphReport(coilInd).coilHemifield = 2; % Left visual field
    end
    for day = 1:parameters.days
        TMScond = tms_notms(day);
        conds = ["pro", "anti"];
        conds = repmat(conds, [1, parameters.numBlocks/2]);
        condsIdx = randperm(length(conds));
        condsByBlock = conds(condsIdx);
        % Compute taskMaps
        for block = 1:parameters.numBlocks
            inds = randi(length(StimuliSampleSpace),[parameters.numTrials/2 1]);
            % stimulus inside the tms FOV / TMS
            stimLocSetIn = StimuliSampleSpace(inds, :);
            % stimulus outside the tms FOV / TMS
            if strcmp(anti_type, 'diagonal')
                stimLocSetOut = [parameters.screenXpixels parameters.screenYpixels] - stimLocSetIn; % mirror diagonally
            elseif strcmp(anti_type, 'mirror')
                stimLocSetOut(:, 1) = parameters.screenXpixels - stimLocSetIn(:, 1); % mirror diagonally
                stimLocSetOut(:, 2) = stimLocSetIn(:, 2);
            end
            % concat all conditions
            stimLocpix = [stimLocSetIn; stimLocSetOut];
            trialInds = randperm(parameters.numTrials);
            stimLocpix = stimLocpix(trialInds', :);
            % 1 if stimulus is inside TMS VF
            stimVF = [ones(size(stimLocSetIn, 1), 1); zeros(size(stimLocSetOut, 1), 1)];
            stimVF = stimVF(trialInds);

            condthisBlock = convertStringsToChars(condsByBlock(block));
            PhosphReport(coilInd).taskMap(day, block).TMScond = TMScond;
            PhosphReport(coilInd).taskMap(day, block).condition = condthisBlock;
            if strcmp(condthisBlock,'pro')
                saccLocpix = stimLocpix;
            elseif strcmp(condthisBlock,'anti')
                if strcmp(anti_type, 'diagonal')
                    saccLocpix = [parameters.screenXpixels parameters.screenYpixels] - stimLocpix; % mirror diagonally
                elseif strcmp(anti_type, 'mirror')
                    saccLocpix(:, 1) = parameters.screenXpixels - stimLocpix(:, 1); % mirror diagonally
                    saccLocpix(:, 2) = stimLocpix(:, 2);
                end
            end
            dotSizeStim = computeDotSize(parameters, stimLocpix);
            dotSizeSacc = computeDotSize(parameters, saccLocpix);
            
            PhosphReport(coilInd).taskMap(day, block).stimVF = stimVF;
            PhosphReport(coilInd).taskMap(day, block).stimLocpix = stimLocpix;
            PhosphReport(coilInd).taskMap(day, block).dotSizeStim = dotSizeStim;
            PhosphReport(coilInd).taskMap(day, block).dotSizeSacc = dotSizeSacc;
            PhosphReport(coilInd).taskMap(day, block).saccLocpix = saccLocpix;
        end
    end
    % Compute taskMaps for Practice
    for blockPractice = 1:parameters.numBlocksPractice
        indsPractice = randi(length(StimuliSampleSpace),[parameters.numTrials/2 1]);
        % stimulus inside the tms FOV / TMS
        stimLocSetInPractice = StimuliSampleSpace(indsPractice, :);
        % stimulus outside the tms FOV / TMS
        if strcmp(anti_type, 'diagonal')
            stimLocSetOutPractice = [parameters.screenXpixels parameters.screenYpixels] - stimLocSetInPractice; % mirror diagonally
        elseif strcmp(anti_type, 'mirror')
            stimLocSetOutPractice(:, 1) = parameters.screenXpixels - stimLocSetInPractice(:, 1); % mirror diagonally
            stimLocSetOutPractice(:, 2) = stimLocSetInPractice(:, 2);
        end
        % concat all conditions
        stimLocpixPractice = [stimLocSetInPractice; stimLocSetOutPractice];
        trialIndsPractice = randperm(parameters.numTrials);
        stimLocpixPractice = stimLocpixPractice(trialInds', :);
        % 1 if stimulus is inside TMS VF
        stimVFPractice = [ones(size(stimLocSetInPractice, 1), 1); zeros(size(stimLocSetOutPractice, 1), 1)];
        stimVFPractice = stimVFPractice(trialIndsPractice);

        if mod(blockPractice, 2) == 1 % odd blocks in practice are pro
            condthisBlockPractice = 'pro';
            saccLocpixPractice = stimLocpixPractice;
        else
            condthisBlockPractice = 'anti';
            if strcmp(anti_type, 'diagonal')
                saccLocpixPractice = [parameters.screenXpixels parameters.screenYpixels] - stimLocpixPractice; % mirror diagonally
            elseif strcmp(anti_type, 'mirror')
                saccLocpixPractice(:, 1) = parameters.screenXpixels - stimLocpixPractice(:, 1); % mirror diagonally
                saccLocpixPractice(:, 2) = stimLocpixPractice(:, 2);
            end
        end
        PhosphReport(coilInd).taskMapPractice(blockPractice).condition = condthisBlockPractice;

        dotSizeStimPractice = computeDotSize(parameters, stimLocpixPractice);
        dotSizeSaccPractice = computeDotSize(parameters, saccLocpixPractice);

        PhosphReport(coilInd).taskMapPractice(blockPractice).stimVF = stimVFPractice;
        PhosphReport(coilInd).taskMapPractice(blockPractice).stimLocpix = stimLocpixPractice;
        PhosphReport(coilInd).taskMapPractice(blockPractice).dotSizeStim = dotSizeStimPractice;
        PhosphReport(coilInd).taskMapPractice(blockPractice).dotSizeSacc = dotSizeSaccPractice;
        PhosphReport(coilInd).taskMapPractice(blockPractice).saccLocpix = saccLocpixPractice;
    end
end


%% Visualize Phosphene maps
fig1 = figure();
fig1.Position = [50 50 1000 1000];
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
    plot(parameters.xCenter, parameters.yCenter,'+k', 'MarkerSize', 10, 'linewidth', 1.5);
    for trial = 1:length(PhosphReport(coilInd).polyshape)
        hold on;
        pg = plot(PhosphReport(coilInd).polyshape{trial}, 'linewidth', 1.5);
        pg.FaceColor = 'w';
        ax = gca; ax.YDir = 'reverse'; %axis off;
    end

    pg1 = plot(PhosphReport(coilInd).overlapPolyshape);
    pg1.FaceColor = 'k';
    ax = gca;
    ax.FontSize = 16;
    ax.XAxis.FontSize = 16;
    ax.YAxis.FontSize = 16;
    plot([parameters.xCenter, PhosphReport(coilInd).polyshape_centroid(1)], ...
        [parameters.yCenter, PhosphReport(coilInd).polyshape_centroid(2)], 'm--', 'MarkerSize', 10, 'linewidth', 1.5);
    
    plot(PhosphReport(coilInd).polyshape_centroid(1), PhosphReport(coilInd).polyshape_centroid(2), 'g*', 'MarkerSize', 10, 'linewidth', 1.5);
    xlim([0 parameters.screenXpixels]);
    ylim([0 parameters.screenYpixels]);
    xticks(parameters.screenXpixels * [0 1/4 1/2 3/4 1]);
    yticks(parameters.screenYpixels * [0 1/4 1/2 3/4 1]);
    hh = sgtitle('Overlapping Phosphenes');
    set(hh, 'FontSize', 24, 'FontWeight', 'bold');
    title({['Coil index: ' num2str(coilInd)], ['mean va: ' num2str(round(VAs(coilInd), 4))]}, 'FontSize', 20);
    pbaspect([1 1 1]);
end

%% Visualize Stimulus space
fig2 = figure();
fig2.Position = [1000 1000 1000 1000];

for coilInd = 1:N
    subplot(n1,n2,coilInd);
    plot(parameters.xCenter, parameters.yCenter,'+k', 'MarkerSize', 20, 'linewidth', 2);
    hold on;
    pg1 = plot(PhosphReport(coilInd).overlapPolyshape);
    pg1.FaceColor = 'k';
    pg1.FaceAlpha = 0.5;
    plot(PhosphReport(coilInd).StimuliSampleSpace(:,1), ...
        PhosphReport(coilInd).StimuliSampleSpace(:,2), '.', 'Color', [0, 0, 1, 1])
    ax = gca; ax.YDir = 'reverse';
    ax.FontSize = 16;
    ax.XAxis.FontSize = 16;
    ax.YAxis.FontSize = 16;
    xlim([0 parameters.screenXpixels]);
    ylim([0 parameters.screenYpixels]);
    xticks(parameters.screenXpixels * [0 1/4 1/2 3/4 1]);
    yticks(parameters.screenYpixels * [0 1/4 1/2 3/4 1]);
    hh1 = sgtitle('Stimuli Sample Space');
    set(hh1, 'FontSize', 24, 'FontWeight', 'bold');
    title({['Coil index: ' num2str(coilInd)], ['mean va: ' num2str(round(VAs(coilInd), 4))]}, 'FontSize', 20);pbaspect([1 1 1]);
end
%% Save results
saveName_phosph = [data_dir '/PhospheneReport_sub' subjID '_sess' session '_antitype_' anti_type];
save(saveName_phosph,'PhosphReport')

if ~exist(figures_dir, 'dir')
    mkdir(figures_dir);
end
saveName_phosph_fig = [figures_dir '/PhospheneReport_sub' subjID '_sess' session];
saveName_samplespace_fig = [figures_dir '/SampleSpace_sub' subjID '_sess' session];

saveas(fig1,saveName_phosph_fig,'fig')
saveas(fig1,saveName_phosph_fig,'png')
saveas(fig1,saveName_phosph_fig,'epsc')
saveas(fig2,saveName_samplespace_fig,'fig')
saveas(fig2,saveName_samplespace_fig,'png')
saveas(fig2,saveName_samplespace_fig,'epsc')
end

