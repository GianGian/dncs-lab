export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes

# Startup commands go here
sudo ip link set dev enp0s8 up
sudo ip addr add 192.168.2.2/24 dev enp0s8
sudo ip route del default
sudo ip route add default via 192.168.2.1

