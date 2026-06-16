#!/usr/bin/env python

from datetime import datetime

import os
import psutil
import psycopg2
import socket

conn = "unknown"

# write percentages to TimescaleDB
def writeP(key, value):
    write('percentages',key,value)

# write data to TimescaleDB
def write(table, key, value):
    try:
        global conn  
        # create a cursor      
        cur = conn.cursor()   
        # execute a statement
        sql = 'insert into '+table+' (time, key, value) values (now(), %s, %s)'
        cur.execute(sql, (key,value,))   
        # commit the changes to the database
        conn.commit()
        # close the communication with the PostgreSQL
        cur.close()
    except Exception as ex:
        print ("ERROR: ", ex) 
        cur.execute("rollback")

# exec in db
def exec(sql):
    try:
        global conn
        # create a cursor
        cur = conn.cursor()   
        # execute a statement
        cur.execute(sql)  
        # commit the changes to the database
        conn.commit()
        # close the communication with the PostgreSQL
        cur.close()
    except Exception as ex:
        print ("ERROR: ", ex) 
        cur.execute("rollback")

def connect():
    try:       
        
        #init Timescaledb
        global conn
        conn = psycopg2.connect(
            host=os.environ['TIMESCALEDB_HOST'],
            database="postgres",
            user=os.environ['TIMESCALEDB_USERNAME'],
            password=os.environ['TIMESCALEDB_PASSWORD'])
        
    except Exception as ex:
        print ("ERROR: ", ex)         

def close():
    global conn
    conn.close()

if __name__ == "__main__":  
    # print (datetime.now().strftime("%d/%m/%Y %H:%M:%S") + " START #####")
    try:
        # connect to timescaledb
        connect()

        hostname = socket.gethostname()
        # print(hostname)

        # get CPU load
        cpu_percent = round(psutil.cpu_percent()) / 100
        # print(cpu_percent)
        writeP('xmrig_cpu_' + hostname, cpu_percent)

        # search xmrig process
        xmrig_found = 0
        for proc in psutil.process_iter(['pid', 'name', 'username']):
            if 'xmrig' in proc.name():
                xmrig_found = 1
        # print(xmrig_found)
        writeP('xmrig_' + hostname, xmrig_found)

        print(datetime.now().strftime("%d/%m/%Y %H:%M:%S") + ' ' + hostname + ': ' + str(cpu_percent) + ', xmrig: ' + str(xmrig_found))

        # close connection to timescaledb
        close()

        # print (datetime.now().strftime("%d/%m/%Y %H:%M:%S") + " END #####")
        
    except Exception as ex:
        print ("ERROR: ", ex)     
