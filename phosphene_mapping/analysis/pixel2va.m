function [r_outer, r_inner, theta] = pixel2va(XY,ref, tmsRtnTpy)
    % ref: 'cntr' if x and y are in regard to the screen center point([0 0])
    % ref: 'ul' if x and y are in regard to the upper left corner of the screen
    % positive x: left->right , positive y: up->down
    if strcmp(ref,'cntr')
        dx = XY(1);
        dy = -XY(2);
    elseif strcmp(ref, 'ul')
        dx = XY(1) - tmsRtnTpy.Params.screen.xCenter;
        dy = -(XY(2) - tmsRtnTpy.Params.screen.yCenter);
    end
    % convert to cm
    dx_cm = dx.*tmsRtnTpy.Params.screen.pixWidth;
    dy_cm = dy.*tmsRtnTpy.Params.screen.pixHeight;
    
    % compute euclidean distance of XY from center
    r = abs(sqrt(dx_cm.^2 + dy_cm.^2)); % in cm
    
    % compute visual angle subtended by XY
    va = atan2d(r, tmsRtnTpy.Params.taskParams.viewingDistance);
    
    % compute r given a buffer of visual angle
    r_outer_cm = tmsRtnTpy.Params.taskParams.viewingDistance * tand(va+tmsRtnTpy.Params.taskParams.rbuffer); % in cm
    r_inner_cm = tmsRtnTpy.Params.taskParams.viewingDistance * tand(va-tmsRtnTpy.Params.taskParams.rbuffer); % in cm
    
    r_outer = r_outer_cm./tmsRtnTpy.Params.screen.pixWidth;
    % polar angle of XY
    theta = atan2d(dy_cm, dx_cm);
    if theta < 0
        theta = 360 - abs(theta);
    end
    % boundary of polar angles
    theta_range = theta-45:1:theta+45;
    theta_range(theta_range<0) = 360 + theta_range(theta_range<0); % accounting for angles between 0 to 360
    x = r.*cosd(theta) + tmsRtnTpy.Params.screen.xCenter; % in pixel
    y = (-r.*sind(theta) + tmsRtnTpy.Params.screen.yCenter); % in pixel
    coords = [x; y]';
    
    %%%%%%%
    edge1 = connectPoints(coords_outer(1, :), coords_inner(1, :));
    edge2 = connectPoints(coords_outer(end, :), coords_inner(end, :));
    
    coords_all = [edge1; coords_outer; flip(edge2); flip(coords_inner)];
    coords_all = round(coords_all);
end