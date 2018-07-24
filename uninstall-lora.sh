#!/bin/bash
#This script will uninstall lora
# Variables related to output-text style
 RED='\033[0;31m'
 BLUE='\033[0;34m'
 ORANGE='\033[0;33m'
 GREEN='\033[0;32m'
 NC='\033[0m' # No Color
# Stop on the first sign of trouble
set -e
if [ $UID != 0 ]; then
    echo -e "${RED}ERROR: Operation not permitted. Forgot sudo?${NC}"
    exit 1
fi
echo -e "${GREEN}LoRa Box Uninstaller${NC}"
echo
echo -e "${ORANGE}Deactivating SPI port on Raspberry Pi${NC}"
pushd /boot
sed -i -e 's/dtparam=spi=on/#dtparam=spi=on/g' ./config.txt
popd
echo
echo -e "${BLUE}Gateway configuration:${NC}"
# Change hostname
CURRENT_HOSTNAME=$(hostname)
NEW_HOSTNAME="raspberrypi"
echo -e "${ORANGE}Updating hostname to '$NEW_HOSTNAME'...${NC}"
hostname $NEW_HOSTNAME
echo $NEW_HOSTNAME > /etc/hostname
sed -i "s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/" /etc/hosts
echo
echo -e "${ORANGE}Uninstalling LoRaWAN...${NC}"
rm -rf /opt/lora-box
echo
rm -rf /etc/systemd/system/lora-box.service
rm -rf /etc/apt/sources.list.d/loraserver.list
echo -e "${ORANGE}Uninstalling LoRa Gateway Bridge${NC}"
apt remove -y lora-gateway-bridge
rm -rf /etc/lora-gateway-bridge
echo -e "${ORANGE}Uninstalling LoRaWAN Server${NC}"
apt remove -y loraserver
rm -rf /etc/loraserver
echo -e "${ORANGE}Uninstalling LoRa Application Server${NC}"
apt remove -y lora-app-server
rm -rf /etc/lora-app-server
echo -e "${ORANGE}Uninstalling dependencies${NC}"
apt remove -y mosquitto mosquitto-clients redis-server redis-tools apt-transport-https dirmngr postgresql
sudo -u postgres psql -c "drop database if exists loraserver_ns;"
sudo -u postgres psql -c "drop database if exists loraserver_as;"
sudo -u postgres psql -c "drop role if exists loraserver_ns;"
sudo -u postgres psql -c "drop role if exists loraserver_as;"
echo -e "${GREEN}End of LoRa Box Uninstaller${NC}"
echo -e "${ORANGE}The system will reboot in 30 seconds...${NC}"
sleep 30
shutdown -r now
