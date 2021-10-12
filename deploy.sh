#!/bin/bash

NS_3SCALE="rh-3scale-demo"
NS_SSO="rh-sso-demo"
NS_APPS="purrina-apps"

function logHeader() {
  echo -e "\n======================================================================"
  echo "| ${1}"
  echo -e "======================================================================\n"
}

######## Deploy RH Serverless
logHeader "Deploying Serverless..."
oc apply -f deploy-rh-serverless/step1/

until oc get customresourcedefinition knativeservings.operator.knative.dev; do sleep 3; done

oc apply -f deploy-rh-serverless/step2/

######## Deploy AMQ Streams
logHeader "Deploying AMQ Streams..."
oc apply -f deploy-rh-amq-streams/

######## Deploy RH SSO
logHeader "Deploying RH SSO..."
oc new-project ${NS_SSO}
oc apply -n ${NS_SSO} -f deploy-rh-sso/

######## Deploy RH 3Scale
## Create a namespace
logHeader "Deploying 3Scale..."
oc new-project ${NS_3SCALE}

## Create a RH Registry Pull Secret https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.10/html-single/installing_3scale/index#creating-a-registry-service-account
oc apply -f ~/rh-registry-secret.yaml -n ${NS_3SCALE}

## Deploy the 3Scale Operator
oc apply -f deploy-rh-3scale/operator/step1/ -n ${NS_3SCALE}

until oc get customresourcedefinition apimanagers.apps.3scale.net; do sleep 10; done

oc apply -f deploy-rh-3scale/operator/step2/ -n ${NS_3SCALE}

until oc rollout status dc/apicast-production -n ${NS_3SCALE}; do sleep 10; done

sleep 10

## The Master URL
until [ $(oc get routes -n ${NS_3SCALE} --selector='zync.3scale.net/route-to=system-master' -o=json | jq -r '.items | length') -eq 1 ]; do sleep 10; done
THRSCALE_MASTER_URL=$(oc get routes -n ${NS_3SCALE} --selector='zync.3scale.net/route-to=system-master' -o=jsonpath='{.items[0].spec.host}')

## The Admin URL
until [ $(oc get routes -n ${NS_3SCALE} --selector='zync.3scale.net/route-to=system-provider' -o=json | jq -r '.items | length') -eq 1 ]; do sleep 10; done
THRSCALE_ADMIN_URL=$(oc get routes -n ${NS_3SCALE} --selector='zync.3scale.net/route-to=system-provider' -o=jsonpath='{.items[0].spec.host}')

## The Master Credentials
THRSCALE_MASTER_USER=$(oc get secret -n ${NS_3SCALE} system-seed -o json | jq -r .data.MASTER_USER | base64 -d)
THRSCALE_MASTER_PASS=$(oc get secret -n ${NS_3SCALE} system-seed -o json | jq -r .data.MASTER_PASSWORD | base64 -d)

## The Admin Credentials
THRSCALE_ADMIN_USER=$(oc get secret -n ${NS_3SCALE} system-seed -o json | jq -r .data.ADMIN_USER | base64 -d)
THRSCALE_ADMIN_PASS=$(oc get secret -n ${NS_3SCALE} system-seed -o json | jq -r .data.ADMIN_PASSWORD | base64 -d)

######## Deploy PetID Application
logHeader "Deploying Applications..."
oc new-project ${NS_APPS}

######## Deploy Furever Safe

######## Deploy Furever Home
## Frontend
logHeader "Deploying Furever Home - Frontend..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/static-frontend/openshift/

## Add Adoptee
logHeader "Deploying Furever Home - Add Adoptee Microservice..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-add-adoptee-usvc/openshift/kafka-instance/
until oc rollout status -n ${NS_APPS} deployment/pet-cluster-entity-operator; do sleep 10; done
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-add-adoptee-usvc/openshift/kafka-topic/
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-add-adoptee-usvc/openshift/add-adoptee-usvc/

## Process Adoptee
logHeader "Deploying Furever Home - Process Adoptee Microservice..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-process-adoptee-usvc/openshift/database/
until oc rollout status -n ${NS_APPS} dc/petadoption-db; do sleep 10; done
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-process-adoptee-usvc/openshift/database-config/
echo "Waiting for DB Population Job to finish..."
until [ $(oc get jobs -n ${NS_APPS} --selector='component==dbpopulate-job' -o=json | jq -r '.items[0].status.succeeded') -eq 1 ]; do sleep 10; done
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-process-adoptee-usvc/openshift/process-adoptee-usvc/

## Backend
logHeader "Deploying Furever Home - Backend..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-backend/openshift/

######## Finished!
logHeader "Deployment COMPLETE!"
echo -e "===== 3Scale Information\n"
echo -e "3Scale Master URL: https://${THRSCALE_MASTER_URL}"
echo -e "3Scale Master Username: ${THRSCALE_MASTER_USER}"
echo -e "3Scale Master Password: ${THRSCALE_MASTER_PASS}"
echo -e "\n3Scale Admin URL: https://${THRSCALE_ADMIN_URL}"
echo -e "3Scale Admin Username: ${THRSCALE_ADMIN_USER}"
echo -e "3Scale Admin Password: ${THRSCALE_ADMIN_PASS}"

echo -e "\n===== Red Hat SSO Information\n"
echo -e "\n===== Application Information\n"