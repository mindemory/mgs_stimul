function calcStimLocations(subjID,session)

% subjID = int2strz(input(sprintf('\nsubject: ')),2);
% session = int2strz(input(sprintf('\nsession: ')),2);

dataDIR = ['Results/sub' subjID];
fileName = ['PhospheneReport_sub' subjID '_sess' session];
data = [dataDIR '/' fileName];
% check if PhospheneReport exists
listing = dir(dataDIR);
flag = 0;
for i = 1:length(listing)
    if strfind(listing(i).name,fileName)
        flag = 1;
    end
end
if ~flag
    return
end
load(data);

data = [dataDIR '/tmsRtnTpy_sub' subjID '_sess' session];
load(data);

stimN = 10;
%% estimate a 2D-normal matching the overlapped area for each trial

for coilLocInd = 1:length(PhosphReport)
    
    ValidCoords = PhosphReport{coilLocInd}.overlapCoords.unique;
    vc.coords = ValidCoords;
    vc.mean = [mean(ValidCoords(:,1)) mean(ValidCoords(:,2))];
    vc.std = [std(ValidCoords(:,1)) std(ValidCoords(:,2))];
    
    x = 1:tmsRtnTpy.Params.screen.screenXpixels;
    y = 1:tmsRtnTpy.Params.screen.screenYpixels;
    fX = normpdf(x,vc.mean(1),vc.std(1));
    fY = normpdf(y,vc.mean(2),vc.std(2));
    [X,Y] = meshgrid(fX,fY);
    vc.pdf = X.*Y/sum(sum(X.*Y));
    
    Stim{coilLocInd}.ValidCoords = vc;
    
    % find locations with estimated 2D-normal is larger than half maximum
    gain = max(max(vc.pdf));
    thresh = .5*gain;
    [indsY , indsX] = find(vc.pdf > thresh);
    pdfCoords = [indsX indsY];
    
    Stim{coilLocInd}.pdfCoords = pdfCoords;
    
    if vc.mean(1) > tmsRtnTpy.Params.screen.xCenter
        Stim{coilLocInd}.coilHemField = 1; % Right visual field
    else
        Stim{coilLocInd}.coilHemField = 2; % Left visual field
    end
end

%% pick stimulus locations randomly from the selected coordinates

for coilLocInd = 1:length(Stim)
    stimArea = Stim{coilLocInd}.pdfCoords;
    if ~isempty(stimArea)
        sampInds = randperm(length(stimArea), stimN);
        stimCoords = stimArea(sampInds,:);
        
        Stim{coilLocInd}.sampInds = sampInds;
        Stim{coilLocInd}.stimCoords = stimCoords;
    else
        Stim{coilLocInd}.sampInds = [];
        Stim{coilLocInd}.stimCoords = [];
    end
end

%% visualize samples
ScrSize = get(0,'screensize');
fig = figure('Position',[100 round(ScrSize(4)/5) ScrSize(3)-200 round(3*ScrSize(4)/5)]);
N = length(Stim);
n1 = ceil(N/5);
n2 = min([5 N]);
for coilLocInd = 1:N
    if ~isempty(Stim{coilLocInd}.stimCoords)
        subplot(n1,n2,coilLocInd);
        imagesc(Stim{coilLocInd}.ValidCoords.pdf); title(['Coil Location Index : ' num2str(coilLocInd)]);
        hold on;
        for sampInd = 1:size(Stim{coilLocInd}.stimCoords,1)
            plot(Stim{coilLocInd}.stimCoords(sampInd,1),Stim{coilLocInd}.stimCoords(sampInd,2),'+')
        end
        pbaspect([1 1 1]);
    end
end

%% save results
saveDIR = dataDIR;
saveName = [saveDIR '/Stim_sub' subjID '_sess' session];
save(saveName,'Stim')

saveName = [saveDIR '/Figures/Stim_sub' subjID '_sess' session];
saveas(fig,saveName,'fig')
saveas(fig,saveName,'jpg')
saveas(fig,saveName,'epsc')