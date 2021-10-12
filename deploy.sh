#!/bin/bash

NS_3SCALE="rh-3scale-demo"
NS_SSO="rh-sso-demo"
NS_APPS="purrina-app"

######## Deploy RH Serverless
oc apply -f deploy-rh-serverless/step1/

until oc get customresourcedefinition knativeservings.operator.knative.dev; do sleep 3; done

oc apply -f deploy-rh-serverless/step2/

######## Deploy AMQ Streams
oc apply -f deploy-rh-amq-streams/

######## Deploy RH SSO
oc new-project ${NS_SSO}
oc apply -n ${NS_SSO} -f deploy-rh-sso/

######## Deploy RH 3Scale
## Create a namespace
oc new-project ${NS_3SCALE}

## Create a RH Registry Pull Secret https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.10/html-single/installing_3scale/index#creating-a-registry-service-account
oc apply -f ~/rh-registry-secret.yaml -n ${NS_3SCALE}

## Deploy the 3Scale Operator
oc apply -f deploy-rh-3scale/operator/step1/ -n ${NS_3SCALE}

until oc get customresourcedefinition apimanagers.apps.3scale.net; do sleep 3; done

oc apply -f deploy-rh-3scale/operator/step2/ -n ${NS_3SCALE}

oc rollout status dc/apicast-production -n ${NS_3SCALE}

sleep 10

## The Master URL
THRSCALE_MASTER_URL=$(oc get routes -n ${NS_3SCALE} --selector='zync.3scale.net/route-to=system-master' -o=jsonpath='{.items[0].spec.host}')

## The Admin Credentials
THRSCALE_MASTER_USER=$(oc get secret -n ${NS_3SCALE} system-seed -o json | jq -r .data.MASTER_USER | base64 -d)
THRSCALE_MASTER_PASS=$(oc get secret -n ${NS_3SCALE} system-seed -o json | jq -r .data.MASTER_PASSWORD | base64 -d)

## The Admin URL
THRSCALE_ADMIN_URL=$(oc get routes -n ${NS_3SCALE} --selector='zync.3scale.net/route-to=system-provider' -o=jsonpath='{.items[0].spec.host}')

## The Admin Credentials
THRSCALE_ADMIN_USER=$(oc get secret -n ${NS_3SCALE} system-seed -o json | jq -r .data.ADMIN_USER | base64 -d)
THRSCALE_ADMIN_PASS=$(oc get secret -n ${NS_3SCALE} system-seed -o json | jq -r .data.ADMIN_PASSWORD | base64 -d)

######## Deploy PetID Application

######## Deploy Furever Safe

######## Deploy Furever Home
## Add Adoptee
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-add-adoptee-usvc/openshift/kafka-instance/

oc rollout status -n ${NS_APPS} statefulset/pet-cluster-zookeeper

oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-add-adoptee-usvc/openshift/kafka-topic/
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-add-adoptee-usvc/openshift/add-adoptee-usvc/

## Process Adoptee
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-process-adoptee-usvc/openshift/database/

oc rollout status -n ${NS_APPS} deploymentconfig/petadoption-db

oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-process-adoptee-usvc/openshift/database-config/
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-process-adoptee-usvc/openshift/process-adoptee-usvc/
