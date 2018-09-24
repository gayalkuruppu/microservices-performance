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
# Run Performance Tests for Ballerina - Aggregator with two services with DB and Cache
# ----------------------------------------------------------------------------

########################################
#------------Test-Variables--------------#
########################################

concurrent_users=(1 2 50 100 300 500 700 1000) #to be changed 1 2 50 100 300 500 700 1000 
test_duration=900#to be changed to 900
split_time=5 #to be changed to 5

########################################
#------------Host Machine--------------#
########################################

target_script=/home/fct/Project/Builds/Ballerina/aggregator-with-db-caching-two/start.sh
target_uptime_script=/home/fct/Project/Builds/Ballerina/aggregator-with-db-caching-two/uptime.sh
target_uptime_path=/home/fct/Project/Builds/Ballerina/aggregator-with-db-caching-two/uptime_dir

###Machine A
host1_ip=172.16.53.77
host1_port=8080
host1_username_ip=fct@172.16.53.77
host1_pwd=123
host1_machine_num=1

###Machine B
host2_ip=172.16.53.76
host2_port=8081
host2_username_ip=fct@172.16.53.76
host2_pwd=123
host2_machine_num=2

###Machine C
host3_ip=172.16.53.70
host3_port=8082
host3_username_ip=fct@172.16.53.70
host3_pwd=123
host3_machine_num=3

########################################
#------------Client Machine------------#
########################################

jmeter_path=/home/fct/Downloads/Software/JMeter/apache-jmeter-4.0/bin
jtl_splitter_path=/home/fct/Projects/ballerina-0-981-1/common

jtl_location=/home/fct/Projects/ballerina-0-981-1/Results/aggregator-with-db-caching-two/jtls
jmx_file=/home/fct/Projects/ballerina-0-981-1/Tests/aggregator-with-db-caching-two/Aggregator_Two_DB_Cache_Test.jmx
dashboards_path=/home/fct/Projects/ballerina-0-981-1/Results/aggregator-with-db-caching-two/dashboards
uptime_path=/home/fct/Projects/ballerina-0-981-1/Results/aggregator-with-db-caching-two

performance_report_python_file=/home/fct/Projects/ballerina-0-981-1/common/python/NoMsg/with_three_machines/performance-report.py
performance_report_output_file=/home/fct/Projects/ballerina-0-981-1/Results/aggregator-with-db-caching-two/summary_aggregator_db_cache_two

########################################
#------------Test Begins---------------#
########################################

# Split JTLs

echo "Splitting JTL files started"


	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		jtl_file=${jtl_location}/${total_users}_users/results.jtl
		
		java -jar ${jtl_splitter_path}/jtl-splitter-0.1.1-SNAPSHOT.jar -f $jtl_file -t ${split_time} -d	
		
		echo "Splitting jtl file for ${u} users test completed"
	done


echo "Splitting JTL files Completed"
	
# Generating dashboards

echo "Generating Dashboards"

	for u in ${concurrent_users[@]}
	do	
		total_users=$(($u))
		report_location=${dashboards_path}/${total_users}_users
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		${jmeter_path}/jmeter -g  ${jtl_location}/${total_users}_users/results-measurement.jtl -o $report_location	

		echo "Generating dashboard for ${u} users test completed"
	done


echo "Generating Dashboards Completed"

#Generate CSV

echo "Generating the CSV file"

python3 $performance_report_python_file $dashboards_path $uptime_path $performance_report_output_file

echo "Finished generating CSV file"

