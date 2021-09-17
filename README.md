# Red Hat Single Sign On Demo

This repo house a number of quickstarts, apps, and services to showcase the capabilities of Red Hat Single Sign On, based on Keycloak.

## Deployment

The deployment target for this demo is Red Hat OpenShift (tested on 4.8) - you could run this on other Kubernetes clusters as well.

## Documentation

- [Deploy Red Hat Single Sign On](./docs/deploy-rh-sso.md)
- [Initial Setup - Creating a Realm, Client, and Users](./docs/rh-sso-initial-setup.md)

## FAQs

- **What is needed to deploy this demo?**
  An OpenShift cluster - any Kubernetes cluster will do, your Ingress needs to be considered though since this demo uses OpenShift Routes.  Not a hard change, but not one that is in the scope of this repo since Ingress options can vary widely.

- **Why not use the Operator?**
  The Operator is still in its early stages and some assets don't reconcile properly - it's best and more easily customizable to deploy via StatefulSets.