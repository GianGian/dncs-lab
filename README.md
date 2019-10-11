# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                       |eth1
        |  N  |                      |                           |
        |  A  |                      |                           |
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |eth1         |eth1                |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+  host-a  |     |  host-b  |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+



```

# Requirements
 - Python 3
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/dustnic/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
`vagrant ssh host-c`

# Assignment
This section describes the assignment, its requirements and the tasks the student has to complete.
The assignment consists in a simple piece of design work that students have to carry out to satisfy the requirements described below.
The assignment deliverable consists of a Github repository containing:
- the code necessary for the infrastructure to be replicated and instantiated
- an updated README.md file where design decisions and experimental results are illustrated
- an updated answers.yml file containing the details of 

## Design Requirements
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 161 and 436 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 504 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command

## Tasks
- Fork the Github repository: https://github.com/dustnic/dncs-lab
- Clone the repository
- Run the initiator script (dncs-init). The script generates a custom `answers.yml` file and updates the Readme.md file with specific details automatically generated by the script itself.
  This can be done just once in case the work is being carried out by a group of (<=2) engineers, using the name of the 'squad lead'. 
- Implement the design by integrating the necessary commands into the VM startup scripts (create more if necessary)
- Modify the Vagrantfile (if necessary)
- Document the design by expanding this readme file
- Fill the `answers.yml` file where required (make sure that is committed and pushed to your repository)
- Commit the changes and push to your own repository
- Notify the examiner that work is complete specifying the Github repository, First Name, Last Name and Matriculation number. This needs to happen at least 7 days prior an exam registration date.

# Notes and References
- https://rogerdudler.github.io/git-guide/
- http://therandomsecurityguy.com/openvswitch-cheat-sheet/
- https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/
- https://www.vagrantup.com/intro/getting-started/

# Design

## Table of Contents
1. [DNCS-LAB assigment](#DNCS-LAB-assigment)
2. [Technical choices](#Technical-choices)
    - [Subnets](#subnets) 
    - [VLANs](#VLANs) 
    - [Interface-IP mapping](#Interface-IP-mapping)
    - [Network Map](#Network-Map)
3. [Implementation](#implementation)
    -[host-a.sh](#host-a.sh)
    -[host-b.sh](#host-b.sh)
    -[switch.sh](#switch.sh)
    -[router-1.sh](#router-1.sh)
    -[router-2.sh](#router-2.sh)
    -[host-c.sh](#host-c.sh)



4. [Validation](#validation)

### DNCS-LAB assigment
Design of Networks and Communication Systems
A.Y. 2019/20
University of Trento

Starting from a _Vagrantfile_  available at https://github.com/dustnic/dncs-lab the student have to design a simply network configured as above. The design requirements are:
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 161 and 436 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 504 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the vagrant up command

### Technical choices
#### Subnets
I decided to set up four subnets:
**1**. For the first subnet (between router-1 and host-b) I used the subnet 192.168.0.0/23. Indeed these subnet can cover 2<sup>32-23</sup>-2= 510 address (2<sup>NofIPV4bits-Nofnetmaskbits</sup>-subnet address-broadcast address).
**2**. For the second subnet (between router-1 and host-a) I used the subnet 192.168.2.0/24. Indeed these subnet can cover 2<sup>32-24</sup>-2= 254 address.
**3**. For the third subnet (between router-1 and router-2) I used the subnet 10.10.10.0/30. Indeed these subnet can cover 2<sup>32-30</sup>-2= 2 address.
**4**. For the fourth subnet (between router-2 and host-c) I used the subnet 172.16.0.0/23. Indeed these subnet can cover 2<sup>32-23</sup>-2= 510 address.

| Subnet | Devices (Interface)                 | Network address | Netmask        |Broadcast     | # of hosts              |
| ------ | ------------------------------------| ----------------| ---------------| -------------|------------------------ |
| 1      | router-1 (eth1.10)<br>host-a (eth1) | 192.168.2.0/24  | 255.255.255.0  | 192.168.2.255| 2<sup>32-24</sup>-2=254 |
| 2      | router-1 (eth1.20)<br>host-b (eth1) | 192.168.0.0/23  | 255.255.254.0  | 192.168.1.255| 2<sup>32-23</sup>-2=510 |
| 3      | router-2 (eth1)<br>host-c (eth1)    | 10.10.10.0/30   | 255.255.255.252| 10.10.10.3   | 2<sup>32-30</sup>-2=2   |
| 4      | router-1 (eth2)<br>router-2 (eth2)  | 172.16.0.0/23   | 255.255.254.0  | 172.16.1.255 | 2<sup>32-23</sup>-2=510 |
#### VLANs
Between _router-1_ and _switch_ there are 2 subnets so it is required the use of virtual LANs. So I set up it for network **1** and **2**.

| ID  | Subnet |
| --- | ------ |
| 10  | 1      |
| 20  | 2      |

#### Interface-IP mapping

I decided to give the X.X.X.1 IP to the routers, which will also be the gateways. The hosts so have the X.X.X.2 IP.
Every subnet hasn't got contiguous addresses (it was not a specification) to make the subdivision of the various subnets clearer.

| Device   | Interface | IP                | Subnet |
| -------- | --------- | ----------------- | ------ |
| host-a   | eth1      | 192.168.2.2/24     | 1     |
| router-1 | eth1.10   | 192.168.2.1/24   | 1      |
| host-b  | eth1      | 192.168.0.2/23   | 2     |
| router-1 | eth1.20   | 192.168.0.1/23   |2      |
| host-c | eth1      | 172.16.0.2/23   | 3     |
| router-2 | eth1      | 172.16.0.1/23   |3      |
| router-1 | eth2      | 10.10.10.1/30 | 4      |
| router-2 | eth2      | 10.10.10.2/30 | 4      |

#### Network Map

        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |10.10.10.1   |            |
        |     |                |            |   10.10.10.2|            |
        |  M  |                +------------+             +------------+
        |  A  | eth1.20  192.168.2.1 |eth1.10  192.168.0.1       |eth1 172.16.0.1
        |  N  |                      |                           |
        |  A  |                      |                           |eth1 172.16.0.2
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |  192.168.2.2  |eth1         |eth1 192.168.0.2    |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+  host-a  |     |  host-b  |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+

### Implementation
#### host-a.sh
```sh
$export DEBIAN_FRONTEND=noninteractive
$sudo apt-get update
$sudo apt-get install -y tcpdump --assume-yes
$sudo apt install -y curl --assume-yes
$# Startup commands go here
$sudo ip link set dev enp0s8 up
$sudo ip addr add 192.168.2.2/24 dev enp0s8
$sudo ip route del default
$sudo ip route add default via 192.168.2.1
```

#### host-b.sh
#### switch.sh
#### router-1.sh
#### router-2.sh
#### host-c.sh

### Validation

