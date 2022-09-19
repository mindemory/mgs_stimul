import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.stats import sem

baseline_mean_pro = 1
baseline_mean_anti = 1.5
baseline_variance = 0.5
sample_size = 100
increased_mean = 0.3

direct = {}
direct['datc'] =  '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc'
direct['data'] = direct['datc'] + '/data'
direct['analysis'] = direct['datc'] + '/analysis'
direct['Figures'] = direct['datc'] + '/Figures'
plt.rc('ytick', labelsize = 12)

# Predictions for null result
notms_pro = np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
notms_anti = np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
prointoVF = np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
prooutVF = np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
antiintoVF = np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
antioutVF = np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
fig1 = plt.figure()
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(notms_pro), np.mean(prointoVF), np.mean(prooutVF)]
Y2 = [np.mean(notms_anti), np.mean(antiintoVF), np.mean(antioutVF)]
Yerr1 = [sem(notms_pro), sem(prointoVF), sem(prooutVF)]
Yerr2 = [sem(notms_anti), sem(antiintoVF), sem(antioutVF)]
plt.title('No effect of TMS', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
plt.ylim(0, 2)
plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
#plt.show()
figname = direct['Figures'] + '/prediction0.png'
fig1.savefig(figname, dpi = fig1.dpi, format = 'png')

# Predictions for TMS effect only for intoVF
notms_pro = np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
notms_anti = np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
prointoVF = increased_mean+np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
prooutVF = np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
antiintoVF = increased_mean+np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
antioutVF = np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
fig2 = plt.figure()
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(notms_pro), np.mean(prointoVF), np.mean(prooutVF)]
Y2 = [np.mean(notms_anti), np.mean(antiintoVF), np.mean(antioutVF)]
Yerr1 = [sem(notms_pro), sem(prointoVF), sem(prooutVF)]
Yerr2 = [sem(notms_anti), sem(antiintoVF), sem(antioutVF)]
plt.title('TMS effect only for intoVF', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
plt.ylim(0, 2)
plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
#plt.show()
figname = direct['Figures'] + '/prediction1.png'
fig2.savefig(figname, dpi = fig2.dpi, format = 'png')

# Predictions for TMS effect for both intoVF and outVF
notms_pro = np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
notms_anti = np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
prointoVF = increased_mean+np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
prooutVF = increased_mean+np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
antiintoVF = increased_mean+np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
antioutVF = increased_mean+np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
fig3 = plt.figure()
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(notms_pro), np.mean(prointoVF), np.mean(prooutVF)]
Y2 = [np.mean(notms_anti), np.mean(antiintoVF), np.mean(antioutVF)]
Yerr1 = [sem(notms_pro), sem(prointoVF), sem(prooutVF)]
Yerr2 = [sem(notms_anti), sem(antiintoVF), sem(antioutVF)]
plt.title('TMS effect for both intoVF and outVF', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
plt.ylim(0, 2)
plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
#plt.show()
figname = direct['Figures'] + '/prediction2.png'
fig3.savefig(figname, dpi = fig3.dpi, format = 'png')

# Predictions for TMS effect only if stimulus is inVF
notms_pro = np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
notms_anti = np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
prointoVF = increased_mean+np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
prooutVF = np.random.normal(baseline_mean_pro, baseline_variance, sample_size)
antiintoVF = np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
antioutVF = increased_mean+np.random.normal(baseline_mean_anti, baseline_variance, sample_size)
fig4 = plt.figure()
X1 = [0.3, 0.8, 1.3]
X2 = [0.4, 0.9, 1.4]
Y1 = [np.mean(notms_pro), np.mean(prointoVF), np.mean(prooutVF)]
Y2 = [np.mean(notms_anti), np.mean(antiintoVF), np.mean(antioutVF)]
Yerr1 = [sem(notms_pro), sem(prointoVF), sem(prooutVF)]
Yerr2 = [sem(notms_anti), sem(antiintoVF), sem(antioutVF)]
plt.title(' TMS effect only if stimulus is inVF', fontsize = 16)
plt.errorbar(X1, Y1, yerr = Yerr1, fmt = '.', ecolor = 'green', 
            markersize = 10, markerfacecolor = 'green', markeredgecolor = 'green', label = 'pro')
plt.errorbar(X2, Y2, yerr = Yerr2, fmt = '.', ecolor = 'red', 
            markersize = 10, markerfacecolor = 'red', markeredgecolor = 'red', label = 'anti')
plt.xlim(0, 1.6)
plt.ylim(0, 2)
plt.xticks([0.35, 0.85, 1.35], ['No TMS', 'MGS into\n TMS VF', 'MGS away\n from TMS VF'], fontsize = 12)
plt.legend()
plt.ylabel('MGS Error', fontsize = 12)
#plt.show()
figname = direct['Figures'] + '/prediction3.png'
fig4.savefig(figname, dpi = fig4.dpi, format = 'png')
