#!/bin/bash

## Load configurations
. "utils/parse_yaml.sh"
eval $(parse_yaml config-ocp-tools.yml "cfg_")

path_inventory=$cfg_path_inventory
path_host_ip_list=$cfg_path_host_ip_list


# Exp for validate host and domain
validIpAddressRegex="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";
validHostnameRegex="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";

## Read inventory and copy rsa_pub to masters, infra, nodes, lb, etc
file=$path_inventory

# If file exists 
read_vars="false"
if [[ -f "$path_inventory" ]]; then
    while IFS= read host_line
    do
        if [[ $host_line == "[OSEv3:vars]" ]]; then
            read_vars="true"
        fi
        if [ $read_vars == "true" ]; then
            if [[ $host_line =~ $validIpAddressRegex || $host_line =~ $validHostnameRegex ]]; then
                echo $host_line >> path_host_ip_list
            fi
        fi
    done <"$file"
fi