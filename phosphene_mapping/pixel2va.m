function [r_outer, r_inner, theta] = pixel2va(x,y,ref, tmsRtnTpy)
    % ref: 'cntr' if x and y are in regard to the screen center point([0 0])
    % ref: 'ul' if x and y are in regard to the upper left corner of the screen
    % positive x: left->right , positive y: up->down
    if strcmp(ref,'cntr')
        dx = x;
        dy = -y;
    elseif strcmp(ref, 'ul')
        dx = x - tmsRtnTpy.Params.screen.xCenter;
        dy = -(y - tmsRtnTpy.Params.screen.yCenter);
    end
    tmsRtnTpy.Params.taskParams.rbuffer = 2; % added temporarily
    %dx_cm = dx.*screen.pixWidth;
    %dy_cm = dy.*screen.pixWidth;

    r = abs(sqrt(dx.^2 + dy.^2)); % in pixel
    
    va = atan2d(r, tmsRtnTpy.Params.taskParams.viewingDistance);
    
    r_outer = tmsRtnTpy.Params.taskParams.viewingDistance * tand(va+tmsRtnTpy.Params.taskParams.rbuffer);
    r_inner = tmsRtnTpy.Params.taskParams.viewingDistance * tand(va-tmsRtnTpy.Params.taskParams.rbuffer);
    
    theta = atan2d(dy, dx);
    if theta < 0
        theta = 360 - abs(theta);
    end
end