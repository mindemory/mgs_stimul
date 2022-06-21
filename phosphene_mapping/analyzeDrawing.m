function [inds_area, drwng_connected] = analyzeDrawing(drwng, tmsRtnTpy)

% The part for calculating the area coordinates needs to be re-written.
% Right now, some columns are missed in the calculated areas. 

% drwng = round(drwng); % Mrugank (04/11/2022): What's the point of this?
drwng(drwng <= 0) = 1;

scrW_vf = tmsRtnTpy.Params.screen.screenWidth;
scrH_vf = tmsRtnTpy.Params.screen.screenHeight;
scrW_pix = tmsRtnTpy.Params.screen.screenXpixels;
scrH_pix = tmsRtnTpy.Params.screen.screenYpixels;

%% throw away redundant coordinates

drwng_uniqe = unique(drwng,'rows','stable');
% I1 = zeros(scrH_pix,scrW_pix);
% for i = 1:length(drwng)
%     disp(i);
%     I1(drwng(i,2),drwng(i,1)) = 1;
% end
% 
% figure(); imagesc(I1);

%% find the closest point to each point
k = 1;
drwng_tmp = drwng_uniqe;
while size(drwng_tmp, 1) > 1
    A = drwng_tmp(1, :);
    drwng_tmp(1, :) = [];
    B = drwng_tmp;
    distances = sqrt(sum((B - A).^2, 2));
    % find the smallest distance and use that as an index into B:
    closest_tmp = B(distances == min(distances), :); % Masih used a find function which seemed redundant.
    closest(k, :) = closest_tmp(1, :);
    k = k + 1;
end

%% connect the each point to it's closest point
drwng_connected = [];
for i = 1:size(closest,1)
    xy1 = drwng_uniqe(i,:);
    xy2 = closest(i,:);
    xyConnected = connectPoints(xy1, xy2);
    
    drwng_connected = [drwng_connected; xyConnected];
end

drwng_connected = connect_missing_points(drwng_connected);

drwng_connected = unique(drwng_connected,'rows','stable');
% I1 = zeros(scrH_pix,scrW_pix);
% for i = 1:length(drwng_connected)
%     I1(drwng_connected(i,2),drwng_connected(i,1)) = 1;
% end
% figure(); imagesc(I1);

%% fill in the shape
inds_area = [];
for x = 1:scrW_pix
  
    indsY_thisX = find(drwng_connected(:,1) == x);
    if length(indsY_thisX) > 1
        
        y1 = min(drwng_connected(indsY_thisX,2));
        y2 = max(drwng_connected(indsY_thisX,2));
        inds_y = y1:y2;
        inds_area = [inds_area ; [repmat(x,[length(inds_y) 1 ]) inds_y'] ];
    end
end
inds_area = unique(inds_area,'rows','stable');

% I1 = zeros(scrH_pix,scrW_pix);
% for i = 1:length(inds_area)
%     I1(inds_area(i,2),inds_area(i,1)) = 1;
% end
% figure(); imagesc(I1);

