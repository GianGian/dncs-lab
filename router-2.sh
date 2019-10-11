export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes
# Startup commands go here
sudo sysctl -w net.ipv4.ip_forward=1
sudo ip link add link enp0s8 name enp0s8
sudo ip link add link enp0s9 name enp0s9
sudo ip link set enp0s9 up
sudo ip link set enp0s8 up
sudo ip addr add 10.10.10.2/30 dev enp0s9
sudo ip addr add 172.16.0.1/23 dev enp0s8
sudo ip route del default
sudo ip route add 192.168.0.0/22 via 10.10.10.1