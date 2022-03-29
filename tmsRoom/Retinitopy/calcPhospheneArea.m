function calcPhospheneArea(subjID,session,overlapThresh)
% subjID = int2strz(input(sprintf('\nsubject: ')),2);
% session = int2strz(input(sprintf('\nsession: ')),2);

dataDIR = ['Results/sub' subjID];
data = [dataDIR '/tmsRtnTpy_sub' subjID '_sess' session];
load(data);

if isfield(tmsRtnTpy,'Detection') || (~isfield(tmsRtnTpy,'Detection') && isempty(tmsRtnTpy.Response.Detection))
    return
end

phsphTrialInds = find(tmsRtnTpy.Response.Detection);
phsphLocInds = unique(tmsRtnTpy.Response.CoilLocation(phsphTrialInds));

CoilLoc_PosPhsph = [];
for locInd = 1:length(phsphLocInds)
    %% calculate border and area of each phosphene report
    phsphTrials_thisLoc = find(tmsRtnTpy.Response.CoilLocation == locInd & tmsRtnTpy.Response.Detection == 1);
    if exist('phsphTrials_thisLoc') && ~isempty(phsphTrials_thisLoc)
        PhosphReport{locInd}.coilLocInd = phsphLocInds(locInd);
        CoilLoc_PosPhsph = [CoilLoc_PosPhsph locInd];
        
        for trialInd = 1:length(phsphTrials_thisLoc)
            
            thisPhsph_totalTrialInd = phsphTrials_thisLoc(trialInd);
            PhosphReport{locInd}.trialInd(trialInd) = thisPhsph_totalTrialInd;
            PhosphReport{locInd}.mouseCoords{trialInd} = tmsRtnTpy.Response.Drawing.coords{thisPhsph_totalTrialInd};
            
            tmp = PhosphReport{locInd}.mouseCoords{trialInd};
            [area border] = analyzeDrawing(tmp,tmsRtnTpy);
            PhosphReport{locInd}.area{trialInd} = area;
            PhosphReport{locInd}.border{trialInd} = border;
            
        end
%     end
    %% calculate the overlaped areas
%     if isfield(PhosphReport{locInd},'area')
        PhosphReport{locInd}.overlapCoords.all = [];
        for i = 1:length(PhosphReport{locInd}.area)
            
            coords1 = PhosphReport{locInd}.area{i};
            overlap.counter = zeros(size(coords1,1),1);
            overlap.trialInd = cell(size(coords1,1),1);
            
            for j = 1:length(PhosphReport{locInd}.area)
                
                coords2 = PhosphReport{locInd}.area{j};
                if i ~= j
                    membInds = ismember(coords1,coords2,'rows');
                    inds = find(membInds);
                    overlap.counter(inds) = overlap.counter(inds) + 1;
                    for k = 1:length(inds)
                        overlap.trialInd{inds(k)} = [overlap.trialInd{inds(k)} j];
                    end
                end
            end
            PhosphReport{locInd}.overlap{i} = overlap; % each coordinate (corresponding to the phosphene at this coil location) repeted in how many trials.
            validInds = find(PhosphReport{locInd}.overlap{i}.counter >= overlapThresh);
            PhosphReport{locInd}.validInds{i} = validInds;
            PhosphReport{locInd}.overlapCoords.all = [PhosphReport{locInd}.overlapCoords.all;coords1(validInds,:)];
        end
        
        PhosphReport{locInd}.overlapCoords.unique = unique(PhosphReport{locInd}.overlapCoords.all,'rows','stable');
    end
 
end

%% visualize drawings
ScrSize = get(0,'screensize');
fig = figure('Position',[100 round(ScrSize(4)/5) ScrSize(3)-200 round(3*ScrSize(4)/5)]);
N = length(CoilLoc_PosPhsph);
n1 = ceil(N/5);
n2 = min([5 N]);
for locInd = 1:N
    if isfield(PhosphReport{locInd},'area')
        subplot(n1,n2,locInd);
        for trialInd = 1:length(PhosphReport{locInd}.area)
            axis ij
            hold on;plot(PhosphReport{locInd}.border{trialInd}(:,1),PhosphReport{locInd}.border{trialInd}(:,2));
            plot(tmsRtnTpy.Params.screen.xCenter,tmsRtnTpy.Params.screen.yCenter,'+r');
            xlim([0 tmsRtnTpy.Params.screen.screenXpixels]);
            ylim([0 tmsRtnTpy.Params.screen.screenYpixels]);
            title(['Coil Location Index : ' num2str(CoilLoc_PosPhsph(locInd))]);
        end
        hold on; plot(PhosphReport{locInd}.overlapCoords.unique(:,1),PhosphReport{locInd}.overlapCoords.unique(:,2),'.k')
        pbaspect([1 1 1]);
    end
end
%% save results
saveDIR = dataDIR;
saveName = [saveDIR '/PhospheneReport_sub' subjID '_sess' session];
save(saveName,'PhosphReport')

fig_dir = [saveDIR '/Figures/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveName = [saveDIR '/Figures/PhospheneReport_sub' subjID '_sess' session];
saveas(fig,saveName,'fig')
saveas(fig,saveName,'jpg')
saveas(fig,saveName,'epsc')
