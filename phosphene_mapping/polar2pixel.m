%function [pixCoords] = va2pixel(phi)
function coords = polar2pixel(r, theta, tmsRtnTpy)
% created by Mrugank (06/15/2022):
% rho is distance of screen from the subject, and angle is the visual angle
% of the stimulus
%%%%%%%%%
% % ro and angle are in degree on the screen
% X = (ro * cosd(angle))/Sc.pixWidth;
% Y = (ro * sind(angle))/Sc.pixWidth;
% 
% pixCoords(1,1) = round(X) + Sc.xCenter;
% pixCoords(1,2) = round(Y) + Sc.yCenter;
%%%%%%

x = r.*cosd(theta) + tmsRtnTpy.Params.screen.xCenter; % in pixel
y = (-r.*sind(theta) + tmsRtnTpy.Params.screen.yCenter); % in pixel
coords = [x; y]';

end



