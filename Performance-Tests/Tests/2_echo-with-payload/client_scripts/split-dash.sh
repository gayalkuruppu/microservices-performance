#!/bin/bash
# Copyright 2018 WSO2 Inc. (http://wso2.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ----------------------------------------------------------------------------
# Run Full Performance Tests for Ballerina - Echo with Payload
# ----------------------------------------------------------------------------

########################################
#------------Test-Variables--------------#
########################################

concurrent_users=(1) #to be changed 1 2 50 100 300 500 700 1000 
message_sizes=(50 1024) # 400 1600
test_duration=120 #to be changed to 900
split_time=1 #to be changed to 5

########################################
#------------Host Machine--------------#
########################################

host1_ip=172.16.53.70
host1_port=8080
host1_username_ip=fct@172.16.53.70
host1_pwd=123

target_script=/home/uok/Project/Builds/Ballerina/echo-with-payload/start.sh
target_uptime_script=/home/uok/Project/Builds/Ballerina/echo-with-payload/uptime.sh
target_uptime_path=/home/uok/Project/Builds/Ballerina/echo-with-payload/uptime_dir

########################################
#------------Client Machine------------#
########################################

jmeter_path=/home/uok/Downloads/Software/JMeter/apache-jmeter-4.0/bin
jtl_splitter_path=/home/uok/Projects/ballerina-0-981-1/common

jmx_file=/home/uok/Projects/ballerina-0-981-1/Tests/echo-with-payload/Echo_Payload_Test.jmx
jtl_location=/home/uok/Projects/ballerina-0-981-1/Results/echo-with-payload/jtls
dashboards_path=/home/uok/Projects/ballerina-0-981-1/Results/echo-with-payload/dashboards
uptime_path=/home/uok/Projects/ballerina-0-981-1/Results/echo-with-payload

performance_report_python_file=/home/uok/Projects/ballerina-0-981-1/common/python/with_single_machine/performance-report.py

performance_report_output_file=/home/uok/Projects/ballerina-0-981-1/Results/echo-with-payload/summary_echo_with_payload

########################################
#------------Test Begins-------------#
########################################

# Split jtls

echo "Splitting JTL files started"

	for size in ${message_sizes[@]}
	do
		for u in ${concurrent_users[@]}
		do
			total_users=$(($u))
			jtl_file=${jtl_location}/${size}_message/${total_users}_users/results.jtl

			java -jar ${jtl_splitter_path}/jtl-splitter-0.1.1-SNAPSHOT.jar -f $jtl_file -t ${split_time_min} -d	

			echo "Splitting jtl file for ${size}B message size and ${u} users test completed"
		done
	done

echo "Splitting JTL files Completed"

# Gnerate Dashboard

echo "Generating Dashboards"

for size in ${message_sizes[@]}
do
	for u in ${concurrent_users[@]}
	do	
		total_users=$(($u))
		report_location=${jtl_location}/${size}_message/${total_users}_users
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		${path_jmeter}/jmeter -g  ${jtl_location}/${size}_message/${total_users}_users/results-measurement.jtl -o $report_location	

		echo "Generating dashboard for ${size}B message size and ${u} users test completed"
	done
done

echo "Generating Dashboards Completed"

# Generate CSV

echo "Generating the CSV file"

python3 $performance_report_python_file $dashboards_path $uptime_path $performance_report_output_file

echo "Finished generating CSV file"
