export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update
apt-get install -y tcpdump --assume-yes
apt install -y curl --assume-yes

# Startup commands go here
ip link set dev eth1 up
ip add add 192.168.1.2/24 dev eth1