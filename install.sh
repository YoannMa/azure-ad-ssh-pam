#!/bin/bash

#######################
#
# Name: install.sh
# Description: sets up your Azure Active Directory Authentication on your ubuntu machine
# Author: chvugrin@microsoft.com
# Edited: yoann.mallemanche@gmail.com
#
#######################

# OS Check
if [ ! -f /etc/lsb-release ]; then
    echo "Only tested on debian like systems"
    exit 1
else
    id=$(cat /etc/lsb-release | grep DISTRIB_ID | sed 's/^.*[=]//')
    if [[ $id -ne "Ubuntu" ]]; then
        echo "Only tested on Ubuntu"
        exit 1
    fi
fi

# are you root
if [ $(whoami) != "root" ]; then
    echo "you need to be root"
    exit 1
fi

usage() { echo "Usage: $0 -d <A_AD_DIRECTORY_NAME> -c <A_AD_CLIENT_ID>" 1>&2; exit 1; }

while getopts ":h::d::c:" OPT; do
    case ${OPT} in
        h)
            usage;
            exit 1;
            ;;
        d)
            A_AD_DIRECTORY_NAME="$OPTARG";
            ;;
        c)
            A_AD_CLIENT_ID="$OPTARG";
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2;
            usage;
            exit 1;
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2;
            usage;
            exit 1;
            ;;
    esac
done

if [ -z "${A_AD_DIRECTORY_NAME+x}" ]; then
    echo You need to provide an Azure Active Directory Name using the option -d;
    usage;
    exit 1;
fi

if [ -z "${A_AD_CLIENT_ID+x}" ]; then
    echo You need to provide an Azure Active Directory clientID using the option -c;
    usage;
    exit 1;
fi

echo "\n\n Starting setting up your Azure Active Directory Authentication on your ubuntu machine \n\n"

#cp -f aad-login.js.orig aad-login.js

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

nvm install node
nvm use node

sed -i 's/aadDirName/'${A_AD_DIRECTORY_NAME}'/' aad-login.js
sed -i 's/aadClientID/'${A_AD_CLIENT_ID}'/' aad-login.js

cp aad-login /usr/local/bin/aad-login

npm install

sed -i '1s/.*/auth sufficient pam_exec.so expose_authtok \/usr\/local\/bin\/aad-login/' /etc/pam.d/common-auth
