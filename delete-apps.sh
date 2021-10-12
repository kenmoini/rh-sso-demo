#!/bin/bash

oc delete project purrina-apps
oc delete project purrina-demo
oc delete project a-rh-sso-demo

ssh suki 'sudo rm -rf /mnt/fastAndLoose/nfs/ocp/core-ocp/{rh-sso-demo,rh-3scale-demo,purrina-apps,purrina-demo,a-rh-sso-demo}'