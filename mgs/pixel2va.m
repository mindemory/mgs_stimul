function [ecc,theta] = pixel2va(x,y,ref)
    % ref: 'cntr' if x and y are in regard to the screen center point([0 0])
    % ref: 'ul' if x and y are in regard to the upper left corner of the screen
    % positive x: left->right , positive y: up->down
    global screen;
    if strcmp(ref,'cntr')
        dx = x;
        dy = -y;
    elseif strcmp(ref, 'ul')
        dx = x - screen.xCenter;
        dy = -(y - screen.yCenter);
    end

    dx_va = dx./screen.pixels_per_deg_width;
    dy_va = dy./screen.pixels_per_deg_height;

    ecc = sqrt(dx_va.^2 + dy_va.^2);

    theta = atan2d(dy,dx);
    if theta < 0
        theta = 360 - abs(theta);
end