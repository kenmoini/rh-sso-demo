#!/bin/bash

#NS_APPS="a-rh-sso-demo"
NS_APPS="a-sso-app-demo"

function logHeader() {
  echo -e "\n======================================================================"
  echo "| ${1}"
  echo -e "======================================================================\n"
}

######## Deploy Applications
logHeader "Deploying Applications..."
oc new-project ${NS_APPS} > /dev/null 2>&1

######## Deploy PetID Application

######## Deploy Furever Safe

######## Deploy Furever Home
## Frontend
logHeader "Deploying Furever Home - Frontend..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/static-frontend/openshift/

## Shared Database
logHeader "Deploying Furever Home - Shared Database..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-process-adoptee-usvc/openshift/database/
until oc rollout status -n ${NS_APPS} dc/petadoption-db; do sleep 10; done
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-process-adoptee-usvc/openshift/database-config/
echo "Waiting for DB Population Job to finish..."
until [ $(oc get jobs -n ${NS_APPS} --selector='component==dbpopulate-job' -o=json | jq -r '.items[0].status.succeeded') -eq 1 ]; do sleep 10; done

## Add Adoptee
logHeader "Deploying Furever Home - Add Adoptee Microservice..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-add-adoptee-usvc/openshift/kafka-instance/
until oc rollout status -n ${NS_APPS} deployment/pet-cluster-entity-operator; do sleep 10; done
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-add-adoptee-usvc/openshift/kafka-topic/
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-add-adoptee-usvc/openshift/add-adoptee-usvc/

## Process Adoptee
logHeader "Deploying Furever Home - Process Adoptee Microservice..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-process-adoptee-usvc/openshift/process-adoptee-usvc/

## Backend
logHeader "Deploying Furever Home - Backend..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-backend/openshift/

## Adoption Judge
logHeader "Deploying Furever Home - Adoption Judge Microservice..."
oc apply -n ${NS_APPS} -f services/python-staticjs-furever-home/python-adoption-judge-usvc/openshift/