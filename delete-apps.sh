#!/bin/bash

oc delete project a-sso-app-demo

ssh suki 'sudo rm -rf /mnt/fastAndLoose/nfs/ocp/core-ocp/a-sso-app-demo'