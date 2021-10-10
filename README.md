# Red Hat Single Sign On Demo

This repo houses a number of quickstarts, apps, and services to showcase the capabilities of Red Hat Single Sign On, based on Keycloak.

Things covered:

- Deploying RH SSO to OpenShift.
- Creating a Realm, configuring it, testing with a basic Client.
- Modifying the deployment to use custom themes with a custom baked image.
- Deploying a number of services to use as Clients.

## Deployment

The deployment target for this demo is Red Hat OpenShift (tested on 4.8) - you could run this on other Kubernetes clusters as well with little modification.

## Documentation

- [Deploy Red Hat Single Sign On](./docs/deploy-rh-sso.md)
- [Initial Setup - Creating a Realm, Client, and Users](./docs/rh-sso-initial-setup.md)

## FAQs

- **What is needed to deploy this demo?**
  An OpenShift cluster - any Kubernetes cluster will do, your Ingress needs to be considered though since this demo uses OpenShift Routes.  Not a hard change, but not one that is in the scope of this repo since Ingress options can vary widely.

- **Why not use the Operator?**
  The Operator is still in its early stages and some assets don't reconcile properly - it's best and more easily customizable to deploy via StatefulSets.

---

## Quickstart Full Demo on OpenShift

Tested on OpenShift 4.8.  Goals:

- Deploy Red Hat Single Sign On
- Deploy Red Hat 3Scale API Management
- Deploy Red Hat Serverless
- Deploy Red Hat AMQ Streams
- Deploy Applications and Microservices
- Configure Red Hat SSO
  - Create a Realm for PetCorp
    - Create Clients for:
      - `pet-id-backend`
      - `pet-id-frontend`
      - `furever-home-backend`
      - `furever-home-frontend`
      - `furever-safe-backend`
      - `furever-safe-frontend`
      - `3scale-admin`
      - `3scale-developer`
    - Create Groups for:
      - `mypetcorp-users`
      - `mypetcorp-admins`
    - Create Test Users (userNN@mypetcorp.com)
    - Create Test Admin Users (adminNN@mypetcorp.com)
    - Map Users to Groups
    - Map Groups to Client Roles


### 1. Deploy RH SSO

```bash
oc apply -f deploy-rh-sso/

## RH SSO Route
oc get route rh-sso -n rh-sso-demo -o=jsonpath='{.spec.host}'

## RH SSO Admin Credentials
oc get secret -n rh-sso-demo credential-rh-sso -o=jsonpath='{.data.ADMIN_USERNAME}' | base64 -d
oc get secret -n rh-sso-demo credential-rh-sso -o=jsonpath='{.data.ADMIN_PASSWORD}' | base64 -d
```

### 2. Deploy RH 3Scale

```bash
oc new-project rh-3scale-demo
## Create a RH Registry Pull Secret https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.10/html-single/installing_3scale/index#creating-a-registry-service-account
oc apply -f ~/rh-registry-secret.yaml -n rh-3scale-demo
oc apply -f deploy-rh-3scale/operator/ -n rh-3scale-demo

## Wait for like...5 minutes...

## The Master URL
oc get routes -n rh-3scale-demo --selector='zync.3scale.net/route-to=system-master' -o=jsonpath='{.items[0].spec.host}'

## The Admin Credentials
oc get secret -n rh-3scale-demo system-seed -o=jsonpath='{.data.MASTER_USER}' | base64 -d
oc get secret -n rh-3scale-demo system-seed -o=jsonpath='{.data.MASTER_PASSWORD}' | base64 -d

## The Admin URL
oc get routes -n rh-3scale-demo --selector='zync.3scale.net/route-to=system-provider' -o=jsonpath='{.items[0].spec.host}'

## The Admin Credentials
oc get secret -n rh-3scale-demo system-seed -o=jsonpath='{.data.ADMIN_USER}' | base64 -d
oc get secret -n rh-3scale-demo system-seed -o=jsonpath='{.data.ADMIN_PASSWORD}' | base64 -d

## The Developer URL
oc get routes -n rh-3scale-demo --selector='zync.3scale.net/route-to=system-developer' -o=jsonpath='{.items[0].spec.host}'
```

### 3. Deploy Red Hat Serverless

```bash
## Install the operator
oc apply -f deploy-rh-serverless/step1/

## Wait for like...5 min...or:
until oc get customresourcedefinition knativeservings.operator.knative.dev; do sleep 3; done

## Create the basic eventing and serving structures
oc apply -f deploy-rh-serverless/step2/
```

### 4. Deploy Red Hat AMQ Streams

```bash
oc apply -f deploy-rh-amq-streams/
```

### 5. Configure RH SSO

#### Create a Demo Realm

Literally create a Realm called `demo`

#### Create a Client for the 3Scale Developer Portal

#### Create a Client for the 3Scale Admin Portal

Create a new Client with the following configuration:

- **Name:** `3scale-admin-portal`
- **Client Protocol:** `openid-connect`
- **Login Theme:** `<your_choice>`
- **Access Type:** `confidential`

With the Client created, you can use it and the ID/Secret pair to create the Admin Portal integratino in 3Scale under the Admin Portal > Account Settings > Users > SSO Integrations.  Create the Integration and that will give you the generated callback URLs to provide back to this SSO Client...

### 6. Configure 3Scale - OpenID Connect

https://access.redhat.com/documentation/en-us/red_hat_3scale_api_management/2.3/html/api_authentication/openid-connect#configure-oidc-rhsso-integration

#### Configure Zync with Custom CAs for RH SSO

```bash
## Download the OpenShift Router CA Certificate
oc get secret router-ca -n openshift-ingress-operator -o template='{{index .data "tls.key"}}' | base64 -d > $HOME/route-ca.pem

## Get the Zync Certificate Store
ZYNC_POD_NAME=$(oc get pods -n rh-3scale-demo --selector='deploymentConfig=zync' -o=jsonpath='{.items[0].metadata.name}')
oc exec $ZYNC_POD_NAME -- cat /etc/pki/tls/cert.pem > $HOME/zync.pem

## Merge the Certificates
cat $HOME/route-ca.pem >> $HOME/zync.pem

## Create a CA Configmap
oc create configmap zync-ca-bundle -n rh-3scale-demo --from-file=$HOME/zync.pem

## Set the Volume
oc set volume dc/zync --add --name=zync-ca-bundle --mount-path /etc/pki/tls/zync/zync.pem --sub-path zync.pem --source='{"configMap":{"name":"zync-ca-bundle","items":[{"key":"zync.pem","path":"zync.pem"}]}}'

## Configure the DeploymentConfig
oc patch dc/zync --type=json -p '[{"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts/0/subPath", "value":"zync.pem"}]'
oc set env dc/zync SSL_CERT_FILE=/etc/pki/tls/zync/zync.pem
```

#### Get the Token Introspection Link

```bash
RH_SSO_URI_BASE="https://$(oc get route rh-sso -n rh-sso-demo -o=jsonpath='{.spec.host}')/auth"
curl -sSLk "${RH_SSO_URI_BASE}/realms/master/.well-known/openid-configuration" | jq -r '.token_introspection_endpoint'
```

#### Get the Issuer Link

```bash
RH_SSO_URI_BASE="https://$(oc get route rh-sso -n rh-sso-demo -o=jsonpath='{.spec.host}')/auth"
curl -sSLk "${RH_SSO_URI_BASE}/realms/master/.well-known/openid-configuration" | jq -r '.issuer'
```

#### Disable the Access Control on the Developer Portal

Null the text field in the admin panel under Audience > Developer Portal > Settings > Domains & Access

### 7. Deploy Frontend Applications