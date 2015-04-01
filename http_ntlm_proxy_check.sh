#!/bin/bash

#
#Script to check ntlm authentication is still running via a web proxy by logging in with ntlm and attempting 
#to grab a page via the proxy.  
#
#


#user defined variables 
WEB_PAGE_TO_CHECK[0]="www.cheese.com"
WEB_PAGE_TO_CHECK[1]="www.loadbalancer.org"
DOMAIN="ROBS"
USERNAME="tom"
PASSWORD="Loadbalancer100"
#the next variable is where it gets complicated some proxies return an authentication failed page when the ntlm service is not responding so curl exits with a code
#of zero as a page was returned  theoretically passing the check. So you can set this value for something that is returned on the page that would indicate to you that the check has failed, this can be disabled by setting the variable $PAGE_CHECK to 0
PAGE_CHECK="1"
STRING_TO_CHECK_FOR="Authentication failed"

#specify the proxy server as virtual_ip and virtual_port so when this is sent from ldirectord it will query your vip. 
#on calling the script you can ignore the real server bit its not important
#but ldirectord will still pass it so its best to accept it

#Command Line Parameters
VIRTUAL_IP=$1
VIRTUAL_PORT=$2
REAL_IP=$3
REAL_PORT=$4

#program starts

for WEB_PAGE in "${WEB_PAGE_TO_CHECK[@]}"
do 
	WEB_PAGE_TO_CHECK_RESULT=$WEB_PAGE_TO_CHECK $WEB_PAGE_CHECK_NUMBER
	CURL_OUTPUT=$(curl -s 0 --proxy-ntlm --proxy-user $DOMAIN\\$USERNAME:$PASSWORD --url $WEB_PAGE --proxy $REAL_IP:$REAL_PORT)
	if [ "$?" -eq "0" ]; then
		EXIT_CODE="0"
		if [ $PAGE_CHECK -eq "1" ]; then
			echo "$CURL_OUTPUT" | grep "$STRING_TO_CHECK_FOR" >> /dev/null
			if [ "$?" -eq "0" ]; then
				EXIT_CODE="1"	
			fi
		fi
	else
		EXIT_CODE="1"	
	fi
done

# set the exiting return code 
exit $EXIT_CODE
