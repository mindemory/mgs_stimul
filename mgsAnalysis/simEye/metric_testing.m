% In this simulation, the target is placed at the center of the screen and
% the scatter_x and scatter_y generates different saccade points uniformly
% across the screen. Compute_errors computes the regular errors that would
% be expected to be reported like Euclidean error, radial error, angular
% error and error in dva. It also computes the error as computed by iEye.
% The error computed by iEye seems to capture a very small picture of the
% actual error dynamics that one would expect in the saccade data.

clear; close all; clc;

p.xwidth = 1080; p.ywidth = 1920;
p.xcenter = p.xwidth/2;
p.ycenter = p.ywidth/2;
p.viewDistance = 55; % cm
p.ppd = (p.viewDistance * tand(1))/0.0264;
numpoints = 1e5;
scatter_x = randi([0, 1.5*p.xcenter], numpoints, 1);
scatter_y = randi([0, 1.5*p.ycenter], numpoints, 1);

target_x = 2*p.xcenter/3;%randi(p.xwidth, 1, 1);
target_y = 2*p.ycenter/3;%randi(p.ywidth, 1, 1);


[real, iEye] = compute_errors(scatter_x, scatter_y, target_x, target_y, p);
figure()
plot(scatter_x, scatter_y, 'ro')
hold on;
plot(target_x, target_y, 'k+', 'MarkerSize', 10, 'LineWidth', 2)
xlim([0, p.xwidth])
ylim([0, p.ywidth])

figure()
subplot(2, 2, 1)
plot(iEye.euclidean, abs(real.euclidean), 'ko');
%xlim([0, 10])
xlabel('iEye error')
ylabel('Euclidean error')

subplot(2, 2, 2)
plot(iEye.euclidean, real.dva, 'ko');
hold on;
plot(0:10, 0:10, 'r--')
%xlim([0, 10])
xlabel('iEye error')
ylabel('DVA error')

subplot(2, 2, 3)
plot(iEye.euclidean, real.r, 'ko');
%xlim([0, 10])
xlabel('iEye error')
ylabel('radius error')

subplot(2, 2, 4)
plot(iEye.euclidean, real.theta, 'ko');
%xlim([0, 10])
xlabel('iEye error')
ylabel('theta error')