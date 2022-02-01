function [inds_area drwng_connected] = analyzeDrawing(drwng,tmsRtnTpy)

% The part for calculating the area coordinates needs to be re-written.
% Right now, some columns are missed in the calculated areas. 

drwng = round(drwng);
drwng(find(drwng == 0)) = 1;

scrW_vf = tmsRtnTpy.Params.screen.screenWidth;
scrH_vf = tmsRtnTpy.Params.screen.screenHeight;
scrW_pix = tmsRtnTpy.Params.screen.screenXpixels;
scrH_pix = tmsRtnTpy.Params.screen.screenYpixels;

%% throw away redundant coordinates

drwng_uniqe = unique(drwng,'rows','stable');
% tmplt = zeros(scrH_pix,scrW_pix);
% I1= tmplt;
% for i = 1:length(drwng)
%     I1(drwng(i,2),drwng(i,1)) = 1;
% end
% [a b] = find(I1==1);
% drwng_uniqe = [a b];
% % imagesc(I1);

%% find the closest point to each point
k = 1;
drwng_tmp = drwng_uniqe;
while size(drwng_tmp,1) > 1
    A = drwng_tmp(1,:);
    drwng_tmp(1,:) = [];
    B = drwng_tmp;
    distances = sqrt(sum(bsxfun(@minus, B, A).^2,2));
    %find the smallest distance and use that as an index into B:
    closest_tmp = B(find(distances==min(distances)),:);
    closest(k,:) = closest_tmp(1,:);
    k = k+1;
   
end

%% connect the each point to it's closest point
drwng_connected = [];
for i = 1:size(closest,1)
    xy1 = drwng_uniqe(i,:);
    xy2 = closest(i,:);
    xyConnected = connectPoints(xy1,xy2);
    
    drwng_connected = [drwng_connected;xy1;xyConnected];
    
end
drwng_connected = unique(drwng_connected,'rows','stable');

%% fill in the shape
inds_area = [];
for x = 1:scrW_pix
  
    indsY_thisX = find(drwng_connected(:,1) == x);
    
    tmp = indsY_thisX;
    i = 1;
    while i < length(tmp)
        if abs(drwng_connected(tmp(i),2) - drwng_connected(tmp(i+1),2)) < 2
            tmp(i+1) = [];
        else
            i = i+1;
        end
    end
    indsY_thisX = tmp;
    
    if mod(length(indsY_thisX),2) == 1
        indsY_thisX(end) = [];
    end
    if length(indsY_thisX) > 1
        for i = 1:2:length(indsY_thisX)
            y1 = min([drwng_connected(indsY_thisX(i),2) drwng_connected(indsY_thisX(i+1),2)]);
            y2 = max([drwng_connected(indsY_thisX(i),2) drwng_connected(indsY_thisX(i+1),2)]);
            inds_y = [y1:y2]';
            inds_area = [inds_area ; [repmat(x,[length(inds_y) 1 ]) inds_y] ];
        end
    end
end
inds_area = unique(inds_area,'rows','stable');
