#!/bin/bash

oc delete project rh-sso-demo
oc delete project rh-3scale-demo
oc delete project purrina-apps

ssh suki 'sudo rm -rf /mnt/fastAndLoose/nfs/ocp/core-ocp/{rh-sso-demo,rh-3scale-demo,purrina-apps}'