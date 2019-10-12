export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y tcpdump --assume-yes
sudo apt install -y curl --assume-yes
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sudo apt-key fingerprint 0EBFCD88 | grep docker@docker.com || exit 1
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce --assume-yes --force-yes
# Startup commands go here
sudo docker run --name mybox -p 80:80 -d dustnic82/nginx-test
sudo ip link set dev enp0s8 up
sudo ip addr add 172.16.0.2/23 dev enp0s8
sudo ip route del default
sudo ip route add default via 172.16.0.1


