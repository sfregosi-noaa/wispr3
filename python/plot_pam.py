# -*- coding: utf-8 -*-
"""
Created on Tue Oct  8 20:13:28 2024

@author: Chris Jones
"""
import wispr3 as wispr
#import numpy as np
#from scipy import signal
import matplotlib.pyplot as plt
from tkinter import filedialog as fd

names = fd.askopenfilenames()

filename = names[0]
print(filename)

# read the entire file
data, time  = wispr.read_file( filename, 0, 0)

#dt = 1.0 / wispr3.sampling_rate

#time = [float(x)*dt for x in range(0, len(data))]

# Plot the time series data
plt.figure(figsize=(10, 6))
plt.plot(time, data)
plt.title('Time Series Plot')
plt.xlabel('Seconds')
plt.ylabel('Volts')
plt.show()

# Matplotlib.pyplot.specgram() function to
# generate spectrogram
fs = wispr.sampling_rate
plt.figure(figsize=(10, 6))

#f, t, S = signal.spectrogram(np.array(data), fs)
#plt.pcolormesh(t, f, S, shading='gouraud')
plt.specgram(data, Fs=fs, cmap="jet")

plt.title('Spectrogram')
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.show()

 
