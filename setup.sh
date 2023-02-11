#!/bin/bash

echo "Are you using machines from these specific providers? (OracleCloud / Azure / If none of these press enter):"
read -r provider

echo "What do you want your new hostname to be (Press enter if you don't want to change it):"
read -r hostname

echo "What is your timezone? (It will be defaulted to Europe/Istanbul if none given):"
read -r timezone

sudo sed -i '34s/.*/PermitRootLogin without-password/' /etc/ssh/sshd_config

sudo sh -c "sed -i "s/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"ubuntu\" rather than the user \"root\".';echo;sleep 10;exit 142"
//" /root/.ssh/authorized_keys"

sudo sh -c "apt-get update && apt-get upgrade && apt-get dist-upgrade -y"

if [[ -z ${hostname+x} ]]; then
    echo "Not changing the hostname"
else
    echo "Changing hostname to $hostname."
    current_hostname=$(cat /etc/hostname)

    hostnamectl set-hostname $hostname
    sudo sed -i "s/$current_hostname/$hostname/g" /etc/hosts

    echo "Finished changing the hostname to $hostname."
fi

if [ -z "$timezone" ]; then

    echo "Changing the timezone to Europe/Istanbul since no input was given"
    timedatectl set-timezone Europe/Istanbul

    echo "Changed the timezone"

else
    echo "Changing the timezone to $timezone"
    timedatectl set-timezone $timezone

    echo "Changed the timezone"

fi

touch /root/.hushlogin

sudo apt-get install wget

mkdir temp && cd temp

wget https://raw.githubusercontent.com/tahakocabuga/serversetup/main/.bashrc
wget https://github.com/tahakocabuga/serversetup/blob/main/.bash_profile

mv /root/.bashrc /root/.bashrcold
mv .bashrc /root/.bashrc
mv .bash_profile /root/.bash_profile

if [[ "$provider" =~ ^[oO][rR][aA][cC][lL][eE][cC][lL][oO][uU][dD]$ ]]; then
    echo "OracleCloud selected"

fi
