#!/bin/bash

echo "Are you using machines from these specific providers? (OracleCloud / Azure / If none of these press enter):"
read -r provider

echo "What do you want your new hostname to be (Press enter if you don't want to change it):"
read -r hostname

echo "What is your timezone? (It will be defaulted to Europe/Istanbul if none given):"
read -r timezone

while true; do
    read -s -p "Enter new sudo password: " sudopass
    echo
    read -s -p "Confirm new sudo password: " sudopass2
    echo
    if [ "$sudopass" = "" ]; then
        echo "Password cannot be empty. Please try again."
    elif [ "$sudopass" != "$sudopass2" ]; then
        echo "Passwords do not match. Please try again."
    else
        sudo sh -c "echo "root:$sudopass" | chpasswd"
        echo "Sudo password updated successfully."
        break
    fi
done

sudo sed -i '34s/.*/PermitRootLogin without-password/' /etc/ssh/sshd_config

sudo sed -i 's|["'\'']||g' /root/.ssh/authorized_keys
sudo sed -i 's/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,.*exit 142 //g' /root/.ssh/authorized_keys

sudo sh -c "apt-get update && apt-get upgrade && apt-get dist-upgrade -y"

if [[ -z ${hostname+x} ]]; then
    echo "Not changing the hostname"
else
    echo "Changing hostname to $hostname."
    current_hostname=$(cat /etc/hostname)

    sudo hostnamectl set-hostname $hostname
    sudo sed -i "s/$current_hostname/$hostname/g" /etc/hosts

    echo "Finished changing the hostname to $hostname."
fi

if [ -z "$timezone" ]; then

    echo "Changing the timezone to Europe/Istanbul since no input was given"
    sudo timedatectl set-timezone Europe/Istanbul

    echo "Changed the timezone"

else
    echo "Changing the timezone to $timezone"
    sudo timedatectl set-timezone $timezone

    echo "Changed the timezone"

fi

sudo touch /root/.hushlogin

sudo apt-get install wget -y

mkdir temp && cd temp


wget https://raw.githubusercontent.com/tahakocabuga/serversetup/main/.bashrc
wget https://raw.githubusercontent.com/tahakocabuga/serversetup/main/.bash_profile

sudo mv /root/.bashrc /root/.bashrcold
sudo mv .bashrc /root/.bashrc
sudo mv .bash_profile /root/.bash_profile

sudo apt install golang-go
export PATH=$PATH:/usr/local/go/bin
sudo apt install python3
sudo apt install python3-pip
sudo apt install net-tools
sudo apt install htop

if [[ "$provider" =~ ^[oO][rR][aA][cC][lL][eE][cC][lL][oO][uU][dD]$ ]]; then
    echo "OracleCloud selected"

fi

echo "Done! Please reboot your machine"
