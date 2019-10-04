export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update
apt-get install -y tcpdump --assume-yes
apt install -y curl --assume-yes

# Startup commands go here
sudo ip link set dev eth1 up
sudo ip add add 192.168.2.2/24 dev eth1
