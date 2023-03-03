function va = pixel2va(XY, parameters, screen)
dx = XY(:, 1) - screen.xCenter; %in pix
dy = -(XY(:, 2) - screen.yCenter); %in pix
dx_cm = dx.*screen.pixSize; %in cm
dy_cm = dy.*screen.pixSize; %in cm
r = sqrt(dx_cm.^2 + dy_cm.^2); % in cm

% compute visual angle
va = atan2d(r, parameters.viewingDistance);
end