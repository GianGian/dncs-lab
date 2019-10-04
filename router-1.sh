export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update
apt-get install -y tcpdump
# Startup commands go here

ip link set enp0s8.10 up
ip link add link eth1name eth1.10 type vlan id 10
ip add add 192.168.1.1/24 dev enp0s8.10
ip link set eth1.20 up
ip link add link eth1 name eth1.20 type vlan id 20
ip add add 192.168.2.1/24 dev eth1.20
sysctl net.ipv4.ip_forward=1
