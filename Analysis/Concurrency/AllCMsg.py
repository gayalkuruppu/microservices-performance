000# ----------------------------------------------------------------------------
# Generating CSV Files
# ----------------------------------------------------------------------------

########################################
#------------Imports----------------#
########################################

import sys
from random import randint
import csv
import os
import matplotlib.pyplot as plt
import sys
import math
import numpy as np
import seaborn as sns
import scipy.stats as st
from scipy.stats._continuous_distns import _distn_names
from scipy.optimize import curve_fit
import random

########################################
#------------Variables-----------------#
########################################

concurrent_users=[1, 2, 50, 100, 300, 500, 700, 1000] 
message_sizes=[50, 400, 1024]
num_services=[1, 2, 3]

#CSV file
csv_file_records = []
headers = ['Message Size', 'Num Service', 'Users', 'Throughput','Avg_Latency', 'percentile_10', 'percentile_50', 'percentile_90', 'percentile_99', 'percentile_99.9','percentile_99.99','Std','Tail Index']
csv_file_records.append(headers)

#For testing
#concurrent_users=[1000] 
#message_sizes=[1024]
#num_services=[1]


########################################
#------------File Paths------------#
########################################

jtl_location="/media/jayathma/OS/Jayathma_R/Results/echoes/Msg"
summary_location="/media/jayathma/PartitionE/Jayathma_R/TransformedCSV/Msg_Sizes"
output_csv_location="/media/jayathma/PartitionE/Jayathma_R/TransformedCSV/Msg_Sizes/chain.csv"

########################################
#------------Functions-----------------#
########################################

def getLatencyList(filename):
    if os.path.isfile(filename):

        latencies = []
        with open(filename) as f:
            content = f.readlines()
            content=content[1:]
            for row in content:
                success = row.strip().split(",")[7]
                latency = row.strip().split(",")[-3]
                if(success == "true"):
                    latencies.append(int(latency))
        return latencies

    else:
        print("File doesn't exists")
        return []

def get_TPS(filename,user):
	with open(filename, 'r') as csvfile:
		plots= csv.reader(csvfile, delimiter=',')
		for row in plots:
			if int(row[0]) == user:
				print (user)
				return float(row[7])
		print("TPS not found")
		return 0

def getAverageLatency(latency_values):
    #return sum(latency_values)/len(latency_values
	return np.average(latency_values)

def get_percentile(latency_values, percentile):
    return np.percentile(latency_values, percentile)

def get_std(latency_values, average):
	return np.std(latency_values)

def get_variance(latency_values, average):
	variance = 0
	for i in latency_values:
		variance += (average - latency_values[i]) ** 2
	return variance / len(latency_values)



def get_cdf(latency_values):
    a = np.array(latency_values)
    ag = st.gaussian_kde(a, bw_method=1e-3)

    cdf = [0]
    x = []
    k = 0

    max_data = max(latency_values)

    while k < max_data:
        x.append(k)
        k = k + 1

    sum_integral = 0

    for i in range(1, len(x)):
        sum_integral = sum_integral + (trapezoidal_cdf(ag, x[i - 1], x[i], 10))
        cdf.append(sum_integral)

    return x, cdf

def trapezoidal_mass(ag, a, b, n):
    h = np.float(b - a) / n
    s = 0.0
    s += a*ag(a)[0]/2.0
    for i in range(1, n):
        s += (a + i*h)*ag(a + i*h)[0]
    s += b*ag(b)[0]/2.0
    return s * h

def trapezoidal_cdf(ag, a, b, n):
	h = np.float(b - a) / n
	s = 0.0
	s += ag(a)[0]/2.0
	for i in range(1, n):
		s += ag(a + i*h)[0]
	s += ag(b)[0]/2.0
	return s * h

def get_survival_function(x, y):
	sf = []
	for i in y:
		sf.append(abs(1-i))
	return x, sf

def get_log_log_complementary_graph(x_cdf, y_cdf):
	xs, ys = get_survival_function(x_cdf, y_cdf)
	xs = [math.log10(i+1/sys.maxsize) for i in xs]
	ys = [math.log10(i+1/sys.maxsize) for i in ys]
	return xs[1:len(xs)-1], ys[1:len(ys)-1]


def f(x, A, B):
    return A*x + B


def get_max_n_samples(x, n):
    x.sort()
    return x[len(x)-n:]


def get_tail_index(xs, ys, latency_values, k = 0.01):
	start_item= get_max_n_samples(latency_values, int(k * len(latency_values)))[0]
	start_item_log = math.log10(start_item)
	tail_x = []
	tail_y = []
	for i in range(len(xs)):
		if xs[i] >= start_item_log:
			tail_x.append(xs[i])
			tail_y.append(ys[i])
	return curve_fit(f, tail_x, tail_y)[0]



########################################
#------------Process Begins-----------#
########################################

# Generating JTL files
for size in message_sizes:
	
	for num in num_services:
		
		for user in concurrent_users:
			
			jtl_file_name = jtl_location+"/"+str(num)+"_Msg/jtls/"+str(size)+"_message/"+str(user)+"_users/results-measurement.jtl"
			
			summary_file_name = summary_location+"/"+str(num)+"_chain/"+str(num)+"_"+str(size)+".csv"
			
			print ("Report location is " + jtl_file_name)
			print (summary_file_name)
			
			#latency_values = getLatencyList(jtl_file_name)
			latency_values_all = getLatencyList(jtl_file_name)
			latency_values = latency_values_all[:2000000]
			print ("OK Extracted")
			
			TPS = get_TPS(summary_file_name,user)
			avg_Latency = getAverageLatency(latency_values)
			percentile_10 = get_percentile(latency_values, 10)
			percentile_50 = get_percentile(latency_values, 50)
			percentile_90 = get_percentile(latency_values, 90)
			percentile_99 = get_percentile(latency_values, 99)
			percentile_99_9 = get_percentile(latency_values, 99.9)
			percentile_99_99 = get_percentile(latency_values, 99.99)
			std = get_std(latency_values, avg_Latency)
			tail_index = 0
			
			print ("OK got main things")
			x_c, cdf = get_cdf(latency_values)
			x_s, y_s = get_log_log_complementary_graph(x_c, cdf)
			tail_index = get_tail_index(x_s,y_s,latency_values)
			print ("OK got tail index")
			
			print (TPS)
			print (avg_Latency)
			print (percentile_10)
			print (percentile_50)
			print (percentile_90)
			print (percentile_99)
			print (percentile_99_9)
			print (percentile_99_99)
			print (std)
			
			row = [size,num,user,TPS,avg_Latency,percentile_10,percentile_50,percentile_90,percentile_99,percentile_99_9,percentile_99_99,std,tail_index]
			csv_file_records.append(row)
			
		print ("Completed Generating CSV files for "+ str(user) + " users and " + str(size) + " Prime")
	
	print ("Completed for " + str(size) + " Prime number")

print ("Completed Generating CSV files for analyis")

with open(output_csv_location, "w") as csv_file:
	writer = csv.writer(csv_file, delimiter=',')
	for line in csv_file_records:
		writer.writerow(line)
