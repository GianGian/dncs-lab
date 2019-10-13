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
    - [VLAN](#VLAN) 
    - [Interface-IP mapping](#Interface-IP-mapping)
    - [Network Map](#Network-Map)
3. [Implementation](#implementation)
    - [Vagrantfile](#Vagrantfile)
    - [host-a.sh](#host-ash)
    - [host-b.sh](#host-bsh)
    - [switch.sh](#switchsh)
    - [router-1.sh](#router-1sh)
    - [router-2.sh](#router-2sh)
    - [host-c.sh](#host-csh)
4. [Validation](#validation)
	- [Introduction](#Introduction)
	- [Some commands to test the work](#Some-commands-to-test-the-work)

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
**1**. For the first subnet (between router-1 and host-b) I used the subnet 192.168.0.0/23. Indeed these subnet can cover 2<sup>32-23</sup>-2= 510 address (2<sup>NofIPV4bits-Nofnetmaskbits</sup>-subnet address-broadcast address) (minimun required to cover 436 hosts).

**2**. For the second subnet (between router-1 and host-a) I used the subnet 192.168.2.0/24. Indeed these subnet can cover 2<sup>32-24</sup>-2= 254 address (minimun required to cover 161 hosts).

**3**. For the third subnet (between router-1 and router-2) I used the subnet 10.10.10.0/30. Indeed these subnet can cover 2<sup>32-30</sup>-2= 2 address.

**4**. For the fourth subnet (between router-2 and host-c) I used the subnet 172.16.0.0/23. Indeed these subnet can cover 2<sup>32-23</sup>-2= 510 address (minimun required to cover 504 hosts).


The choice to use the subnets 192.168.0.0/23 and 192.168.2.0/24 was made to use summerization and so to optimize the rules for routing (in router-2).


| Subnet | Devices (Interface)                 | Network address | Netmask        |Broadcast     | # of hosts              |
| ------ | ------------------------------------| ----------------| ---------------| -------------|------------------------ |
| 1      | router-1 (eth1.10)<br>host-a (eth1) | 192.168.2.0/24  | 255.255.255.0  | 192.168.2.255| 2<sup>32-24</sup>-2=254 |
| 2      | router-1 (eth1.20)<br>host-b (eth1) | 192.168.0.0/23  | 255.255.254.0  | 192.168.1.255| 2<sup>32-23</sup>-2=510 |
| 3      | router-2 (eth1)<br>host-c (eth1)    | 10.10.10.0/30   | 255.255.255.252| 10.10.10.3   | 2<sup>32-30</sup>-2=2   |
| 4      | router-1 (eth2)<br>router-2 (eth2)  | 172.16.0.0/23   | 255.255.254.0  | 172.16.1.255 | 2<sup>32-23</sup>-2=510 |
#### VLAN
Between _router-1_ and _switch_ there are 2 subnets so it is required the use of virtual LAN to separete the hosts at level 2. So I set up it for network **1** and **2**.

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
| router-1 | eth2      | 10.10.10.1/30 | 3     |
| router-2 | eth2      | 10.10.10.2/30 | 3      |
| host-c | eth1      | 172.16.0.2/23   | 4    |
| router-2 | eth1      | 172.16.0.1/23   |4      |


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

#### Vagrantfile
The Vagrantfile create and set some settings of the VMs.
in this case only the part of the host-c was reported; indeed the various configurations are very similar.
This is the setting for the host-c VM. There is the command to set interface and to allocate the RAM memory and only in this case it has been changed (from 256 to 512).
```sh
config.vm.define "host-c" do |hostc|
    hostc.vm.box = "ubuntu/bionic64"
    hostc.vm.hostname = "host-c"
    hostc.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    hostc.vm.provision "shell", path: "host-c.sh"
    hostc.vm.provider "virtualbox" do |vb|
      vb.memory = 512
    end
  end
```

This code will execute the provisioning script named "host-c.sh"

#### host-a.sh
```sh
1. export DEBIAN_FRONTEND=noninteractive
2. sudo apt-get update
3. sudo apt-get install -y tcpdump --assume-yes
4. sudo apt install -y curl --assume-yes
5. # Startup commands go here
6. sudo ip link set dev enp0s8 up
7. sudo ip addr add 192.168.2.2/24 dev enp0s8
8. sudo ip route del default
9. sudo ip route add default via 192.168.2.1
```

_line 2_ - _line 4_: installation of libraries and functions

_line 6_: interface enp0s8 (eth1) activation

_line 7_: assignment of the IP address to the interface

_line 8_: erase of default route 

_line 9_: defining of default route 


#### host-b.sh

```sh
1. export DEBIAN_FRONTEND=noninteractive
2. sudo apt-get update
3. sudo apt-get install -y tcpdump --assume-yes
4. sudo apt install -y curl --assume-yes
5. # Startup commands go here
6. sudo ip link set dev enp0s8 up
7. sudo ip addr add 192.168.0.2/23 dev enp0s8
8. sudo ip route del default
9. sudo ip route add default via 192.168.0.1
```
_line 2_ - _line 4_: installation of libraries and functions

_line 6_: interface enp0s8 (eth1) activation

_line 7_: assignment of the IP address to the interface

_line 8_: erase of default route 

_line 9_: defining of default route 


#### switch.sh

```sh
1. export DEBIAN_FRONTEND=noninteractive
2. sudo apt-get update
3. sudo apt-get install -y tcpdump
4. sudo apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common
5. # Startup commands for switch go here
6. sudo ovs-vsctl add-br switch
7. sudo ovs-vsctl add-port switch enp0s8
8. sudo ovs-vsctl add-port switch enp0s9 tag=10
9. sudo ovs-vsctl add-port switch enp0s10 tag=20
10. sudo ip link set enp0s8 up
11. sudo ip link set enp0s9 up
12. sudo ip link set enp0s10 up
```

_line 2_ - _line 4_: installation of libraries and functions

_line 6_: switch creation

_line 7_: interface enp0s8 (eth1) creation

_line 8_: interface enp0s9 (eth2) creation with VLAN tag

_line 9_: interface enp0s10 (eth3) creation with VLAN tag

_line 10_: interface enp0s8 (eth1) activation (between switch and router-1)

_line 11_: interface enp0s9 (eth2) activation (between switch and host-a)

_line 12_: interface enp0s10 (eth3) activation (between switch and host-b)


#### router-1.sh

```sh
1. export DEBIAN_FRONTEND=noninteractive
2. sudo apt-get update
3. sudo apt-get install -y tcpdump --assume-yes
4. sudo apt install -y curl --assume-yes
5. # Startup commands go here
6. sudo sysctl -w net.ipv4.ip_forward=1
7. sudo ip link add link enp0s8 name enp0s8.10 type vlan id 10
8. sudo ip link add link enp0s8 name enp0s8.20 type vlan id 20
9. sudo ip link add link enp0s9 name enp0s9
10. sudo ip link set enp0s8 up
11. sudo ip link set enp0s8.10 up
12. sudo ip link set enp0s8.20 up
13. sudo ip link set enp0s9 up
14. sudo ip addr add 192.168.2.1/24 dev enp0s8.10
15. sudo ip addr add 192.168.0.1/23 dev enp0s8.20
16. sudo ip addr add 10.10.10.1/30 dev enp0s9
17. sudo ip route del default
18. sudo ip route add 172.16.0.0/23 via 10.10.10.2
```

_line 2_ - _line 4_: installation of libraries and functions

_line 6_: enables the ability to reroute packages

_line 7_ - _line 8_: interface enp0s8 (eth1) creation with VLAN tag

_line 9_: interface enp0s9 (eth2) creation

_line 10_ - _line 12_: interface enp0s8 (eth1) activation

_line 13_: interface enp0s9 (eth2) activation

_line 14_ - _line 16_: assignment of the IP address to the interface 

_line 17_: erase of default route 

_line 18_: defining route to reach host-c


#### router-2.sh

```sh
1. export DEBIAN_FRONTEND=noninteractive
2. sudo apt-get update
3. sudo apt-get install -y tcpdump --assume-yes
4. sudo apt install -y curl --assume-yes
5. # Startup commands go here
6. sudo sysctl -w net.ipv4.ip_forward=1
7. sudo ip link add link enp0s8 name enp0s8
8. sudo ip link add link enp0s9 name enp0s9
9. sudo ip link set enp0s8 up
10. sudo ip link set enp0s9 up
11. sudo ip addr add 172.16.0.1/23 dev enp0s8
12. sudo ip addr add 10.10.10.2/30 dev enp0s9
13. sudo ip route del default
14. sudo ip route add 192.168.0.0/22 via 10.10.10.1
```

_line 2_ - _line 4_: installation of libraries and functions

_line 6_: enables the ability to reroute packages

_line 7_: interface enp0s8 (eth1) creation

_line 8_: interface enp0s9 (eth2) creation

_line 9_: interface enp0s8 (eth1) activation

_line 10_: interface enp0s9 (eth2) activation

_line 11_ - _line 12_: assignment of the IP address to the interface 

_line 13_: erase of default route 

_line 14_: defining route to reach host-a and host-b using the summerization


#### host-c.sh

```sh
1. export DEBIAN_FRONTEND=noninteractive
2. sudo apt-get update
3. sudo apt-get install -y tcpdump --assume-yes
4. sudo apt install -y curl --assume-yes
5. sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
6. sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
7. sudo apt-key fingerprint 0EBFCD88 | grep docker@docker.com || exit 1
8. sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
9. sudo apt-get update
10. sudo apt-get install -y docker-ce --assume-yes --force-yes
11. # Startup commands go here
12. sudo docker run --name mybox -p 80:80 -d dustnic82/nginx-test
13. sudo ip link set dev enp0s8 up
14. sudo ip addr add 172.16.0.2/23 dev enp0s8
15. sudo ip route del default
16. sudo ip route add default via 172.16.0.1
```

_line 2_ - _line 10_: installation of libraries and functions

_line 12_: set docker configuration

_line 13_: interface enp0s8 (eth1) creation

_line 14_: assignment of the IP address to the interface 

_line 15_: erase of default route 

_line 16_: defining of default route 



### Validation
#### Introduction
To verify the proper functioning of the work it is sufficient to carry out some steps:
 - Download Vagrant and VirtualBox
 - Clone the repository from there: https://github.com/GianGian/dncs-lab
 - Open the power shell (on Windows) or the bash (on Linux), move into the repository and start creating the machines whit the command `vagrant up`. This may take a few minutes.
 - To switch from a machine from another it can be use the commands `vagrant ssh host-a`(in case of you want to connect with the host-a) and `exit`. 

#### Some commands to test the work
- To verify the interface status
 ```sh
 vagrant@host-a:~$ ip add
 ```
The output in this case it's:
 ```sh
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:82:7a:7b:51:94 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 86136sec preferred_lft 86136sec
    inet6 fe80::82:7aff:fe7b:5194/64 scope link
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:0a:1b:8a brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.2/24 scope global enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe0a:1b8a/64 scope link
       valid_lft forever preferred_lft forever
 ```
In this case the interface enp0s8 is UP and its IP is 192.168.2.2/24.

- To verify the routing table
 ```sh
vagrant@host-a:~$ ip route
 ```
The output in this case it's:
 ```sh
default via 192.168.2.1 dev enp0s8
10.0.2.0/24 dev enp0s3 proto kernel scope link src 10.0.2.15
10.0.2.2 dev enp0s3 proto dhcp scope link src 10.0.2.15 metric 100
192.168.2.0/24 dev enp0s8 proto kernel scope link src 192.168.2.2
 ```
You can see that is has been set a default via (192.168.2.1) but there are other via that connect the host-a and the Management Vagrant (eth0).

- To Verify the mac address table
```sh
vagrant@switch:~$ sudo ovs-appctl fdb/show switch
```
```sh
 port  VLAN  MAC                Age
    1     0  08:00:27:a5:9c:8d  151
    1    10  08:00:27:a5:9c:8d  151
    3    20  08:00:27:85:5a:0e  110
    1    20  08:00:27:a5:9c:8d  110
    2    10  08:00:27:0a:1b:8a  107
```
This is the list of the devices connected at the switch. You can see the MAC-address, their port and if they belong to a VLAN.
In case the command doesn't work it means that in the .sh file miss this command 'sudo apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common'.


- To test the connectivity between 2 hosts
 ```sh
vagrant@host-b:~$ ping 172.16.0.2
 ```
Output:
 ```sh
PING 172.16.0.2 (172.16.0.2) 56(84) bytes of data.
64 bytes from 172.16.0.2: icmp_seq=1 ttl=62 time=1.41 ms
64 bytes from 172.16.0.2: icmp_seq=2 ttl=62 time=2.48 ms
64 bytes from 172.16.0.2: icmp_seq=3 ttl=62 time=2.52 ms
64 bytes from 172.16.0.2: icmp_seq=4 ttl=62 time=2.32 ms
--- 172.16.0.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 1.414/2.187/2.527/0.454 ms

 ```
In this case host-b is able to reach 172.16.0.2 (host-c).

If you disable the interface with the command `vagrant@host-b:~$ sudo ip link set enp0s8 down` the destination became unreachable and with the command `ip add` can be verify that the interface is down.


- To check the route traveled
 ```sh
vagrant@host-b:~$ tracepath 172.16.0.2
 ```
The output is:
 ```sh
 1?: [LOCALHOST]                      pmtu 1500
 1:  _gateway                                              0.587ms
 1:  _gateway                                              0.442ms
 2:  10.10.10.2                                            0.577ms
 3:  172.16.0.2                                            0.774ms reached
     Resume: pmtu 1500 hops 3 back 3
 ```
The package pass through to the gateway (router-1), the router-2 (10.10.10.2) and arrives at the router-c (172.16.0.2)


- To verify the docker settings
```sh
vagrant@host-c:~$ sudo docker ps
```

Output:

```sh
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                         NAMES
bc832a1692b1        dustnic82/nginx-test   "nginx -g 'daemon of…"   8 minutes ago       Up 8 minutes        0.0.0.0:80->80/tcp, 443/tcp   mybox
```
You can see some settings and details about the docker.


- To test the operation of the docker
```sh
vagrant@host-b:~$ curl 172.16.0.2
```
The output is:
```sh
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>
<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
In this case the docker is configured on port 80 (with this command in host-c: 'sudo docker run --name mybox -p 80:80 -d dustnic82/nginx-test'). In case the port is different or it isn't set you have to use this command:
```sh
vagrant@host-b:~$ curl 172.16.0.2:32769
```
Port 32769 is in this case the default port.
