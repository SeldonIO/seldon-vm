# Seldon Virtual Machine

This project packages into a single virtual machine all the Seldon projects so they can be tested easily. 

The docs related to this can be found at [http://docs.seldon.io/getting-started.html](http://docs.seldon.io/getting-started.html)

This project provides functionality to:

* Package each Seldon dependency as a Docker container, e.g.:
    * [Seldon Server](https://github.com/SeldonIO/seldon-server) - the real time prediction server
	* [Seldon Spark](https://github.com/SeldonIO/seldon-spark) - offline and streaming jobs in Spark
* Package standard components as docker containers, e.g.:
    * Mysql
	* Zookeeper
	* Consul
* Create a Vagrant VM from the Docker containers
* Provide a Movie Recommender demo integration that goes from iniital raw data to final recommender system. An online version of the final demo can be viewed [here](http://www.seldon.io/movie-demo/). 
* Provide an API explorer. An online version of this can be viewed [here](http://www.seldon.io/api-explorer/)

This VM built and ready to use can be accessed by joining our [Beta program](http://www.seldon.io/open-source) and dowloading the [Vagrant VM](http://docs.seldon.io/vm.html) or using the [AWS AMI](http://docs.seldon.io/vm-aws.html) pre-built Docker instance.

We will give scripts and instructions on how to build the VM yourself in the future. The dependencies needed are:

 * node
 * npm
 * docker
 * make
 * java jdk
 * jq
 * maven
 * bower
 * grunt

An initial script that installs these for Ubuntu (assumes an ubuntu user) can be found in

```
install-dependencies-ubuntu.sh
```

We welcome help to build this VM on different systems. Please clone the project and contact support at seldon dot io if you wish to contribute.


