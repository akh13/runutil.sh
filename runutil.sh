#!/bin/bash

### This is a simple script used to failover a rundeck server from a primary to a secondar
### node. In the event that you wish for the secondary server to take over the schedule
### Responsibilities for the primary node, you can use this to submit an API call that will
### Take ALL jobs and switch their schedules to the secondary node.
### Required information:

### Rundeck token. Make this with your admin-enabled user in the user panel.

TOKEN=""

### domain for your rundeck server.

DOMAIN="example.com"

### UUIDs assigned to the rundeck servers.

### Server 1
ID1="ID HERE"

### Server 2
ID2="ID HERE"

### hostnames of the rundeck servers

SERVER1="YOUR SERVER NAME HERE"
SERVER2="YOUR SERVER2 NAME HERE"

###
###
###
###
### Check if we are failing from one to two, or two to one.

if [[ $2 == 1 ]]
then
  SERVER=$SERVER1
  ID=$ID2
elif [[ $2 == 2 ]]
then
  SERVER=$SERVER2
  ID=$ID1
fi
if [[ ! -z $3 ]]
then
  PROJ=$3
fi

case $1 in
  #Statistics
  stats)
    
    curl --insecure \
    -H "X-RunDeck-Auth-Token:$TOKEN" \
    -H "Content-Type: application/xml" \
    -X GET "https://$SERVER.$DOMAIN/api/2/system/info"
    
    echo $SERVER
    echo $ID
  exit 0;;
  
  failover) while true
    do
      # (1) prompt user, and read command line argument
      
      if [[ -z "$PROJ" ]]
      then
        
        read -p "Failover all jobs to $SERVER? (y/n)" answer
        
      else
        
        read -p "Failover all jobs in the project named \"$PROJ\" to $SERVER? (y/n)" answer
        
      fi
      
      # (2) handle the input we were given
      case $answer in
        [yY]* )
          
          if [[ -z "$PROJ" ]]
          then
            
            echo "Okay, failing to $SERVER"
            
            curl --insecure \
            -H "X-RunDeck-Auth-Token:$TOKEN" \
            -H "Content-Type: application/xml" \
            --data "<server uuid=\"$ID\"/>" \
            -X PUT "https://$SERVER.$DOMAIN/api/20/scheduler/takeover"
            
          else
            
            echo "Okay, failing all jobs in $PROJ to $SERVER"
            
            curl --insecure \
            -H "X-RunDeck-Auth-Token:$TOKEN" \
            -H "Content-Type: application/xml" \
            --data "<takeoverSchedule><server uuid=\"$ID\"/><project name=\"$PROJ\"/></takeoverSchedule>" \
            -X PUT "https://$SERVER.$DOMAIN/api/20/scheduler/takeover"
            
          fi
          
        break;;
        
        [nN]* ) exit;;
        
        * )     echo "Please enter Y or N.";;
      esac
    done
  ;;
  
  *)
    
    ###
    ### Instructions block.
    ###
    
    echo "runutil.sh ARG NUM PROJ"
    echo "----------------------------"
    echo "NUM is the number of the rundeck server to fail to or to run stats on."
    echo ""
    echo "1 = $SERVER1"
    echo "2 = $SERVER2"
    echo ""
    echo "----------------------------"
    echo "----------------------------"
    echo "ARG is the call for a server"
    echo ""
    echo "stats = statistics"
    echo "failover = fail over, followed by node number"
    echo ""
    echo "ex: for stats of $SERVER1, do as follows:"
    echo "./runutil.sh stats 1"
    echo ""
    echo "It is now possible to specify a project after choosing the failover target."
    echo "To only migrate a specific project to a node, specify the name of the project"
    echo "as PROJ. Without this argument, it is assumed that you wish to migrate every"
    echo "job on the cluster, as opposed to just a select subset."
    echo "----------------------------"
    
  ;;
  
esac
exit 0
