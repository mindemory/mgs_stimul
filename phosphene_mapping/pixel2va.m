function [r_outer, r_inner, theta] = pixel2va(x,y,ref)
    % ref: 'cntr' if x and y are in regard to the screen center point([0 0])
    % ref: 'ul' if x and y are in regard to the upper left corner of the screen
    % positive x: left->right , positive y: up->down
    global parameters screen;
    if strcmp(ref,'cntr')
        dx = x;
        dy = -y;
    elseif strcmp(ref, 'ul')
        dx = x - screen.xCenter;
        dy = -(y - screen.yCenter);
    end

    %dx_cm = dx.*screen.pixWidth;
    %dy_cm = dy.*screen.pixWidth;

    r = abs(sqrt(dx.^2 + dy.^2)); % in pixel
    
    va = atan2d(r, parameters.viewingDistance);
    
    r_outer = parameters.viewingDistance * tand(va+parameters.rbuffer);
    r_inner = parameters.viewingDistance * tand(va-parameters.rbuffer);
    
    theta = atan2d(dy, dx);
    if theta < 0
        theta = 360 - abs(theta);
    end
end