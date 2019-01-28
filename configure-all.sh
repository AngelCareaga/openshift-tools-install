#!/bin/bash

## Load configurations
echo " ======= LOADING CONFIGURATIONS ======"
. "utils/parse_yaml.sh"
eval $(parse_yaml config-ocp-tools.yml "cfg_")

echo " ======= CONFIGURE ========"
#Evaluate if use Satellite or direct
if [ $cfg_satellite_subs = "true" ]; then
    sh satellite-provider/configure_bastion_satellite.sh
    else
    sh subscription-provider/configure_bastion_subscription.sh
fi

