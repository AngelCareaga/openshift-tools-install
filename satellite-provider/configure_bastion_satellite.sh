#!/bin/bash

## Load configurations
. "utils/parse_yaml.sh"
eval $(parse_yaml config-ocp-tools.yml "cfg_")

## =============== SETTING CONFIGURATION ============== ##

### SATELLITE
url_package_satellite=$cfg_url_package_satellite
org_name_satellite=$cfg_org_name_satellite
act_ket_satellite=$cfg_act_ket_satellite
install_agent_satellite=$cfg_install_agent_satellite

### GENERAL
copy_rsa_by_inventory=$cfg_copy_rsa_by_inventory

## ==================================================== ##

## Subscription
subscription-manager remove --all
subscription-manager clean

## Attach subscription
rpm -Uvh $url_package_satellite --force
subscription-manager register --org="$org_name_satellite" --activationkey="$act_ket_satellite"

## Satellite monitoring
if [ $install_agent_satellite == "true" ]; then
    yum -y install katello-agent
    systemctl start goferd && systemctl enable goferd
fi

## Verify & disable repos
subscription-manager list --consumed
subscription-manager repos --disable="*"

## Repos & packages ansible
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.9-rpms" --enable="rhel-7-fast-datapath-rpms" --enable="rhel-7-server-ansible-2.4-rpms"
yum -y update
yum -y install atomic-openshift-utils

## Copy RSA to nodes
copyRSA