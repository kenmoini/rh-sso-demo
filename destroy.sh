#!/bin/bash

oc delete project rh-sso-demo
oc delete project rh-3scale-demo

./delete-apps.sh