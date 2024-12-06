"""
Created on Mon Oct  7 12:01:26 2024

@author: Chris Jones
"""

#!/usr/bin/env python
# -*- coding: utf-8 -*-

#import the PySerial library and sleep from the time library
import wispr
import time

# declare to variables, holding the com port we wish to talk to and the speed
port = 'COM10'

# open a serial connection using the variables above
ser = wispr.open_com(port, 9600)

# wait for a moment before doing anything else
time.sleep(0.2)

ser.flush();

print("Serial port open\n")

# Tun off msg ack
wispr.write_com(ser, "NAK") 

time.sleep(0.2)

# Send STA Command 
wispr.write_com(ser, "STA")

# Read and parse PAM message
msg = wispr.read_com(ser)
if msg[0] == 'PAM':
    epoch = int(msg[1])       
    state = int(msg[2],16)       
    mode = int(msg[3],16)
    status = int(msg[4],16)
    sampling_rate = int(msg[5])
    sample_size = int(msg[6])
    gain = int(msg[7])
    secs_per_fie = float(msg[8])
 
# Send ADC command to change sampling rate and file size
cmd = "ADC,3,50000,8,0,10,0" 
wispr.write_com(ser, cmd)
time.sleep(0.2)

# Set time with TME Command 
epoch = int(time.time())
cmd = "TME," + str(epoch)
wispr.write_com(ser, cmd)
time.sleep(0.2)

print("Ready to start data collection.")

go = 1
while (go):
    cmd = input("Enter RUN, PAU or EXI command: ")

    # Send PAU command to stop collecting data
    wispr.write_com(ser, cmd)

    if (cmd == 'EXI'):
       go = 0
       

wispr.close_com(ser)

print("Serial port closed\n")

# now power down wispr
print("OK to power down\n")

    
