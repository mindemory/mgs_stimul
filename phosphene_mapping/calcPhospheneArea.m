function calcPhospheneArea(subjID,session,overlapThresh, data_dir)

data_path = [data_dir '/tmsRtnTpy_sub' subjID '_sess' session];
load(data_path);

tmsRtnTpy = remove_invalid_trials(tmsRtnTpy);

% Check for coil locations that have detections
phsphLocInds = unique(tmsRtnTpy.Response.CoilLocation(tmsRtnTpy.Response.Detection == 1));

CoilLoc_PosPhsph = [];
for locInd = 1:length(phsphLocInds)
    coilInd = phsphLocInds(locInd);
    %% calculate border and area of each phosphene report
    phsphTrials_thisLoc = find(tmsRtnTpy.Response.CoilLocation == coilInd & tmsRtnTpy.Response.Detection == 1);
    if exist('phsphTrials_thisLoc', 'var') && ~isempty(phsphTrials_thisLoc)
        PhosphReport{locInd}.coilLocInd = coilInd;
        CoilLoc_PosPhsph = [CoilLoc_PosPhsph coilInd];
        
        for ii = 1:length(phsphTrials_thisLoc)
            trialInd = phsphTrials_thisLoc(ii);
            PhosphReport{locInd}.trialInd(ii) = trialInd;
            %PhosphReport{locInd}.mouseCoords{trialInd} = tmsRtnTpy.Response.Drawing.coords{thisPhsph_totalTrialInd};
            
            drawing = tmsRtnTpy.Response.Drawing.coords{trialInd};
            [area, border] = analyzeDrawing(drawing, tmsRtnTpy);
            PhosphReport{locInd}.area{ii} = area;
            PhosphReport{locInd}.border{ii} = border;
        end
        
        %% calculate the overlaped areas
        overlap_area = PhosphReport{locInd}.area{1};
        for ii = 2:length(PhosphReport{locInd}.area)
            overlap_area = intersect(overlap_area, PhosphReport{locInd}.area{ii}, 'rows');
        end
        
        PhosphReport{locInd}.overlapCoords = overlap_area;
%         PhosphReport{locInd}.overlapCoords.all = [];
%         for i = 1:length(PhosphReport{locInd}.area)
%             
%             coords1 = PhosphReport{locInd}.area{i};
%             overlap.counter = zeros(size(coords1,1),1);
%             overlap.trialInd = cell(size(coords1,1),1);
%             
%             for j = 1:length(PhosphReport{locInd}.area)
%                 
%                 coords2 = PhosphReport{locInd}.area{j};
%                 if i ~= j
%                     membInds = ismember(coords1,coords2,'rows');
%                     inds = find(membInds);
%                     overlap.counter(inds) = overlap.counter(inds) + 1;
%                     for k = 1:length(inds)
%                         overlap.trialInd{inds(k)} = [overlap.trialInd{inds(k)} j];
%                     end
%                 end
%             end
%             PhosphReport{locInd}.overlap{i} = overlap; % each coordinate (corresponding to the phosphene at this coil location) repeated in how many trials.
%             validInds = find(PhosphReport{locInd}.overlap{i}.counter >= overlapThresh);
%             PhosphReport{locInd}.validInds{i} = validInds;
%             PhosphReport{locInd}.overlapCoords.all = [PhosphReport{locInd}.overlapCoords.all;coords1(validInds,:)];
%         end
%         
%         PhosphReport{locInd}.overlapCoords.unique = unique(PhosphReport{locInd}.overlapCoords.all,'rows','stable');
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
    if isfield(PhosphReport{locInd},'area')
        subplot(n1,n2,locInd);
        for ii = 1:length(PhosphReport{locInd}.area)
            axis ij
            hold on;plot(PhosphReport{locInd}.border{ii}(:,1),PhosphReport{locInd}.border{ii}(:,2));
            plot(tmsRtnTpy.Params.screen.xCenter,tmsRtnTpy.Params.screen.yCenter,'+r');
            xlim([0 tmsRtnTpy.Params.screen.screenXpixels]);
            ylim([0 tmsRtnTpy.Params.screen.screenYpixels]);
            title(['Coil Location Index : ' num2str(CoilLoc_PosPhsph(locInd))]);
        end
        hold on; plot(PhosphReport{locInd}.overlapCoords(:,1),PhosphReport{locInd}.overlapCoords(:,2),'.k')
        pbaspect([1 1 1]);
    end
end

%% Save results
saveName = [data_dir '/PhospheneReport_sub' subjID '_sess' session];
% %save(saveName,'PhosphReport', '-v7.3')
save(saveName,'PhosphReport')
% 
fig_dir = [data_dir '/Figures/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveName = [data_dir '/Figures/PhospheneReport_sub' subjID '_sess' session];
saveas(fig,saveName,'fig')
saveas(fig,saveName,'png')
saveas(fig,saveName,'epsc')
