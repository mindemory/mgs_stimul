%function [pixCoords] = va2pixel(phi)
function [pix1, pix2] = va2pixel(phi)
% created by Mrugank (06/15/2022):
% rho is distance of screen from the subject, and angle is the visual angle
% of the stimulus
global parameters screen;
rho = parameters.viewingDistance;
r_cm = rho * tand(phi/2);
pix1 = round(r_cm/screen.pixWidth); % convert cm to pixels
pix2 = round(r_cm/screen.pixHeight); % convert cm to pixels
end



