%function [pixCoords] = va2pixel(phi)
function [r_pix_width, r_pix_height] = va2pixel(phi)
% rho is distance of screen from the subject, and angle is the visual angle
% of the stimulus
global parameters screen;
%%%%%%%%%
% % ro and angle are in degree on the screen
% X = (ro * cosd(angle))/Sc.pixWidth;
% Y = (ro * sind(angle))/Sc.pixWidth;
% 
% pixCoords(1,1) = round(X) + Sc.xCenter;
% pixCoords(1,2) = round(Y) + Sc.yCenter;
%%%%%%
rho = parameters.viewingDistance;
r_cm = rho * tand(phi/2);
r_pix_width = round(r_cm/screen.pixWidth);
r_pix_height = round(r_cm/screen.pixHeight);
