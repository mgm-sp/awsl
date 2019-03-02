#!/bin/bash

## Global variables
RED='\e[41m'
GREEN='\e[32m'
YELLOW='\e[33m'
BOLD='\e[1m'
NC='\e[0m' # No Color
PublicDnsName=""
PathOnAWS="/home/ec2-user/aswl"

## SET INSTACE OPTIONS HERE
INSTACE_ID=""
REGION=""
USERNAME="ec2-user"


function logo (){

local version="0.1.2"

echo -e "\e[21m                                                                   ${NC}
                                                          
        db       .M\"\"\"bgd \`7MMF'     A     \`7MF'\`7MMF'      
       ;MM:     ,MI    \"Y   \`MA     ,MA     ,V    MM        
      ,V^MM.    \`MMb.        VM:   ,VVM:   ,V     MM        
     ,M  \`MM      \`YMMNq.     MM.  M' MM.  M'     MM        
     AbmmmqMA   .     \`MM     \`MM A'  \`MM A'      MM      , 
    A'     VML  Mb     dM      :MM;    :MM;       MM     ,M 
  .AMA.   .AMMA.P\"Ybmmd\"        VF      VF      .JMMmmmmMMM  ${BOLD}v$version\e[21m
                                                                   
${NC}"
}

function help(){
	echo "ASWL can be used to automate the following steps:"
	echo "   - starting the AWS EC2 instance"
	echo "   - copying sync_me folder (hashcat commands, custom masks/rules/wordlists, hashes)"
	echo "   - starting the cracking process on the AWS EC2 instance"
	echo "   - transfering the results to your shared OwnCloud folder"
	echo "   - stopping the AWS EC2 instance"

	echo -e "\n\n${BOLD}Usage: awsl.sh [<PATH_ON_AWS>]\n${NC}"
	echo -e "Optional parameters:"
	echo -e "\t<PATH_ON_AWS>:\tThis is the path where the files will be stored."
	echo -e "\t\t\tdefault: /home/ec2-user/aswl"
	echo ""
	exit 1
}

function installer() {
	echo -e "${GREEN}Installing missing dependencies${NC}"
	apt-get update
	apt-get -y install jq python3-pip rsync
	bash -c "python3 -m pip install awscli"
	echo -e -n "\n${GREEN}Configuring AWS:${NC}\n"
	bash -c "aws configure"
	exit 1
}

function checks(){
	## checking dependecies
	if [[ $(aws --version 2>&1) == *"aws: command not found"* || $(jq -V 2>&1) == *"command not found"* ]]; then
		installer
	fi

	## check if SSH key is there
	if [ ! -f ./ssh_key.pem ]; then
	    echo "ssh_key.pem not found!"
	    exit -1
	else
		chmod 400 ./ssh_key.pem
	fi

	## set correct path if set
	if [[ ! -z $@ ]]; then
		PathOnAWS=$1
	fi
}

# check if instance has started
function check_running() {
	while true; do
		local state=$(aws ec2 describe-instances --instance-id $INSTACE_ID --region $REGION | jq -r '.Reservations[] | {"name": .Instances[].PublicDnsName, "State": .Instances[].State.Name,}' | jq -r .[])
		if [[ $state == *"running"* ]]; then
			PublicDnsName=$(echo $state | cut -d ' ' -f 1)
			echo -e "[+] Initializing ${GREEN}$PublicDnsName${NC}"
			break
		elif [[ $state = *"pending"* ]]; then
			sleep 10
		else
			echo -e "\e[41mError: Instance has unknown state \"$(echo $state | cut -d ' ' -f 2)\"!${NC}"
			exit -1
		fi
	done
}

# check instance status
function check_state() {
	while true; do
		local state=$(aws ec2 describe-instance-status --instance-id $INSTACE_ID --region $REGION | jq -r '.[] | {"State":.[].InstanceStatus.Status} .State')
		if [[ $state = "ok" ]]; then
			echo -e "${GREEN} | Done!${NC}"
			break
		elif [[ $state = "initializing" ]]; then
			echo -e "${YELLOW} | still $state...${NC}"
			sleep 25
		else
			echo -e "${RED}Error: Instance has unknown state \"$state\"!${NC}"
			exit -1
		fi
	done
}

# start ec2 instance
function start_instance() {
	echo "Waiting for instance to start (may need some minutes)"
	# Exit if awscli is not configured, otherwise start instance
	set -e
	bash -c "aws ec2 start-instances --instance-id $INSTACE_ID --region $REGION > /dev/null"
	sleep 15

	# check if instance is up an running
	check_running
	sleep 25
	check_state
}

# sending files to AWS instance
function send_files(){
	echo -e "\n[+] Sending files to instance."
	rsync -e 'ssh -i ./ssh_key.pem -oStrictHostKeyChecking=no' -a ./sync_me/ $USERNAME@$PublicDnsName:$PathOnAWS
}

# open ssh connection to instance
function hashcat(){
	echo -e "\n${GREEN}[+] \e[5mRunning hashcat commands.\e[25m${NC}"
	echo -e "\nResults will be uploaded to your OwnCloud share."
	ssh -oStrictHostKeyChecking=no -i ./ssh_key.pem $USERNAME@$PublicDnsName 'cd $PathOnAWS && screen -L -d -m ./commands.sh'
}



# Main
#--------------------
logo

## show help
if [[ "$1" = "-h" || "$1" = "--help" ]]; then
	help
fi

checks

## check if istance options are set
if [[ $INSTACE_ID = "" || $REGION = "" ]]; then
	echo -e "${RED}You must set the INSTACE_ID and REGION parameters in this file${NC}"
	exit -1
else
	start_instance
	send_files
	hashcat
fi