function calcStimLocations(subjID,session, data_dir)

fileName = ['PhospheneReport_sub' subjID '_sess' session];
phosphene_report_path = [data_dir '/' fileName];
load(phosphene_report_path);

tmsRtnTpy_path = [data_dir '/tmsRtnTpy_sub' subjID '_sess' session];
load(tmsRtnTpy_path);

%% estimate a 2D-normal matching the overlapped area for each trial
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
    %theta_range = 0:0.1:360;
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
    
%     y = 1:tmsRtnTpy.Params.screen.screenYpixels;
%     fX = normpdf(x,vc.mean(1),vc.std(1));
%     fY = normpdf(y,vc.mean(2),vc.std(2));
%     [X,Y] = meshgrid(fX,fY);
%     vc.pdf = X.*Y/sum(sum(X.*Y));
    
    Stim(ii).ValidCoords = area_common;
    
    % find locations with estimated 2D-normal is larger than half maximum
%     gain = max(max(vc.pdf));
%     thresh = .5*gain;
%     [indsY , indsX] = find(vc.pdf > thresh);
%     pdfCoords = [indsX indsY];
%     
%     Stim(ii).pdfCoords = pdfCoords;
%     
    if vc.mean(1) > tmsRtnTpy.Params.screen.xCenter
        Stim(ii).coilHemField = 1; % Right visual field
    else
        Stim(ii).coilHemField = 2; % Left visual field
    end
end

%% pick stimulus locations randomly from the selected coordinates

% for ii = 1:length(Stim)
%     stimArea = Stim(ii).pdfCoords;
%     if ~isempty(stimArea)
%         sampInds = randperm(length(stimArea), stimN);
%         stimCoords = stimArea(sampInds,:);
%         
%         Stim(ii).sampInds = sampInds;
%         Stim(ii).stimCoords = stimCoords;
%     else
%         Stim(ii).sampInds = [];
%         Stim(ii).stimCoords = [];
%     end
% end
% 
% %% visualize samples
% ScrSize = get(0,'screensize');
% fig = figure('Position',[100 round(ScrSize(4)/5) ScrSize(3)-200 round(3*ScrSize(4)/5)]);
% N = length(Stim);
% n1 = ceil(N/5);
% n2 = min([5 N]);
% for ii = 1:N
%     if ~isempty(Stim(ii).stimCoords)
%         subplot(n1,n2,ii);
%         imagesc(Stim(ii).ValidCoords.pdf); title(['Coil Location Index : ' num2str(ii)]);
%         hold on;
%         for sampInd = 1:size(Stim(ii).stimCoords,1)
%             plot(Stim(ii).stimCoords(sampInd,1),Stim(ii).stimCoords(sampInd,2),'+')
%         end
%         pbaspect([1 1 1]);
%     end
% end

%% save results
saveName = [data_dir '/Stim_sub' subjID '_sess' session];
save(saveName,'Stim')

% saveName = [data_dir '/Figures/Stim_sub' subjID '_sess' session];
% saveas(fig,saveName,'fig')
% saveas(fig,saveName,'jpg')
% saveas(fig,saveName,'epsc')