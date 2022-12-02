import numpy as np
import matplotlib.pyplot as plt

direct = {}
direct['datc'] =  '/Users/mrugankdake/Documents/Clayspace/EEG_TMS/datc'
direct['Figures'] = direct['datc'] + '/Figures'

fig = plt.figure()
fname = '/harrison_tong_memory.png'
time = [0, 2, 4, 6, 8, 10, 12, 14]
perception = [50, 50, 65, 71, 75, 71, 75, 73]
memory = [49, 46, 53, 62, 70, 68, 68, 67]
cc_level = [50, 50, 50, 50, 50, 50, 50, 50]
plt.plot(time, perception, 'ro-', label = 'perception')
plt.plot(time, memory, 'bo-', label = 'working memory')
plt.plot(time, cc_level, 'k--', label = '_no_legend_')
plt.xlabel('Time (s)')
plt.ylabel('Decoding Accuracy (%)')
plt.xlim([-0.5, 14.5])
plt.ylim([40, 100])
plt.legend()
fig.savefig(direct['Figures'] + fname, dpi = 600, format='png')