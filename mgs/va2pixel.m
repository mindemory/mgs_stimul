function [pixCoords] = va2pixel(Sc,ro,angle)
% ro and angle are in degree on the screen

X = (ro * cosd(angle))/Sc.pixWidth;
Y = (ro * sind(angle))/Sc.pixWidth;

pixCoords(1,1) = round(X) + Sc.xCenter;
pixCoords(1,2) = round(Y) + Sc.yCenter;