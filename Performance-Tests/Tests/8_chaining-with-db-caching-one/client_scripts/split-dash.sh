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
# Run Performance Tests for Ballerina - Chaining with one services with DB and Cache(Singleton)
# ----------------------------------------------------------------------------

########################################
#------------Test-Variables--------------#
########################################

concurrent_users=(1 2 50 100 300 500 700 1000) #to be changed 1 2 50 100 300 500 700 1000 
test_duration=900 #to be changed to 900
split_time=5 #to be changed to 5

########################################
#------------Host Machine--------------#
########################################

target_script=/home/fct/Project/Builds/Ballerina/chaining-with-db-caching-one/start.sh
target_uptime_script=/home/fct/Project/Builds/Ballerina/chaining-with-db-caching-one/uptime.sh
target_uptime_path=/home/fct/Project/Builds/Ballerina/chaining-with-db-caching-one/uptime_dir

###Machine A
host1_ip=172.16.53.70
host1_port=8080
host1_username_ip=fct@172.16.53.70
host1_pwd=123

########################################
#------------Client Machine------------#
########################################

jmeter_path=/home/fct/Downloads/Software/JMeter/apache-jmeter-4.0/bin
jtl_splitter_path=/home/fct/Projects/ballerina-0-981-1/common

jtl_location=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-caching-one/jtls
jmx_file=/home/fct/Projects/ballerina-0-981-1/Tests/chaining-with-db-caching-one/Chaining_One_DB_Test.jmx
dashboards_path=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-caching-one/dashboards
uptime_path=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-caching-one

performance_report_python_file=/home/fct/Projects/ballerina-0-981-1/common/python/NoMsg/with_single_machine/performance-report.py
performance_report_output_file=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-caching-one/summary_chaining_one_db_caching

########################################
#------------Test Begins-------------#
########################################
	
# Split JTLs
	
echo "Splitting JTL files started"

	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		jtl_file=${jtl_location}/${total_users}_users/results.jtl
		
		java -jar ${jtl_splitter_path}/jtl-splitter-0.1.1-SNAPSHOT.jar -f $jtl_file -t $split_time -d	
		
		echo "Splitting jtl file for ${u} users test completed"
	done

	
echo "Splitting JTL files Completed"

# Generate dashboards

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
