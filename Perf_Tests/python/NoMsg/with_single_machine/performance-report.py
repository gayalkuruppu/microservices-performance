import sys
from random import randint
import csv

from uptimeParameters import *

def readDashboard(dashboard_js_file):
	dashboard = open(dashboard_js_file)
	stat_table = ""
	content = dashboard.readlines()
	for line in content:
		if '#statisticsTable' in line:
			stat_table = line
			break
	stat_table = stat_table.strip().split(",")
	jtl_stat = {}
	jtl_stat["error"] = stat_table[5].strip()
	jtl_stat["average"] = stat_table[6].strip()
	jtl_stat["min"] = stat_table[7].strip()
	jtl_stat["max"] = stat_table[8].strip()
	jtl_stat["percentile_90"] = stat_table[9].strip()
	jtl_stat["percentile_95"] = stat_table[10].strip()
	jtl_stat["percentile_99"] = stat_table[11].strip()
	jtl_stat["throughput"] = stat_table[12].strip()
	return jtl_stat

concurrent_users = [1000]#1, 2, 50, 100, 300, 500, 700, 1000
message_sizes= [1024]#400, 10240

dashboard_files_root = sys.argv[1]
uptime_reports_root = sys.argv[2]
output_csv_file = sys.argv[3]

csv_file_records = []
#headers = ['user', 'average_latency', 'min_latency', 'max_latency', 'percentile_90', 'percentile_95', 'percentile_99', 'throughput', 'error_rate',  'A_last_one_minutes_la', 'A_last_five_minutes_la', 'A_last_fifteen_minutes_la', 'B_last_one_minutes_la', 'B_last_five_minutes_la', 'B_last_fifteen_minutes_la']
headers = ['user', 'average_latency', 'min_latency', 'max_latency', 'percentile_90', 'percentile_95', 'percentile_99', 'throughput', 'error_rate',  'last_one_minutes_la', 'last_five_minutes_la', 'last_fifteen_minutes_la']
csv_file_records.append(headers)

for size in message_sizes:
	for user in concurrent_users:
		dashboard_file_name = dashboard_files_root+"/"+str(user)+"_users/content/js/dashboard.js"
		uptime_file_name = uptime_reports_root+"/uptime_dir/"+str(user)+"_Users_uptime.txt"
		#uptime_file_name1 = uptime_reports_root+"/uptime_dir/"+"machine1_"+str(user)+"_Users_"+str(size)+"_size_uptime.txt"
		#uptime_file_name2 = uptime_reports_root+"/uptime_dir/"+"machine2_"+str(user)+"_Users_"+str(size)+"_size_uptime.txt"
		
		jtl_stat = readDashboard(dashboard_file_name)

		average_latency = jtl_stat["average"]
		min_latency = jtl_stat["min"]
		max_latency = jtl_stat["max"]
		percentile_90= jtl_stat["percentile_90"]
		percentile_95 = jtl_stat["percentile_95"]
		percentile_99 = jtl_stat["percentile_99"]
		throughput = jtl_stat["throughput"]
		error_rate = jtl_stat["error"]

		load_averages = getLoadAverages(uptime_file_name)
		last_one_minutes_la = load_averages[1]
		last_five_minutes_la = load_averages[5]
		last_fifteen_minutes_la = load_averages[15]
		
		#A_load_averages = getLoadAverages(uptime_file_name1)
		#A_last_one_minutes_la = A_load_averages[1]
		#A_last_five_minutes_la = A_load_averages[5]
		#A_last_fifteen_minutes_la = A_load_averages[15]
		
		#B_load_averages = getLoadAverages(uptime_file_name2)
		#B_last_one_minutes_la = B_load_averages[1]
		#B_last_five_minutes_la = B_load_averages[5]
		#B_last_fifteen_minutes_la = B_load_averages[15]

		row = [user, average_latency, min_latency, max_latency, percentile_90, percentile_95, percentile_99, throughput, error_rate, last_one_minutes_la, last_five_minutes_la, last_fifteen_minutes_la]
		#row = [user, average_latency, min_latency, max_latency, percentile_90, percentile_95, percentile_99, throughput, error_rate, A_last_one_minutes_la, A_last_five_minutes_la, A_last_fifteen_minutes_la, C_last_one_minutes_la, B_last_five_minutes_la, B_last_fifteen_minutes_la]
		csv_file_records.append(row)		

with open(output_csv_file, "w") as csv_file:
    writer = csv.writer(csv_file, delimiter=',')
    for line in csv_file_records:
        writer.writerow(line)