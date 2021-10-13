#!/bin/bash

NS_3SCALE="a-rh-sso-demo"
NS_SSO="a-rh-sso-demo"
NS_APPS="a-rh-sso-demo"

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
oc new-project ${NS_SSO} > /dev/null 2>&1
oc apply --namespace=${NS_SSO} -f deploy-rh-sso/

RH_SSO_URL=$(oc get route/rh-sso --namespace=${NS_SSO} -o=jsonpath='{.spec.host}')
RH_SSO_ADMIN_USER=$(oc get secret --namespace=${NS_SSO} credential-rh-sso -o json | jq -r .data.ADMIN_USERNAME | base64 -d)
RH_SSO_ADMIN_PASS=$(oc get secret --namespace=${NS_SSO} credential-rh-sso -o json | jq -r .data.ADMIN_PASSWORD | base64 -d)

######## Deploy RH 3Scale
## Create a namespace
logHeader "Deploying 3Scale..."
oc new-project ${NS_3SCALE} > /dev/null 2>&1

## Create a RH Registry Pull Secret https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.10/html-single/installing_3scale/index#creating-a-registry-service-account
oc apply --namespace=${NS_3SCALE} -f ~/rh-registry-secret.yaml

## Deploy the 3Scale Operator
oc apply --namespace=${NS_3SCALE} -f deploy-rh-3scale/operator/step1/

until oc get customresourcedefinition apimanagers.apps.3scale.net; do sleep 10; done

oc apply --namespace=${NS_3SCALE} -f deploy-rh-3scale/operator/step2/

until oc rollout status --namespace=${NS_3SCALE} dc/apicast-production; do sleep 10; done

## The Master URL
until [ $(oc get routes --namespace=${NS_3SCALE} --selector='zync.3scale.net/route-to=system-master' -o=json | jq -r '.items | length') -eq 1 ]; do sleep 10; done
THRSCALE_MASTER_URL=$(oc get routes --namespace=${NS_3SCALE} --selector='zync.3scale.net/route-to=system-master' -o=jsonpath='{.items[0].spec.host}')

## The Admin URL
until [ $(oc get routes --namespace=${NS_3SCALE} --selector='zync.3scale.net/route-to=system-provider' -o=json | jq -r '.items | length') -eq 1 ]; do sleep 10; done
THRSCALE_ADMIN_URL=$(oc get routes --namespace=${NS_3SCALE} --selector='zync.3scale.net/route-to=system-provider' -o=jsonpath='{.items[0].spec.host}')

## The Master Credentials
THRSCALE_MASTER_USER=$(oc get secret --namespace=${NS_3SCALE} system-seed -o json | jq -r .data.MASTER_USER | base64 -d)
THRSCALE_MASTER_PASS=$(oc get secret --namespace=${NS_3SCALE} system-seed -o json | jq -r .data.MASTER_PASSWORD | base64 -d)

## The Admin Credentials
THRSCALE_ADMIN_USER=$(oc get secret --namespace=${NS_3SCALE} system-seed -o json | jq -r .data.ADMIN_USER | base64 -d)
THRSCALE_ADMIN_PASS=$(oc get secret --namespace=${NS_3SCALE} system-seed -o json | jq -r .data.ADMIN_PASSWORD | base64 -d)

./app-deployment.sh

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
echo -e "SSO URL: https://${RH_SSO_URL}"
echo -e "SSO Admin Username: ${RH_SSO_ADMIN_USER}"
echo -e "SSO Admin Password: ${RH_SSO_ADMIN_PASS}"
echo -e "\n===== Application Information\n"