#!/bin/bash

oc delete project purrina-apps

ssh suki 'sudo rm -rf /mnt/fastAndLoose/nfs/ocp/core-ocp/{rh-sso-demo,rh-3scale-demo,purrina-apps}'