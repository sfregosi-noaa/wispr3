# -*- coding: utf-8 -*-
"""
Created on Tue Oct  8 20:13:28 2024

@author: Chris Jones
"""
import matplotlib.pyplot as plt
import wispr3

from tkinter import filedialog as fd

names = fd.askopenfilenames()

filename = names[0]
print(filename)

# read the entire file
data  = wispr3.read_file( filename, 0, 0)

dt = 1.0 / wispr3.sampling_rate

time = [float(x)*dt for x in range(0, len(data))]

# Plot the time series data
plt.figure(figsize=(10, 6))
plt.plot(time, data)
plt.title('Time Series Plot')
plt.xlabel('Seconds')
plt.ylabel('Volts')
plt.show()



