# Deploy Red Hat 3Scale API Management to OpenShift via the Operator Framework

## Installation

```bash
## Create a namespace
oc new-project rh-3scale-demo

## Create a RH Registry Pull Secret https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.10/html-single/installing_3scale/index#creating-a-registry-service-account
oc apply -f ~/rh-registry-secret.yaml -n rh-3scale-demo

## Deploy the 3Scale Operator
oc apply -f operator/ -n rh-3scale-demo

## The Master URL
oc get routes -n rh-3scale-demo --selector='zync.3scale.net/route-to=system-master' -o=jsonpath='{.items[0].spec.host}'

## The Admin Credentials
oc get secret -n rh-3scale-demo system-seed -o json | jq -r .data.MASTER_USER | base64 -d
oc get secret -n rh-3scale-demo system-seed -o json | jq -r .data.MASTER_PASSWORD | base64 -d

## The Admin URL
oc get routes -n rh-3scale-demo --selector='zync.3scale.net/route-to=system-provider' -o=jsonpath='{.items[0].spec.host}'

## The Admin Credentials
oc get secret -n rh-3scale-demo system-seed -o json | jq -r .data.ADMIN_USER | base64 -d
oc get secret -n rh-3scale-demo system-seed -o json | jq -r .data.ADMIN_PASSWORD | base64 -d
```

## Deletion

```bash
oc delete project rh-3scale-demo
```