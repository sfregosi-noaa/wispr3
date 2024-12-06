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
channels = 0
gain = 0
secs_per_file = 0
second = 0
usec = 0
sensor_id = 0
platform_id = 0
instrument_id = 0
location_id = 0
file_size = 0
buffer_size = 0
adc_type = 0
adc_vref = 0
adc_df = 0
decimation = 0
timestamp  = 0


def read_file( name, first, last ):
    
    global second, file_size, buffer_size, samples_per_buffer, sampling_rate, sample_size, gain, secs_per_file

    data = []
    stamp = []
    
    with open( name, 'rb' ) as f:

        line = f.readline().decode('utf-8').strip()
        # read the file  header until a null char is found
        while True:
            line = f.readline(32).decode('utf-8').strip()
            print(line)
            if not line:
                break
            if line[0] == '\0':
                break
            line = line.strip(";")
            line = line.replace(" ", "")
            #line = line.replace("'", "\"")
            [var, value] = line.split("=")
            if var == "second":
                second = float(value)
            if var == "file_size":
                file_size = int(value)
            if var == "buffer_size":
                buffer_size = int(value)
            if var == "samples_per_buffer":
                samples_per_buffer = int(value)
            if var == "sampling_rate":
                sampling_rate = int(value)
            if var == "sample_size":
                sample_size = int(value)
            if var == "gain":
                gain = int(value)
            if var == "timestamp":
                timestamp = int(value)
            
        number_buffers = file_size * 512 / buffer_size
        dt = 1.0 / sampling_rate
        duration = samples_per_buffer * dt
        buffer_duration = samples_per_buffer * dt
        file_duration = buffer_duration * number_buffers

        # seek to start od data
        f.seek(512)
    
        # start time
        #t0 = (second + usec * 0.000001) + (first - 1)*duration
        t0 = second + (first - 1)*duration

        if( last == 0 ):
            last = int(number_buffers)
            
        m = sample_size
        for n in range(first, last):
        
            raw = f.read(samples_per_buffer * sample_size )
            for i in range(samples_per_buffer):
                j = i*sample_size
                data.append( int.from_bytes(raw[j:j+m], byteorder='little', signed=True) )

            if timestamp == 8:   
                sec = int.from_bytes(f.read(4), byteorder='little', unsigned=True)
                usec = int.from_bytes(f.read(4), byteorder='little', unsigned=True)
                stamp.append((sec + 0.000001 * usec) - duration) 
            elif timestamp == 6:
                sec = int.from_bytes(f.read(2), byteorder='little', unsigned=True)
                usec = int.from_bytes(f.read(4), byteorder='little', unsigned=True)
                stamp.append(((second + sec) + 0.000001 * usec) - duration) 
            else:
                stamp.append(t0)

    return data 

#----------------------------------------------------------------
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


