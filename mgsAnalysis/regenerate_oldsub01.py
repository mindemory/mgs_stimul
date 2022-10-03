import numpy as np
import matplotlib.pyplot as plt
title_fontsize = 19
axes_fontsize = 16
leg_fontsize = 16
msize = 12
direct = {}
direct['datc'] =  '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc'
direct['Figures'] = direct['datc'] + '/Figures'


fig = plt.figure(figsize = (7, 9))
fname = '/sub01_olddata.pdf'

X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [0.75, 1.2, 0.8]
Y2 = [0.9, 1.18, 0.91]
Yerr1 = [0.1, 0.2, 0.15]
Yerr2 = [0.1, 0.2, 0.15]
X_sum = [sum(value) for value in zip(X1, X2)]
x_tick_pos = [round(x/2, 1) for x in X_sum]
LIMS_x = max(X2) + 0.2
LIMS_y = max(max(Y1), max(Y2)) * 1.2
LIMS = [LIMS_x, LIMS_y]
x_label_names = ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF']
leg_names = ['pro', 'anti']
#plt.title('sub' + subjID + ' ' + metric, fontsize = title_fontsize)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'blue', 
            markersize = msize, markerfacecolor = 'blue', markeredgecolor = 'blue', label = '_nolegend_')
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = msize, markerfacecolor = 'red', markeredgecolor = 'red', label = '_nolegend_')
plt.plot(X1, Y1, 'bo--', label = leg_names[0], markersize = msize)
plt.plot(X2, Y2, 'ro--', label = leg_names[1], markersize = msize)
plt.xlim(0, LIMS[0])
plt.ylim(0, 1.5)
plt.yticks([0, 0.5, 1.0, 1.5])
plt.xticks([])
#plt.xticks(x_tick_pos, x_label_names, fontsize = axes_fontsize)
#plt.legend(fontsize = leg_fontsize)
#plt.ylabel('MGS Error', fontsize = axes_fontsize)
fig.savefig(direct['Figures'] + fname, dpi = 600, format='pdf')