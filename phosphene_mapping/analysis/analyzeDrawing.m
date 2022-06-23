function [inds_area, drawing_connected] = analyzeDrawing(drawing, tmsRtnTpy)

% The part for calculating the area coordinates needs to be re-written.
% Right now, some columns are missed in the calculated areas. 

% drwng = round(drwng); % Mrugank (04/11/2022): What's the point of this?
% scrH_pix = tmsRtnTpy.Params.screen.screenYpixels;
% scrW_pix = tmsRtnTpy.Params.screen.screenXpixels;
drawing(drawing <= 0) = 1;

%% throw away redundant coordinates
drawing_unique = unique(drawing,'rows','stable');
% I1 = zeros(scrH_pix,scrW_pix);
% for i = 1:length(drawing)
%     disp(i);
%     I1(drawing(i,2),drawing(i,1)) = 1;
% end
% 
% figure(); imagesc(I1);

%% find the closest point to each point
k = 1;
drawing_tmp = drawing_unique;
while size(drawing_tmp, 1) > 1
    A = drawing_tmp(1, :);
    drawing_tmp(1, :) = [];
    B = drawing_tmp;
    distances = sqrt(sum((B - A).^2, 2));
    % find the smallest distance and use that as an index into B:
    closest_tmp = B(distances == min(distances), :); % Masih used a find function which seemed redundant.
    closest(k, :) = closest_tmp(1, :);
    k = k + 1;
end

%% connect the each point to it's closest point
drawing_connected = [];
for i = 1:size(closest,1)
    xy1 = drawing_unique(i,:);
    xy2 = closest(i,:);
    xyConnected = connectPoints(xy1, xy2);
    drawing_connected = [drawing_connected; xyConnected];
end

drawing_connected = connect_missing_points(drawing_connected);

% throw away redundant coordinates
drawing_connected = unique(drawing_connected,'rows','stable');
% I1 = zeros(scrH_pix,scrW_pix);
% for i = 1:length(drwng_connected)
%     I1(drwng_connected(i,2),drwng_connected(i,1)) = 1;
% end
% figure(); imagesc(I1);

%% fill in the shape
inds_area = [];
for x = 1:tmsRtnTpy.Params.screen.screenXpixels
  
    indsY = find(drawing_connected(:,1) == x);
    if length(indsY) > 1
        
        y1 = min(drawing_connected(indsY,2));
        y2 = max(drawing_connected(indsY,2));
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

