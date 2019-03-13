#!/bin/bash

## Load configurations
. "utils/parse_yaml.sh"
eval $(parse_yaml config-ocp-tools.yml "cfg_")
. "utils/copy_rsa_hosts.sh"

## =============== SETTING CONFIGURATION ============== ##

### SUBSCRIPTION
username_subscription=$cfg_username_subscription
password_subscription=$cfg_password_subscription
pool_id_subscription=$cfg_pool_id_subscription

### GENERAL
copy_rsa_by_inventory=$cfg_copy_rsa_by_inventory

## ==================================================== ##

## Subscription
subscription-manager remove --all
subscription-manager clean

## Attach subscription
subscription-manager register --username=$username_subscription --password=$password_subscription
subscription-manager attach --pool=$pool_id_subscription

## Verify & disable repos
subscription-manager list --consumed
subscription-manager repos --disable="*"

## Repos & packages ansible
subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-ose-3.9-rpms" --enable="rhel-7-fast-datapath-rpms" --enable="rhel-7-server-ansible-2.4-rpms"
yum -y update
yum -y install atomic-openshift-utils

## Copy RSA to nodes
copyRSA