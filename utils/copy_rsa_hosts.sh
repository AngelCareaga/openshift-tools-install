#!/bin/bash

## Load configurations
. "utils/parse_yaml.sh"
eval $(parse_yaml config-ocp-tools.yml "cfg_")

path_inventory=$cfg_path_inventory

## ================= Functions for RSA ================= #

copyRSA(){
    if [  "$cfg_configure_only_bastion" == "true" ]; then
        echo "Bastion configured correctly"
        else
        echo "Configure bastion connections rsa to nodes"

        ## Certificates
        ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

        echo "Copy rsa to nodes"

        ## Call function
        if [ "$cfg_copy_rsa_by_inventory" == "true" ]; then
            copyRSAByInventory
            else
            copyRSAByList
        fi
    fi
}


## BETAA
copyRSAByInventory() {
    
    # Exp for validate host and domain
    validIpAddressRegex="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";
    validHostnameRegex="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";

    # If file exists 
    read_vars="false"
    if [[ -f "$cfg_path_inventory" ]]; then
        createTempFilePassByConf
        while IFS= read host_line
        do
            ## Declare the host after the "[OSEv3:vars]"
            if [[ $host_line == "[OSEv3:vars]" ]]; then
                read_vars="true"
            fi
            if [ "$read_vars" == "true" ]; then
                if [[ $host_line =~ $validIpAddressRegex || $host_line =~ $validHostnameRegex ]]; then
                    echo "Valid: $host_line"
                    sshpass -f password.txt ssh-copy-id -f -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$host_line
                fi
            fi
        done <"$cfg_path_inventory"
        else 
        echo -e "\e[91mInventory not found, verify config path"
        echo -e "\e[39m"
        abortOnError
        deteteTemFilePassByConf
    fi
}

copyRSAByList(){
    ## declare an array variable
    createTempFilePassByConf
    IFS=';' read -r -a listHostAndIP <<< "$cfg_list_ip"
    for host in "${listHostAndIP[@]}"
    do
        sshpass -f password.txt ssh-copy-id -f -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@$host
    done
    deteteTemFilePassByConf
}

createTempFilePassByConf(){
    touch password.txt
    echo "$cfg_password_nodes" > "password.txt"
}

deteteTemFilePassByConf(){
    rm -f "password.txt"
}