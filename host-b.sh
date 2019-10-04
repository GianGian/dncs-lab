export DEBIAN_FRONTEND=noninteractive
sudo su
apt-get update
apt-get install -y tcpdump --assume-yes
apt install -y curl --assume-yes

# Startup commands go here

ip add add 192.168.2.2/24 dev eth1
ip route 192.168.1.0 via 192.168.2.1
ip link set dev eth1 up
