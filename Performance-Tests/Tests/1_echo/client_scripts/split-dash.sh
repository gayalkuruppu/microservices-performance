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
# Run Full Performance Tests for Ballerina - Echo
# ----------------------------------------------------------------------------

########################################
#------------Test-Variables--------------#
########################################

concurrent_users=(1) #to be changed 1 2 50 100 300 500 700 1000 
test_duration=120 #to be changed to 900
split_time=1 #to be changed to 5

########################################
#------------Client Machine------------#
########################################

jmeter_path=/home/uok/Downloads/Software/JMeter/apache-jmeter-4.0/bin
jtl_splitter_path=/home/uok/Projects/ballerina-0-981-1/common

jmx_file=/home/uok/Projects/ballerina-0-981-1/Tests/echo/Echo_Test.jmx
jtl_location=/home/uok/Projects/ballerina-0-981-1/Results/echo/jtls
dashboards_path=/home/uok/Projects/ballerina-0-981-1/Results/echo/dashboards
uptime_path=/home/uok/Projects/ballerina-0-981-1/Results/echo

performance_report_python_file=/home/uok/Projects/ballerina-0-981-1/common/python/NoMsg/with_single_machine/performance-report.py

performance_report_output_file=/home/uok/Projects/ballerina-0-981-1/Results/echo/summary_echo

########################################
#------------Test Begins-------------#
########################################

# Split jtls

echo "Splitting JTL files started"

	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		jtl_file=${jtl_location}/${total_users}_users/results.jtl
		
		java -jar ${jtl_splitter_path}/jtl-splitter-0.1.1-SNAPSHOT.jar -f $jtl_file -t ${split_time_min} -d	
		
		echo "Splitting jtl file for ${u} users test completed"
	done

echo "Splitting JTL files Completed"

# Generate Dashboard

echo "Generating Dashboards"

	for u in ${concurrent_users[@]}
	do	
		total_users=$(($u))
		report_location=${jtl_location}/${total_users}_users
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		${path_jmeter}/jmeter -g  ${jtl_location}/${total_users}_users/results-measurement.jtl -o $report_location	

		echo "Generating dashboard for ${u} users test completed"
	done

echo "Generating Dashboards Completed"

# Generate CSV

echo "Generating the CSV file"

python3 $performance_report_python_file $dashboards_path $uptime_path $performance_report_output_file

echo "Finished generating CSV file"
