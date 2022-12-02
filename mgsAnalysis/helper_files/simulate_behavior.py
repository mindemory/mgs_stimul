from ssl import ALERT_DESCRIPTION_UNEXPECTED_MESSAGE
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.stats import sem

baseline_mean_pro = 1
baseline_mean_anti = 1.5
baseline_variance = 0.5
sample_size = 100
increased_mean = 0.3
targ_dpi = 600
direct = {}
direct['datc'] =  '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc'
direct['data'] = direct['datc'] + '/data'
direct['analysis'] = direct['datc'] + '/analysis'
direct['Figures'] = direct['datc'] + '/Figures'
plt.rc('ytick', labelsize = 12)

# Predictions for null result
notms_pro = baseline_mean_pro #np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
notms_anti = baseline_mean_anti #np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
prointoVF = baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
prooutVF = baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
antiintoVF = baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
antioutVF = baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)

title_fontsize = 19
axes_fontsize = 16
leg_fontsize = 16
msize = 12
fig1 = plt.figure(figsize = (7, 9))
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(notms_pro), np.mean(prointoVF), np.mean(prooutVF)]
Y2 = [np.mean(notms_anti), np.mean(antiintoVF), np.mean(antioutVF)]
#Yerr1 = [sem(notms_pro), sem(prointoVF), sem(prooutVF)]
#Yerr2 = [sem(notms_anti), sem(antiintoVF), sem(antioutVF)]
#plt.title('No effect of TMS', fontsize = title_fontsize)
plt.plot(X1, Y1, 'bo--', label = 'pro', markersize = msize)
plt.plot(X2, Y2, 'ro--', label = 'anti', markersize = msize)
# plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
#             markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
# plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
#             markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
plt.ylim(0, 2)
plt.xticks([])
#plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = axes_fontsize)
plt.yticks([])
#plt.legend(fontsize = leg_fontsize)
#plt.ylabel('MGS Error\n (dva)', fontsize = axes_fontsize)
#plt.show()
figname = direct['Figures'] + '/prediction0.pdf'
fig1.savefig(figname, dpi = 600, format = 'pdf')

# Predictions for TMS effect only for intoVF
notms_pro = baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
notms_anti = baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
prointoVF = increased_mean+baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
prooutVF = baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
antiintoVF = increased_mean+baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
antioutVF = baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
fig2 = plt.figure(figsize = (7, 9))
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(notms_pro), np.mean(prointoVF), np.mean(prooutVF)]
Y2 = [np.mean(notms_anti), np.mean(antiintoVF), np.mean(antioutVF)]
#Yerr1 = [sem(notms_pro), sem(prointoVF), sem(prooutVF)]
#Yerr2 = [sem(notms_anti), sem(antiintoVF), sem(antioutVF)]
#plt.title('TMS effect only for MGS intoVF', fontsize = title_fontsize)
# plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
#             markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
# plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
#             markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.plot(X1, Y1, 'bo--', label = 'pro', markersize = msize)
plt.plot(X2, Y2, 'ro--', label = 'anti', markersize = msize)
plt.xlim(0, 1.6)
plt.ylim(0, 2)
plt.xticks([])
#plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = axes_fontsize)
plt.yticks([])
#plt.legend(fontsize = leg_fontsize)
#plt.ylabel('MGS Error\n (dva)', fontsize = axes_fontsize)
#plt.show()
figname = direct['Figures'] + '/prediction1.pdf'
fig2.savefig(figname, dpi = 600, format = 'pdf')

# Predictions for TMS effect for both intoVF and outVF
notms_pro = baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
notms_anti = baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
prointoVF = increased_mean+baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
prooutVF = increased_mean+baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
antiintoVF = increased_mean+baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
antioutVF = increased_mean+baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
fig3 = plt.figure(figsize = (7, 9))
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(notms_pro), np.mean(prointoVF), np.mean(prooutVF)]
Y2 = [np.mean(notms_anti), np.mean(antiintoVF), np.mean(antioutVF)]
# Yerr1 = [sem(notms_pro), sem(prointoVF), sem(prooutVF)]
# Yerr2 = [sem(notms_anti), sem(antiintoVF), sem(antioutVF)]
#plt.title('TMS effect for all conditions', fontsize = title_fontsize)
plt.plot(X1, Y1, 'bo--', label = 'pro', markersize = msize)
plt.plot(X2, Y2, 'ro--', label = 'anti', markersize = msize)
# plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
#             markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
# plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
#             markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
plt.ylim(0, 2)
plt.xticks([])
#plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = axes_fontsize)
plt.yticks([])
#plt.legend(fontsize = leg_fontsize)
#plt.ylabel('MGS Error\n (dva)', fontsize = axes_fontsize)
#plt.show()
figname = direct['Figures'] + '/prediction2.pdf'
fig3.savefig(figname, dpi = 600, format = 'pdf')

# Predictions for TMS effect only if stimulus is inVF
notms_pro = baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
notms_anti = baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
prointoVF = increased_mean+baseline_mean_pro#increased_mean+np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
prooutVF = baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
antiintoVF = baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
antioutVF = increased_mean+baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
fig4 = plt.figure(figsize = (7, 9))
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(notms_pro), np.mean(prointoVF), np.mean(prooutVF)]
Y2 = [np.mean(notms_anti), np.mean(antiintoVF), np.mean(antioutVF)]
# Yerr1 = [sem(notms_pro), sem(prointoVF), sem(prooutVF)]
# Yerr2 = [sem(notms_anti), sem(antiintoVF), sem(antioutVF)]
#plt.title(' TMS effect only for stimulus intoVF', fontsize = title_fontsize)
plt.plot(X1, Y1, 'bo--', label = 'pro', markersize = msize)
plt.plot(X2, Y2, 'ro--', label = 'anti', markersize = msize)
# plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
#             markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
# plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
#             markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
plt.ylim(0, 2)
plt.xticks([])
#plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = axes_fontsize)
plt.yticks([])
#plt.legend(fontsize = leg_fontsize)
#plt.ylabel('MGS Error\n (dva)', fontsize = axes_fontsize)
#plt.show()
figname = direct['Figures'] + '/prediction3.pdf'
fig4.savefig(figname, dpi = targ_dpi, format = 'pdf')

# Predictions for TMS effect when either stimulus or memory is into VF
notms_pro = baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
notms_anti = baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
prointoVF = increased_mean+baseline_mean_pro#increased_mean+np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
prooutVF = baseline_mean_pro#np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
antiintoVF = increased_mean+baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
antioutVF = increased_mean+baseline_mean_anti#np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
fig5 = plt.figure(figsize = (7, 9))
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(notms_pro), np.mean(prointoVF), np.mean(prooutVF)]
Y2 = [np.mean(notms_anti), np.mean(antiintoVF), np.mean(antioutVF)]
# Yerr1 = [sem(notms_pro), sem(prointoVF), sem(prooutVF)]
# Yerr2 = [sem(notms_anti), sem(antiintoVF), sem(antioutVF)]
#plt.title('TMS effect for both stimulus and memory intoVF', fontsize = 18)
plt.plot(X1, Y1, 'bo--', label = 'pro', markersize = msize)
plt.plot(X2, Y2, 'ro--', label = 'anti', markersize = msize)
# plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
#             markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
# plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
#             markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
plt.ylim(0, 2)
plt.xticks([])
#plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = axes_fontsize)
plt.yticks([])
#plt.legend(fontsize = leg_fontsize)
#plt.ylabel('MGS Error\n (dva)', fontsize = axes_fontsize)
#plt.show()
figname = direct['Figures'] + '/prediction4.pdf'
fig5.savefig(figname, dpi = 600, format = 'pdf')

