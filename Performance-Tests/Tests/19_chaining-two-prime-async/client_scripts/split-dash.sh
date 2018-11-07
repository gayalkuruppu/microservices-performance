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
# Run Performance Tests for Ballerina - Chaining with two services with DB
# ----------------------------------------------------------------------------

########################################
#------------Test-Variables--------------#
########################################

concurrent_users=(1 2 50 100 300 500 700 1000) #to be changed 1 2 50 100 300 500 700 1000
message_sizes=(521 7919 10007)
test_duration=900 #to be changed to 900
split_time=5 #to be changed to 5

########################################
#------------Host Machine--------------#
########################################

target_script=/home/fct/Project/Builds/Ballerina/async-factorial-chaining-two/start.sh
target_uptime_script=/home/fct/Project/Builds/Ballerina/async-factorial-chaining-two/uptime.sh
target_uptime_path=/home/fct/Project/Builds/Ballerina/async-factorial-chaining-two/uptime_dir


########################################
#------------Client Machine------------#
########################################

jmeter_path=/home/fct/Downloads/Software/JMeter/apache-jmeter-4.0/bin
jtl_splitter_path=/home/fct/Projects/ballerina-0-981-1/common

jtl_location=/home/fct/Projects/ballerina-0-981-1/Results/async-factorial-chaining-two/jtls
jmx_file=/home/fct/Projects/ballerina-0-981-1/Tests/async-factorial-chaining-two/Chaining_Two_DB_Test.jmx
dashboards_path=/home/fct/Projects/ballerina-0-981-1/Results/async-factorial-chaining-two/dashboards
uptime_path=/home/fct/Projects/ballerina-0-981-1/Results/async-factorial-chaining-two

performance_report_python_file=/home/fct/Projects/ballerina-0-981-1/common/python/with_two_machines/performance-report-fact.py
performance_report_output_file=/home/fct/Projects/ballerina-0-981-1/Results/async-factorial-chaining-two/summary_chaining_two_factorial_async.csv

########################################
#------------Test Begins-------------#
########################################
	
# Split JTLs

echo "Splitting JTL files started"

for size in ${message_sizes[@]}
do
	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		jtl_file=${jtl_location}/${size}_message/${total_users}_users/results.jtl
		
		java -jar ${jtl_splitter_path}/jtl-splitter-0.1.1-SNAPSHOT.jar -f $jtl_file -t $split_time -d	
		
		echo "Splitting jtl file for ${size} and ${u} users test completed"
	done
done
	
echo "Splitting JTL files Completed"

# Generate dashboards

echo "Generating Dashboards"

for size in ${message_sizes[@]}
do
	for u in ${concurrent_users[@]}
	do	
		total_users=$(($u))
		report_location=${dashboards_path}/${size}_message/${total_users}_users
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		${jmeter_path}/jmeter -g  ${jtl_location}/${size}_message/${total_users}_users/results-measurement.jtl -o $report_location	

		echo "Generating dashboard for ${size}and ${u} users test completed"
	done
done

echo "Generating Dashboards Completed"

# Generate summary CSV file

echo "Generating the CSV file"

python3 $performance_report_python_file $dashboards_path $uptime_path $performance_report_output_file

echo "Finished generating CSV file"