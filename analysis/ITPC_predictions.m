clear; close all; clc;
phase = 0:0.01:2*pi;

ITPC = 0.5 + 0.2 * cos(phase);
figure
plot(phase, ITPC, 'LineWidth', 2)
xlabel('Endogenous phase', FontSize = 15)
xticks([0, pi/2, pi, 3*pi/2, 2*pi])
xticklabels({'0', 'pi/2', 'pi', '3*pi/2', '2*pi'})
xlim([0, 2*pi])
ylim([0.2, 0.8])
ylabel('ITPC', FontSize = 15)
