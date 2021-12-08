# app-vue

> Sample application vue app secured with keycloak

## Build Setup

``` bash
# install dependencies
npm install

# serve with hot reload at localhost:8080
npm run dev

# build for production with minification
npm run build
```

For detailed explanation on how things work, consult the [docs for vue-loader](http://vuejs.github.io/vue-loader).

## Building in OpenShift

- Assuming that RH SSO is already installed

```bash
RH_SSO_ROUTE=$(oc get route.route.openshift.io/rh-sso -n ${USER_SSO_NAMESPACE} -o jsonpath='{.status.ingress[0].host}')
APPS_ROUTE_BASE=$(oc get route.route.openshift.io/rh-sso -n ${USER_SSO_NAMESPACE} -o jsonpath='{.status.ingress[0].routerCanonicalHostname}')

KEYCLOAK_SERVER="https://${RH_SSO_ROUTE}/auth/"
KEYCLOAK_REALM='petcorp'
KEYCLOAK_CLIENT_ID='pet-id'
PET_ID_SERVER_ENDPOINT="https://pet-id-backend-${USER_SSO_NAMESPACE}.${APPS_ROUTE_BASE}/app"

oc new-app -n ${USER_SSO_NAMESPACE} --strategy=docker \
--name pet-id-frontend --binary

oc start-build pet-id-frontend --from-dir="services/go-nodejs-pet-id/app-vue/"
```