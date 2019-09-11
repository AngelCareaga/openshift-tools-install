#!/bin/bash

## Load configurations
echo " ======= LOADING CONFIGURATIONS ======"
. "utils/parse_yaml.sh"
eval $(parse_yaml config-ocp-tools.yml "cfg_")
. "utils/copy_rsa_hosts.sh"
. "utils/generals.sh"

cfg_configure_only_bastion=false

echo " ======= CONFIGURE ========"

## Copy RSA to nodes
copyRSA

# If file exists 
if [[ -f "$cfg_path_inventory" ]]; then
    echo -e "\e[92mInstall pre-prerequisites nodes; subscription, packages, configure docker, nfs, gluster...\e[39m"
    if [ "$cfg_satellite_subs" == "true" ]; then
        if [ "$cfg_ocp_is_gluster" == "true" ]; then
            ansible-playbook -i $cfg_path_inventory satellite-provider/install_prerrequisitos_nodes_satellite_gluster.yml
            else
            ansible-playbook -i $cfg_path_inventory satellite-provider/install_prerrequisitos_nodes_satellite.yml
        fi
        else
        if [ "$cfg_ocp_is_gluster" == "true" ]; then
            ansible-playbook -i $cfg_path_inventory subscription-provider/install_prerrequisitos_nodes_subscription_gluster.yml
            else
            ansible-playbook -i $cfg_path_inventory subscription-provider/install_prerrequisitos_nodes_subscription.yml
        fi
    fi
    else 
        abortOnEecho -e "\e[91mInventory not found, verify config path"
        echo -e "\e[39m"
        abortOnErrorrror
fi