function calcPhospheneArea(subjID,session, data_dir)

data_path = [data_dir '/tmsRtnTpy_sub' subjID '_sess' session];
load(data_path);

tmsRtnTpy = remove_invalid_trials(tmsRtnTpy);

% Check for coil locations that have detections
phsphLocInds = unique(tmsRtnTpy.Response.CoilLocation(tmsRtnTpy.Response.Detection == 1));

CoilLoc_PosPhsph = NaN(length(phsphLocInds), 1);
PhosphReport = struct;
PhosphReport = repmat(PhosphReport, [1, length(phsphLocInds)]);
%% Calculate border and area of each phosphene report

for locInd = 1:length(phsphLocInds)
    coilInd = phsphLocInds(locInd);
    phsphTrials_thisLoc = find(tmsRtnTpy.Response.CoilLocation == coilInd & tmsRtnTpy.Response.Detection == 1);
    if exist('phsphTrials_thisLoc', 'var') && ~isempty(phsphTrials_thisLoc)
        PhosphReport(locInd).coilLocInd = coilInd;
        CoilLoc_PosPhsph(locInd) = coilInd;
        
        for ii = 1:length(phsphTrials_thisLoc)
            trialInd = phsphTrials_thisLoc(ii);
            PhosphReport(locInd).trialInd(ii) = trialInd;            
            drawing = tmsRtnTpy.Response.Drawing.coords{trialInd};
            [area, border] = analyzeDrawing(drawing, tmsRtnTpy);
            PhosphReport(locInd).area{ii} = area;
            PhosphReport(locInd).border{ii} = border;
        end
        
        % calculate the overlaped areas
        overlap_area = PhosphReport(locInd).area{1};
        for ii = 2:length(PhosphReport(locInd).area)
            overlap_area = intersect(overlap_area, PhosphReport(locInd).area{ii}, 'rows');
        end
        
        PhosphReport(locInd).overlapCoords = overlap_area;
    end
end

%% Calculate possible target coordinates
Stim = struct;
Stim = repmat(Stim, [1, length(PhosphReport)]);

for ii = 1:length(PhosphReport)
    coilLocInd = PhosphReport(ii).coilLocInd;
    Stim(ii).coilLocInd = coilLocInd;
    
    vc.coords = PhosphReport(ii).overlapCoords;
    vc.mean = [mean(vc.coords(:,1)) mean(vc.coords(:,2))];
    vc.std = [std(vc.coords(:,1)) std(vc.coords(:,2))];
        
    [r_outer, r_inner, theta] = pixel2va(vc.mean(1),vc.mean(2),'ul', tmsRtnTpy); % r in pixel
    theta_range = theta-45:1:theta+45;
    for jj = 1:length(theta_range)
        theta_temp = theta_range(jj);
        if theta_temp < 0
            theta_temp = 360 - abs(theta_temp);
            theta_range(jj) = theta_temp;
        end 
    end
    coords_outer = polar2pixel(r_outer, theta_range, tmsRtnTpy);
    coords_inner = polar2pixel(r_inner, theta_range, tmsRtnTpy);
    
    edge1 = connectPoints(coords_outer(1, :), coords_inner(1, :));
    edge2 = connectPoints(coords_outer(end, :), coords_inner(end, :));
    
    coords_all = [edge1; coords_outer; flip(edge2); flip(coords_inner)];
    coords_all = round(coords_all);
    
    [area_bound, ~] = analyzeDrawing(coords_all, tmsRtnTpy);
    
    area_common = intersect(area_bound, vc.coords, 'rows');
    
    Stim(ii).StimuliSampleSpace = area_common;
        
    if vc.mean(1) > tmsRtnTpy.Params.screen.xCenter
        Stim(ii).coilHemField = 1; % Right visual field
    else
        Stim(ii).coilHemField = 2; % Left visual field
    end
end

%% Visualize Phosphene maps
ScrSize = get(0,'screensize');
fig = figure('Position',[100 round(ScrSize(4)/5) ScrSize(3)-200 round(3*ScrSize(4)/5)]);
N = length(CoilLoc_PosPhsph);

N1 = [1, 1, 2, 2, 2, 2, 3, 2, 3, 3, 3, 3];
N2 = [1, 2, 2, 2, 3, 3, 3, 4, 3, 4, 4, 4];

if N <= 12
    n1 = N1(N);
    n2 = N2(N);
else
    n1 = ceil(N/5);
    n2 = min([5 N]);
end

for locInd = 1:N
    if isfield(PhosphReport(locInd),'area')
        subplot(n1,n2,locInd);
        for ii = 1:length(PhosphReport(locInd).area)
            axis ij
            hold on;plot(PhosphReport(locInd).border{ii}(:,1),PhosphReport(locInd).border{ii}(:,2));
            plot(tmsRtnTpy.Params.screen.xCenter,tmsRtnTpy.Params.screen.yCenter,'+r');
            xlim([0 tmsRtnTpy.Params.screen.screenXpixels]);
            ylim([0 tmsRtnTpy.Params.screen.screenYpixels]);
            title(['Coil Location Index : ' num2str(CoilLoc_PosPhsph(locInd))]);
        end
        hold on; plot(PhosphReport(locInd).overlapCoords(:,1),PhosphReport(locInd).overlapCoords(:,2),'.k')
        pbaspect([1 1 1]);
    end
end

%% Save results
saveName_phosph = [data_dir '/PhospheneReport_sub' subjID '_sess' session];
save(saveName_phosph,'PhosphReport')

saveName_stim = [data_dir '/Stim_sub' subjID '_sess' session];
save(saveName_stim,'Stim')

fig_dir = [data_dir '/Figures/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveName_phosph_fig = [data_dir '/Figures/PhospheneReport_sub' subjID '_sess' session];
saveas(fig,saveName_phosph_fig,'fig')
saveas(fig,saveName_phosph_fig,'png')
saveas(fig,saveName_phosph_fig,'epsc')
