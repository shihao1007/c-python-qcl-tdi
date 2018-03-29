# -*- coding: utf-8 -*-
"""
Created on Wed Mar 28 10:15:00 2018

@author: shihao
"""

import numpy as np
from matplotlib import pyplot as plt

dataname = r'C:\Users\shihao\Desktop\ir-images\ir-holography\laser-labview\test3\64k\laseron2.txt'
a = np.zeros(250000)
a = np.loadtxt(dataname)
sampling_rate = 250000
b = np.arange(0,1,0.000004)
n = a.size
timestep = 0.000004
freq = np.fft.fftfreq(n, d=timestep)
sp = np.fft.fft(a)
T = 1/sampling_rate # inverse of the sampling rate
x = np.linspace(0.0, 1.0/(2.0*T), int(n/2))
y = 2/n * np.abs(sp[0:np.int(n/2)])

plt.figure()
plt.plot(b, a)
plt.xlabel('Time (s)')
plt.ylabel('Amplitede')
plt.title('Time Domain (Laser On 64kHz 2nd)');
plt.grid(True)
plt.show()

plt.figure()
plt.plot(x, y)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Amplitede')
plt.title('Frequency Domain (Laser On 64kHz 2nd)');
plt.grid(True)
plt.show()