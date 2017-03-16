# dc/os cluster orchestration for softlayer

The following is a quick guide on how to install [dc/os](https://dcos.io/) on softlayer. Detailed information about dc/os
can be found [here](https://dcos.io/docs/1.9/).

## install & configure kleiber

First clone the [kleiber](https://github.rtp.raleigh.ibm.com/edgepoc/kleiber) repository.

**Note:** If you don't want to install kleiber to your OS'es python then you should setup a python [virtualenv](http://docs.python-guide.org/en/latest/dev/virtualenvs/) 
before you run the following install command.

Change to the kleiber directory and run the install command as follows.
```
cd <kleiber_home>
python setup.py install
```

Next create the following configration file `~/.kleiber` and enter your softlayer credentials as shown in the following.

```
username: SLUSER                                                  
api_key: SLAPIKEY
```


## install the dc/os cluster

First change to the directory that contains the kleiber score for dc/os.
```
cd <kleiber_home>/kleiber/examples/scores/open-dcos
```

Next we use the following kleiber create command to install the dc/os cluster.

**Note:** This process takes a while so be patient, don't close your terminal. We run with **-v** option so that you see debug output, and know something is happening.

```
kleiber create open-dcos.yml cluster_name datacenter=sjc01 masters=1 agents=1 public_agents=1 firewall=true keyname=public_key_name pkey=private_key_path -v
```
* cluster_name - the name you want to give the cluster, will be the prefix on all the node names
* datacenter - the softlayer datacenter you want the dc/os cluster created in
* masters - the number of mesos master nodes you want in your dc/os cluster, for HA you would want 3
* agents - the number of mesos agent nodes you want in your dc/os cluster
* public_agents - the number of mesos public agent nodes you want in your dc/os cluster
* firewall - the master and (private) agent nodes are only ssh accessible when firewall is set to true. Note that if firewall is set to false all is open.
* keyname - the name of the public key registered with softlayer with which the nodes get configured
* pkey - the path of the private key file, required by the bootstrap node to install the dc/os roles on masters and agents


The creation ends with the following ouput when firewall is set to true. Create an ssh tunnel from your client with the command shown. Pick the dcos url and put it into your browser, it will take you to the dc/os console.

```
create ssh tunnel to master: "ssh -i <private_key_path> -f core@<master_ip> -L 7000:<master_ip>:443 -N" 
   
dcos: "https://localhost:7000"
mesos: "https://localhost:7000/mesos"
exhibitor: "https://localhost:7000/exhibitor"
bootstrap: "<boostrap_ip>"
```

The creation ends with the following ouput when firewall is set to false. Pick the dcos url and put it into your browser, it will take you to the dc/os console.

```
dcos: "http://<master_ip>"
mesos: "http://<master_ip>/mesos"
exhibitor: "http://<master_ip>/exhibitor"
bootstrap: "<boostrap_ip>"
```


## install the dc/os cli

For installing the dc/os cli yourself and how to use it go [here](https://dcos.io/docs/1.9/usage/cli/).

If you dont want to install the dc/os cli on your client just yet, then we have a quick way for you to explore it.

In the previous install step we also created a container on the boostrap node that has the dc/os cli installed. First
ssh into the boostrap node. Once you are in the boostrap node enter the following command to get you to the shell of
the container that has the dc/os cli.
```
docker exec -ti dcoscli bash
```

Entering the dcos command should give you the following.
```
root@69e768a60f2a:/dcos# dcos
Command line utility for the Mesosphere Datacenter Operating
System (DCOS). The Mesosphere DCOS is a distributed operating
system built around Apache Mesos. This utility provides tools
for easy management of a DCOS installation.

Available DCOS commands:

	auth           	Authenticate to DCOS cluster
	config         	Manage the DCOS configuration file
	help           	Display help information about DCOS
	marathon       	Deploy and manage applications to DCOS
	node           	Administer and manage DCOS cluster nodes
	package        	Install and manage DCOS software packages
	service        	Manage DCOS services
	task           	Manage DCOS tasks

Get detailed command description with 'dcos <command> --help'.
```

