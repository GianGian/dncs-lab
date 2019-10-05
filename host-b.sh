export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes

# Startup commands go here

sudo ip add add 192.168.2.2/24 dev enp0s8
sudo ip route 192.168.1.0 via 192.168.2.1
sudo ip link set dev enp0s8 up
