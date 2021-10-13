#!/bin/bash

oc delete project a-rh-sso-demo

ssh suki 'sudo rm -rf /mnt/fastAndLoose/nfs/ocp/core-ocp/a-rh-sso-demo'

./delete-apps.sh