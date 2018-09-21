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
# Run Performance Tests for Ballerina - Chaining with three services with DB
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

target_script=/home/fct/Project/Builds/Ballerina/chaining-with-db-three/start.sh
target_uptime_script=/home/fct/Project/Builds/Ballerina/chaining-with-db-three/uptime.sh
target_uptime_path=/home/fct/Project/Builds/Ballerina/chaining-with-db-three/uptime_dir

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

jtl_location=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-three/jtls
jmx_file=/home/fct/Projects/ballerina-0-981-1/Tests/chaining-with-db-three/Chaining_Three_DB_Test.jmx
dashboards_path=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-three/dashboards
uptime_path=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-three

performance_report_python_file=/home/fct/Projects/ballerina-0-981-1/common/python/NoMsg/with_three_machines/performance-report.py
performance_report_output_file=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-three/summary_chainingdb_three

payload_generator_file=/home/fct/Projects/ballerina-0-981-1/common/payload-generator-0.1.1-SNAPSHOT.jar
payloads_output_file_root=/home/fct/Projects/ballerina-0-981-1/Tests/chaining-with-db-three/client_scripts
payload_files_postfix=B
payload_files_extension=json

########################################
#------------Test Begins-------------#
########################################


# Generating JTL files

		echo "Tests for ${size} size message"

		for u in ${concurrent_users[@]}
		do

			total_users=$(($u))

			report_location=$jtl_location/${total_users}_users
			echo "Report location is ${report_location}"
			mkdir -p $report_location
			
			#MachineA
			#SSH
			echo "begin SSH"
			nohup sshpass -p ${host1_pwd} ssh -n ${host1_username_ip} -f "/bin/bash $target_script" &

			#Check Service
			while true 
			do
				echo "Checking service"
				response_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET http://${host1_ip}:${host1_port}/serviceFamous/test)
				if [ $response_code -eq 200 ]; then
					echo "First Ballerina service has started"
					break
				else
					sleep 10
					echo "Retrying..."
					nohup sshpass -p ${host1_pwd} ssh -n ${host1_username_ip} -f "/bin/bash $target_script" &
				fi
			done
			
			#MachineB
			#SSH
			echo "begin SSH"
			nohup sshpass -p ${host2_pwd} ssh -n ${host2_username_ip} -f "/bin/bash $target_script" &

			#Check Service
			while true 
			do
				echo "Checking service"
				response_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET http://${host2_ip}:${host2_port}/servicePolitical/test)
				if [ $response_code -eq 200 ]; then
					echo "Second Ballerina service has started"
					break
				else
					sleep 10
					echo "Retrying..."
					nohup sshpass -p ${host2_pwd} ssh -n ${host2_username_ip} -f "/bin/bash $target_script" &
				fi
			done
			
			#MachineC
			#SSH
			echo "begin SSH"
			nohup sshpass -p ${host3_pwd} ssh -n ${host3_username_ip} -f "/bin/bash $target_script" &

			#Check Service
			while true 
			do
				echo "Checking service"
				response_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET http://${host3_ip}:${host3_port}/serviceSports/test)
				if [ $response_code -eq 200 ]; then
					echo "Third Ballerina service has started"
					break
				else
					sleep 10
					echo "Retrying..."
					nohup sshpass -p ${host3_pwd} ssh -n ${host3_username_ip} -f "/bin/bash $target_script" &
				fi
			done
			
			echo "Begin test for ${u} users and ${size} size message"

			# Start JMeter server
			
			${jmeter_path}/jmeter -Jgroup1.host=${host1_ip} -Jgroup1.port=${host1_port} -Jgroup1.threads=$u -Jgroup1.seconds=${test_duration} -n -t ${jmx_file} -l ${report_location}/results.jtl

			# uptime
			
			echo "Running Uptime command in first"	
			nohup sshpass -p ${host1_pwd} ssh -n -f ${host1_username_ip} "/bin/bash $target_uptime_script ${total_users} ${target_uptime_path} ${host1_machine_num}" &
			
			echo "Running Uptime command in second"	
			nohup sshpass -p ${host2_pwd} ssh -n -f ${host2_username_ip} "/bin/bash $target_uptime_script ${total_users} ${target_uptime_path} ${host2_machine_num}" &
			
			echo "Running Uptime command in Third"	
			nohup sshpass -p ${host3_pwd} ssh -n -f ${host3_username_ip} "/bin/bash $target_uptime_script ${total_users} ${target_uptime_path} ${host3_machine_num}" &

			echo "Completed Generating JTL files for ${u} users and ${size} size message"
		

		

	done

	echo "Completed Generating JTL files for ${u} users"

# Copying uptime logs

	echo "Copying uptime logs of first machine to Jmeter client machine"

	mkdir -p ${uptime_path}
	sshpass -p ${host1_pwd} scp -r ${host1_username_ip}:${target_uptime_path} ${uptime_path}
	
	echo "Copying uptime logs of second machine to Jmeter client machine"

	mkdir -p ${uptime_path}
	sshpass -p ${host2_pwd} scp -r ${host2_username_ip}:${target_uptime_path} ${uptime_path}
	
	echo "Copying uptime logs of third machine to Jmeter client machine"

	mkdir -p ${uptime_path}
	sshpass -p ${host3_pwd} scp -r ${host3_username_ip}:${target_uptime_path} ${uptime_path}
	
	echo "Finished Copying uptime logs to client machine"


echo "Splitting JTL files started"


	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		jtl_file=${jtl_location}/${total_users}_users/results.jtl
		
		java -jar ${jtl_splitter_path}/jtl-splitter-0.1.1-SNAPSHOT.jar -f $jtl_file -t ${split_time} -d	
		
		echo "Splitting jtl file for ${size}B message size and ${u} users test completed"
	done


echo "Splitting JTL files Completed"

echo "Generating Dashboards"

	for u in ${concurrent_users[@]}
	do	
		total_users=$(($u))
		report_location=${dashboards_path}/${total_users}_users
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		${jmeter_path}/jmeter -g  ${jtl_location}/${total_users}_users/results-measurement.jtl -o $report_location	

		echo "Generating dashboard for ${size}B message size and ${u} users test completed"
	done


echo "Generating Dashboards Completed"

echo "Generating the CSV file"

python3 $performance_report_python_file $dashboards_path $uptime_path $performance_report_output_file

echo "Finished generating CSV file"
