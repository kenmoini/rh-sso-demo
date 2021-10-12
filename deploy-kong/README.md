# Deploy Kong Gateway to OpenShift

Doing this because 3Scale is a loser.

```bash
# or get a real license lol
echo '{ }' > license

oc apply -f ocp-manual/

oc create secret generic kong-enterprise-license -n kong --from-file=license=$HOME/kong-license/license

# echo '{"cookie_name":"admin_session","cookie_samesite":"off","secret":"s3cr3tP455","cookie_secure":false,"storage":"kong"}' > admin_gui_session_conf

# echo '{"cookie_name":"portal_session","cookie_samesite":"off","secret":"s3cr3tP455","cookie_secure":false,"storage":"kong"}' > portal_session_conf

# oc create secret generic kong-session-config \
#    -n kong \
#    --from-file=admin_gui_session_conf \
#    --from-file=portal_session_conf

helm install my-kong kong/kong -n kong --values ./helm-deployment/values.yaml

HOST=$(oc get svc --namespace kong my-kong-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PORT=$(oc get svc --namespace kong my-kong-kong-proxy -o jsonpath='{.spec.ports[0].port}')
export PROXY_IP=${HOST}:${PORT}
curl $PROXY_IP
```