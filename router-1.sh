export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes
# Startup commands go here
sudo sysctl -w net.ipv4.ip_forward=1
sudo ip link add link enp0s8 name enp0s8.10 type vlan id 10
sudo ip link add link enp0s8 name enp0s8.20 type vlan id 20
sudo ip link set enp0s8 up
sudo ip link set enp0s8.10 up
sudo ip link set enp0s8.20 up
sudo ip addr add 193.168.1.1/24 dev enp0s8.10
sudo ip addr add 193.168.2.1/24 dev enp0s8.20


