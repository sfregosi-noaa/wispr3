# -*- coding: utf-8 -*-
"""
Created on Mon Oct  7 20:02:53 2024

@author: Chris Jones
"""
import serial

#from time import sleep, time

state = 0
mode = 0
status = 0
epoch = 0
sampling_rate = 0
sample_size = 0
samples_per_buffer = 0
channels = 1
gain = 0
secs_per_file = 0
second = 0
usec = 0
time = ""
sensor_id = ""
platform_id = ""
instrument_id = ""
location_id = ""
file_size = 0
buffer_size = 0
adc_type = 0
adc_vref = 0
adc_df = 0
decimation = 0
timestamp  = 0

# Example file header fields
# sensor_id = 'EOS';
# platform_id = 'OSU';
# version = 'v1.0.0';
# second = 1727961554.652455;
# file_size = 35146;
# buffer_size = 23040;
# samples_per_buffer = 7680;
# sample_size = 3;
# sampling_rate = 200000;
# channels = 1;
# samples_per_channel = 7680;
# adc_type = 'LTC2512';
# adc_vref = 5.000000;
# adc_df = 4;
# gain = 0;
# timestamp = 0;
# vmp_state = 0;
# vmp_depth = 0;
# old firelds
# time = '05:10:23:20:27:18';
# instrument_id = 'WISPR';
# location_id = 'HWSG';
# volts = 14.75;

#
# Read data buffers from a wispr dat file.
# Buffers are of fixed length (samples_per_buffer) defined by the header.
# This function will return buffer numbers in the range first to last.
# If last = 0, then read until the end of the file.
#  
def read_file( name, first, last ):
    
    global sensor_id, platform_id
    global second, file_size, buffer_size 
    global samples_per_buffer, sampling_rate, sample_size, channels
    global gain, secs_per_file

    data = []
    time = []
    
    with open( name, 'rb' ) as f:

        line = f.readline().decode('utf-8').strip()
        
        # read the file  header until a null char is found
        while True:
            line = f.readline(32).decode('utf-8').strip()
            print(line)
            if not line:
                break
            # check for the end of ascii header, which will a null char
            if line[0] == '\0':
                break
            
            # parse the line
            line = line.strip(";")
            line = line.replace(" ", "")
            #line = line.replace("'", "\"")
            [var, value] = line.split("=")
            if var == "sensor_id":
               sensor_id = value
            if var == "platform_id":
               platform_id = value
            if var == "location_id":
               location_id = value
            if var == "instrument_id":
               instrument_id = value
            if var == "second":
                second = float(value)
            if var == "time":
                time = value
            if var == "file_size":
                file_size = int(value)
            if var == "buffer_size":
                buffer_size = int(value)
            if var == "samples_per_buffer":
                samples_per_buffer = int(value)
            if var == "sampling_rate":
                sampling_rate = int(value)
            if var == "channels":
                channels = int(value)
            if var == "sample_size":
                sample_size = int(value)
            if var == "gain":
                gain = int(value)
            if var == "timestamp":
                timestamp = int(value)

        # number of adc buffer in the file            
        number_buffers = file_size * 512 / buffer_size

        dt = 1.0 / sampling_rate
        
        # duration = samples_per_buffer * dt
        # buffer_duration = samples_per_buffer * dt

    	# define number of samples per channel
        samples_per_channel = (buffer_size - timestamp) / (sample_size * channels)

    	# define number of samples per buffer
        if (samples_per_buffer != (samples_per_channel * channels)):
            print("Error: Inconsistent data file header\n")

    	# calc buffer duration based on sampling rate
        buffer_duration =  samples_per_channel / sampling_rate

        secs_per_file = buffer_duration * number_buffers

        # seek to start od data
        f.seek(512)
    
        # start time
        #t0 = (second + usec * 0.000001) + (first - 1)*buffer_duration
        t0 = second + (first - 1)*buffer_duration

        if( last == 0 ):
            last = int(number_buffers)
        
        m = sample_size
        for n in range(first, last):
        
            raw = f.read(samples_per_buffer * sample_size)
            
            if timestamp == 8:   
                sec = int.from_bytes(f.read(4), byteorder='little', unsigned=True)
                usec = int.from_bytes(f.read(4), byteorder='little', unsigned=True)
                start = ((sec + 0.000001 * usec) - buffer_duration) 
            elif timestamp == 6:
                sec = int.from_bytes(f.read(2), byteorder='little', unsigned=True)
                usec = int.from_bytes(f.read(4), byteorder='little', unsigned=True)
                start = (((second + sec) + 0.000001 * usec) - buffer_duration) 
            else:
                start = n*buffer_duration
                #start = t0 + n*buffer_duration

            for i in range(samples_per_buffer):
                j = i*sample_size
                data.append( int.from_bytes(raw[j:j+m], byteorder='little', signed=True) )
                time.append(start + i*dt)

    return data, time 

#---------------------------------------------------------------------------
# Wispr3 serial command interface
#
com_terminator = '\n'

def open_com(port, baud):

    wait = 1 # 1 second timeout

    # open a serial connection using the variables above
    ser = serial.Serial(port=port, baudrate=baud, timeout=wait)
    
    ser.flush()
    
    return ser

def close_com( ser ):
    ser.close()

    
def write_com(ser, msg):

    #crc = com_CRC(msg, len(msg))
    # skip crc
#    msg_str = "$" + msg + "*ff" + terminator
    # always use \r\n termination
    msg_str = "$" + msg + "*ff\r\n"
    ser.write(msg_str.encode('utf-8')) 
    print("> " + msg_str)

    
def read_com(ser, msg=[]):

    # read the responce
    line = ser.readline().decode('utf-8').strip()    
#    line = ser.read_until(com_terminator).decode('utf-8').strip()
    print("< " + line)
    if line:  # parse if the line is not empty
        line = line.strip("\x00")
        line = line.strip("\r")
        line = line.strip("$")
        [msg,crc] = line.split("*")
        # check crc - skip for now
        msg = msg.split(",")
        #cmd = msg[0];
        #args = msg[1:len(msg)]

    return msg


