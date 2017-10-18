# runutil.sh
## Rundeck API cluster failover bash script.

This is a simple script used to failover a rundeck server from a primary to a secondar
node. In the event that you wish for the secondary server to take over the schedule
Responsibilities for the primary node, you can use this to submit an API call that will
Take ALL jobs and switch their schedules to the secondary node.

Required information should be entered into the script as follows:

* Rundeck token. Make this with your admin-enabled user in the user panel.
* Domain for your rundeck server.
* UUIDs assigned to the rundeck servers.
* hostnames of the rundeck servers

Once you enter this information in the top of the script, you should be good to go!

Usage:

`./runutil.sh [failover|stats] $NUM $PROJ`

"$NUM" is the number of the rundeck server to fail to or to run stats on.
"$PROJ" (optional) is the specific project you wish to fail.

## Instructions for use

### failover

Let's say my primary server is called time01. I want to failover to time02.
This would accomplish that:

`./runutil.sh failover 2`

I will be prompted, asking if I really want this. I will, and all of my scheduled jobs
will be moved to the second node.

To fail back:

`./runutil.sh failover 1`

Now they will move back.

### stats

Simply pulls the statistics for that server, such as running info, time up, memory
usage, and whatnot, from the queried machine.

`./runutil.sh stats 1`

Gives statistics for time01
	
### Other args

It is now possible to specify a project after choosing the failover target. To only migrate 
a specific project to a node, specify the name of the project as PROJ. Without this argument, 
it is assumed that you wish to migrate every job on the cluster, as opposed to just a select 
subset of jobs. For example, in project "bananacheese" we can fail jobs over to the secondary
nodee:

`./runutil.sh failover 2 bananacheese`
