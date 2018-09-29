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
# Run Performance Tests for Ballerina - Chaining with one services with DB (Singleton)
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

target_script=/home/fct/Project/Builds/Ballerina/chaining-with-db-one/start.sh
target_uptime_script=/home/fct/Project/Builds/Ballerina/chaining-with-db-one/uptime.sh
target_uptime_path=/home/fct/Project/Builds/Ballerina/chaining-with-db-one/uptime_dir

###Machine A
host1_ip=################
host1_port=8080
host1_username_ip=################
host1_pwd=################
host1_machine_num=1

########################################
#------------Client Machine------------#
########################################

jmeter_path=/home/fct/Downloads/Software/JMeter/apache-jmeter-4.0/bin

jtl_location=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-one/jtls
jmx_file=/home/fct/Projects/ballerina-0-981-1/Tests/chaining-with-db-one/Chaining_One_DB_Test.jmx
uptime_path=/home/fct/Projects/ballerina-0-981-1/Results/chaining-with-db-one

########################################
#------------Test Begins-------------#
########################################

# Generating JTL files

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
				response_code=$(curl -s -o /dev/null -w "%{http_code}" -X GET http://${host1_ip}:${host1_port}/serviceNews/test)
				if [ $response_code -eq 200 ]; then
					echo "First Ballerina service has started"
					break
				else
					sleep 10
					echo "Retrying..."
					nohup sshpass -p ${host1_pwd} ssh -n ${host1_username_ip} -f "/bin/bash $target_script" &
				fi
			done

			echo "Begin test for ${u} users"
			
			${jmeter_path}/jmeter -Jgroup1.host=${host1_ip} -Jgroup1.port=${host1_port} -Jgroup1.threads=$u -Jgroup1.seconds=${test_duration} -n -t ${jmx_file} -l ${report_location}/results.jtl

			# uptime
			
			echo "Running Uptime command in first"	
			nohup sshpass -p ${host1_pwd} ssh -n -f ${host1_username_ip} "/bin/bash $target_uptime_script ${total_users} ${target_uptime_path}" &

			echo "Completed Generating JTL files for ${u} users"
		done

	echo "Completed Generating JTL files"
	

# Copying uptime logs

	echo "Copying uptime logs of server machine to Jmeter client machine"

	mkdir -p ${uptime_path}
	sshpass -p ${host1_pwd} scp -r ${host1_username_ip}:${target_uptime_path} ${uptime_path}

	echo "Finished Copying uptime logs to client machine"