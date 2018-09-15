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
# Run Performance Tests for Ballerina - Chaining with three services without DB
# ----------------------------------------------------------------------------

########################################
#------------Test-Variables--------------#
########################################

concurrent_users=(1) #to be changed 1 2 50 100 300 500 700 1000 
message_sizes=(50) # 50 1024 400 1600
test_duration=120 #to be changed to 900
split_time=1 #to be changed to 5

########################################
#------------Host Machine--------------#
########################################

target_script=/home/uok/Project/Builds/Ballerina/chaining-without-db-two/start.sh
target_uptime_script=/home/uok/Project/Builds/Ballerina/chaining-without-db-two/uptime.sh
target_uptime_path=/home/uok/Project/Builds/Ballerina/chaining-without-db-two/uptime_dir

###Machine A
host1_ip=172.16.20.60
host1_port=8080
host1_username_ip=uok@172.16.20.60
host1_pwd=123
host1_machine_num=1

###Machine B
host2_ip=172.16.20.176
host2_port=8081
host2_username_ip=uok@172.16.20.176
host2_pwd=123
host2_machine_num=2

###Machine C
host3_ip=172.16.20.74
host3_port=8083
host3_username_ip=uok@172.16.20.74
host3_pwd=123
host3_machine_num=3

########################################
#------------Client Machine------------#
########################################

jmeter_path=/home/uok/Downloads/Software/JMeter/apache-jmeter-4.0/bin

jtl_splitter_path=/home/uok/Projects/ballerina-0-981-1/common

payload_generator_file=/home/uok/Projects/ballerina-0-981-1/common/payload-generator-0.1.1-SNAPSHOT.jar
payloads_output_file_root=/home/uok/Projects/ballerina-0-981-1/Tests/chaining-without-db-three/client_scripts
payload_files_postfix=B
payload_files_extension=json

jmx_file=/home/uok/Projects/ballerina-0-981-1/Tests/chaining-without-db-three/Chaining_Three_Payload_Test.jmx
jtl_location=/home/uok/Projects/ballerina-0-981-1/Results/chaining-without-db-three/jtls
uptime_path=/home/uok/Projects/ballerina-0-981-1/Results/chaining-without-db-three
dashboards_path=/home/uok/Projects/ballerina-0-981-1/Results/chaining-without-db-three/dashboards

#performance_report_python_file=/home/uok/Projects/ballerina-0-981-1/common/python/performance-report.py
#performance_report_output_file=/home/uok/Projects/ballerina-0-981-1/Results/chaining-without-db-three/summary_Chaining_two_noDB

########################################
#------------Test Begins-------------#
########################################

#Generate payloads

echo "Generating Payloads"

for size in ${message_sizes[@]}
do
	echo "Generating ${size}B file"
	java -jar ${payload_generator_file} --size $size
done

echo "Finished generating payloads"

# Generating JTL files

	for size in ${message_sizes[@]}
	do
		echo "Tests for ${size} size message"

		for u in ${concurrent_users[@]}
		do

			total_users=$(($u))

			report_location=$jtl_location/${size}_message/${total_users}_users
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
				response_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET -d "hello" http://${host1_ip}:${host1_port}/hello/serviceA)
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
				response_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET -d "hello" http://${host2_ip}:${host2_port}/hello/serviceB)
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
				response_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET -d "hello" http://${host3_ip}:${host3_port}/hello/serviceC)
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
			message=$(<${payloads_output_file_root}/${size}${payload_files_postfix}.${payload_files_extension})
			
			${jmeter_path}/jmeter -Jgroup1.host=${host1_ip} -Jgroup1.port=${host1_port} -Jgroup1.threads=$u -Jgroup1.seconds=${test_duration} -Jgroup1.data=${message} -n -t ${jmx_file} -l ${report_location}/results.jtl

			# uptime
			
			echo "Running Uptime command in first"	
			nohup sshpass -p ${host1_pwd} ssh -n -f ${host1_username_ip} "/bin/bash $target_uptime_script ${total_users} ${size} ${target_uptime_path} ${host1_machine_num}" &
			
			echo "Running Uptime command in second"	
			nohup sshpass -p ${host2_pwd} ssh -n -f ${host2_username_ip} "/bin/bash $target_uptime_script ${total_users} ${size} ${target_uptime_path} ${host2_machine_num}" &
			
			echo "Running Uptime command in Third"	
			nohup sshpass -p ${host3_pwd} ssh -n -f ${host3_username_ip} "/bin/bash $target_uptime_script ${total_users} ${size} ${target_uptime_path} ${host3_machine_num}" &

			echo "Completed Generating JTL files for ${u} users and ${size} size message"
		done

		echo "Completed tests for ${size} size message"

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

for size in ${message_sizes[@]}
do
	for u in ${concurrent_users[@]}
	do
		total_users=$(($u))
		jtl_file=${jtl_location}/${size}_message/${total_users}_users/results.jtl
		
		java -jar ${jtl_splitter_path} -f $jtl_file -t ${split_time_min} -d	
		
		echo "Splitting jtl file for ${size}B message size and ${u} users test completed"
	done
done

echo "Splitting JTL files Completed"

echo "Generating Dashboards"

for size in ${message_sizes[@]}
do
	for u in ${concurrent_users[@]}
	do	
		total_users=$(($u))
		report_location=${jtl_location}/${size}_message/${total_users}_users/Dashboard
		echo "Report location is ${report_location}"
		mkdir -p $report_location
		
		${path_jmeter}/jmeter -g  ${jtl_location}/${size}_message/${total_users}_users/results-measurement.jtl -o $report_location	

		echo "Generating dashboard for ${size}B message size and ${u} users test completed"
	done
done

echo "Generating Dashboards Completed"

echo "Generating the CSV file"

python3 $performance_report_python_file $dashboards_path $uptime_path $performance_report_output_file

echo "Finished generating CSV file"
