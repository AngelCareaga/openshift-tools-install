#!/bin/bash

## Load configurations
echo " ======= LOADING CONFIGURATIONS ======"
. "utils/parse_yaml.sh"
eval $(parse_yaml config-ocp-tools.yml "cfg_")
. "copy_rsa_hosts.sh"

cfg_configure_only_bastion=true

echo " ======= CONFIGURE ========"

## Copy RSA to nodes
copyRSA

# If file exists 
if [[ -f "$path_inventory" ]]; then
    echo "\e[92mInstall pre-prerequisites nodes; subscription, packages, configure docker, nfs..."
    if [ $cfg_satellite_subs = "true" ]; then
        ansible-playbook -i $path_inventory satellite-provider/install_prerrequisitos_nodes_satellite.yml
        else
        ansible-playbook -i $path_inventory subscription-provider/install_prerrequisitos_nodes_subscription.yml
    fi
fi