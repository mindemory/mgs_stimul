function dotSize = computeDotSize(parameters, XY)
% positive x: left->right , positive y: up->down


dx = XY(:, 1) - parameters.xCenter;
dy = -(XY(:, 2) - parameters.yCenter);


dx_cm = dx.*parameters.pixSize;
dy_cm = dy.*parameters.pixSize;

r = sqrt(dx_cm.^2 + dy_cm.^2); % in cm

va = atan2d(r, parameters.viewingDistance);
va_lower = va - parameters.dotSize/2;
va_upper = va + parameters.dotSize/2;

r_lower_cm = parameters.viewingDistance .* tand(va_lower); %in cm
r_upper_cm = parameters.viewingDistance .* tand(va_upper); %in cm

r_lower = round((abs(r_lower_cm-r))./parameters.pixSize); %in pix
r_upper = round((abs(r_upper_cm-r))./parameters.pixSize); %in pix
dotSize = max([r_lower, r_upper], [], 2);
end