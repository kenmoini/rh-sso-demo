# Red Hat Single Sign On Demo

This repo house a number of quickstarts, apps, and services to showcase the capabilities of Red Hat Single Sign On, based on Keycloak.

# Deploying the Demo

The deployment target for this demo is Red Hat OpenShift (tested on 4.8) - you could run this on other Kubernetes clusters as well.

## Deploying RH SSO

First thing's first, we're going to deploy RH SSO via StatefulSets:

### Create the Namespace

```yaml
---
kind: Namespace
apiVersion: v1
metadata:
  name: rh-sso-demo
  labels:
    kubernetes.io/metadata.name: rh-sso-demo
  annotations:
    openshift.io/description: 'A robust Red Hat Single Sign On demonstration with authentation in and out of a number of apps and services.'
    openshift.io/display-name: 'Red Hat SSO Demo'
spec: {}
```

### Services - rh-sso

```yaml
---
kind: Service
apiVersion: v1
metadata:
  annotations:
    description: The web server's https port.
    service.beta.openshift.io/serving-cert-secret-name: rh-sso-x509-https-secret
  labels:
    app: rh-sso
  name: rh-sso
  namespace: rh-sso-demo
spec:
  ports:
    - name: rh-sso
      protocol: TCP
      port: 8443
      targetPort: 8443
  selector:
    app: rh-sso
    component: rh-sso
  type: ClusterIP
```

### Services - rh-sso-discover

```yaml
---
kind: Service
apiVersion: v1
metadata:
  name: rh-sso-discovery
  namespace: rh-sso-demo
  labels:
    app: rh-sso
spec:
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  selector:
    app: rh-sso
    component: rh-sso
  type: ClusterIP
```

### Services - rh-sso-monitoring

```yaml
---
kind: Service
apiVersion: v1
metadata:
  annotations:
    description: The monitoring service for Prometheus
  name: rh-sso-monitoring
  namespace: rh-sso-demo
  labels:
    app: rh-sso
spec:
  ports:
    - name: rh-sso-monitoring
      protocol: TCP
      port: 9990
      targetPort: 9990
  selector:
    app: rh-sso
    component: rh-sso
  type: ClusterIP
```

### Services - rh-sso-postgresql

```yaml
---
kind: Service
apiVersion: v1
metadata:
  name: rh-sso-postgresql
  namespace: rh-sso-demo
  labels:
    app: rh-sso
spec:
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
  selector:
    app: rh-sso
    component: database
  type: ClusterIP
```


### Routes - rh-sso

```yaml
---
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: rh-sso
  namespace: rh-sso-demo
  labels:
    app: rh-sso
spec:
  to:
    kind: Service
    name: rh-sso
    weight: 100
  port:
    targetPort: rh-sso
  tls:
    termination: reencrypt
  wildcardPolicy: None
```

### Routes - rh-sso-metrics-rewrite

```yaml
---
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: rh-sso-metrics-rewrite
  namespace: rh-sso-demo
  labels:
    app: rh-sso
spec:
  path: /auth/realms/master/metrics
  to:
    kind: Service
    name: rh-sso
    weight: 100
  port:
    targetPort: rh-sso
  tls:
    termination: reencrypt
  wildcardPolicy: None
```

```yaml
---
kind: Route
apiVersion: route.openshift.io/v1
metadata:
  name: rh-sso-myrealm-metrics-rewrite
  namespace: rh-sso-demo
  labels:
    app: rh-sso
spec:
  path: /auth/realms/myrealm/metrics
  to:
    kind: Service
    name: rh-sso
    weight: 100
  port:
    targetPort: rh-sso
  tls:
    termination: reencrypt
  wildcardPolicy: None
```

### Secrets - RH SSO Admin Credentials

You can create a Secret with the following command:

```bash
oc create secret generic credential-rh-sso --from-literal=ADMIN_USERNAME=supersecret --from-literal=ADMIN_PASSWORD=topsecret -n rh-sso-demo
```

Or with the following YAML structure:

```yaml
---
kind: Secret
apiVersion: v1
metadata:
  name: credential-rh-sso
  namespace: rh-sso-demo
  labels:
    app: rh-sso
data:
  ## The ADMIN_PASSWORD is r3dh4t123!
  ADMIN_PASSWORD: cjNkaDR0MTIzIQ==
  ## The ADMIN_USERNAME is admin
  ADMIN_USERNAME: YWRtaW4=
type: Opaque
```

### Secrets - RH SSO Database Credentials

We'll create some Secrets to supply our database information - create it with the following command:

```bash
POSTGRESQL_USERNAME="rhsso"
POSTGRESQL_PASSWORD="someSuperSecretP455"
POSTGRESQL_DATABASE_NAME="rhsso"
POSTGRESQL_SERVICE_HOSTNAME="rh-sso-postgresql"
POSTGRESQL_VERSION="10"

oc create secret generic rh-sso-db-secret --from-literal=POSTGRES_USERNAME=${POSTGRESQL_USERNAME} --from-literal=POSTGRES_PASSWORD=${POSTGRESQL_PASSWORD} --from-literal=POSTGRES_HOST=${POSTGRESQL_SERVICE_HOSTNAME} --from-literal=POSTGRES_DATABASE=${POSTGRESQL_DATABASE_NAME} --from-literal=POSTGRES_VERSION=${POSTGRESQL_VERSION} -n rh-sso-demo
```

Alternatively, you could apply the same YAML which has those above values:

```yaml
---
kind: Secret
apiVersion: v1
metadata:
  name: rh-sso-db-secret
  namespace: rh-sso-demo
data:
  POSTGRES_DATABASE: cmhzc28=
  POSTGRES_HOST: cmgtc3NvLXBvc3RncmVzcWw=
  POSTGRES_PASSWORD: c29tZVN1cGVyU2VjcmV0UDQ1NQ==
  POSTGRES_USERNAME: cmhzc28=
  POSTGRES_VERSION: MTA=
type: Opaque
```

### ConfigMaps - rh-sso-probes

```yaml
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: rh-sso-probes
  namespace: rh-sso-demo
  labels:
    app: rh-sso
data:
  liveness_probe.sh: |
    #!/bin/bash
    set -e
    curl -s --max-time 10 --fail http://$(hostname -i):8080/auth > /dev/null
  readiness_probe.sh: "#!/bin/bash\nset -e\n\nDATASOURCE_POOL_TYPE=\"data-source\"\nDATASOURCE_POOL_NAME=\"KeycloakDS\"\n\nPASSWORD_FILE=\"/tmp/management-password\"\nPASSWORD=\"not set\"\nUSERNAME=\"admin\"\nAUTH_STRING=\"\"\n\nif [ -d \"/opt/eap/bin\" ]; then\n    pushd /opt/eap/bin > /dev/null\n\tDATASOURCE_POOL_TYPE=\"xa-data-source\"\n\tDATASOURCE_POOL_NAME=\"keycloak_postgresql-DB\"\nelse\n    pushd /opt/jboss/keycloak/bin > /dev/null\n\tif [ -f \"$PASSWORD_FILE\" ]; then\n\t\tPASSWORD=$(cat $PASSWORD_FILE)\n\telse\n\t\tPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)\n\t\t./add-user.sh -u $USERNAME -p $PASSWORD> /dev/null\n\t\techo $PASSWORD > $PASSWORD_FILE\n\tfi\n\tAUTH_STRING=\"--digest -u $USERNAME:$PASSWORD\"\nfi\n\ncurl -s --max-time 10 --fail http://localhost:9990/management $AUTH_STRING --header \"Content-Type: application/json\" -d \"{\\\"operation\\\":\\\"test-connection-in-pool\\\", \\\"address\\\":[\\\"subsystem\\\",\\\"datasources\\\",\\\"${DATASOURCE_POOL_TYPE}\\\",\\\"${DATASOURCE_POOL_NAME}\\\"], \\\"json.pretty\\\":1}\"\ncurl -s --max-time 10 --fail http://$(hostname -i):8080/auth > /dev/null\n"
```

### PersistentVolumeClaims - rh-sso-postgresql-claim

```yaml
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: rh-sso-postgresql-claim
  namespace: rh-sso-demo
  labels:
    app: rh-sso
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### StatefulSets - RH SSO PostgreSQL Database

```yaml
---
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: rh-sso-postgresql
  namespace: rh-sso-demo
  labels:
    app: rh-sso
    component: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rh-sso
      component: database
  template:
    metadata:
      name: rh-sso-postgresql
      namespace: rh-sso-demo
      creationTimestamp: null
      labels:
        app: rh-sso
        component: database
    spec:
      volumes:
        - name: rh-sso-postgresql-claim
          persistentVolumeClaim:
            claimName: rh-sso-postgresql-claim
      containers:
        - resources: {}
          readinessProbe:
            exec:
              command:
                - /bin/sh
                - '-c'
                - >-
                  psql -h 127.0.0.1 -U $POSTGRESQL_USER -q -d
                  $POSTGRESQL_DATABASE -c 'SELECT 1'
            initialDelaySeconds: 5
            timeoutSeconds: 1
            periodSeconds: 10
            successThreshold: 1
            failureThreshold: 3
          terminationMessagePath: /dev/termination-log
          name: rh-sso-postgresql
          livenessProbe:
            tcpSocket:
              port: 5432
            initialDelaySeconds: 30
            timeoutSeconds: 1
            periodSeconds: 10
            successThreshold: 1
            failureThreshold: 3
          env:
            - name: POSTGRESQL_USER
              valueFrom:
                secretKeyRef:
                  name: rh-sso-db-secret
                  key: POSTGRES_USERNAME
            - name: POSTGRESQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: rh-sso-db-secret
                  key: POSTGRES_PASSWORD
            - name: POSTGRESQL_DATABASE
              valueFrom:
                secretKeyRef:
                  name: rh-sso-db-secret
                  key: POSTGRES_DATABASE
          ports:
            - containerPort: 5432
              protocol: TCP
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - name: rh-sso-postgresql-claim
              mountPath: /var/lib/pgsql/data
          terminationMessagePolicy: File
          image: 'registry.redhat.io/rhel8/postgresql-10:1'
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
  strategy:
    type: Recreate
  revisionHistoryLimit: 10
  progressDeadlineSeconds: 600
```

### StatefulSets - RH SSO

```yaml
---
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: rh-sso
  namespace: rh-sso-demo
  labels:
    app: rh-sso
    component: rh-sso
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rh-sso
      component: rh-sso
  template:
    metadata:
      name: rh-sso
      namespace: rh-sso-demo
      creationTimestamp: null
      labels:
        app: rh-sso
        component: rh-sso
    spec:
      restartPolicy: Always
      initContainers:
        - name: extensions-init
          image: >-
            registry.redhat.io/rh-sso-7-tech-preview/sso74-init-container-rhel8:7.4
          env:
            - name: KEYCLOAK_EXTENSIONS
          resources: {}
          volumeMounts:
            - name: rh-sso-extensions
              mountPath: /opt/extensions
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: Always
      schedulerName: default-scheduler
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - rh-sso
                topologyKey: topology.kubernetes.io/zone
            - weight: 90
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - rh-sso
                topologyKey: kubernetes.io/hostname
      terminationGracePeriodSeconds: 30
      securityContext: {}
      containers:
        - terminationMessagePath: /dev/termination-log
          name: rh-sso
          env:
            - name: DB_SERVICE_PREFIX_MAPPING
              value: rh-sso-postgresql=DB
            - name: TX_DATABASE_PREFIX_MAPPING
              value: rh-sso-postgresql=DB
            - name: DB_JNDI
              value: 'java:jboss/datasources/KeycloakDS'
            - name: DB_SCHEMA
              value: public
            - name: DB_USERNAME
              valueFrom:
                secretKeyRef:
                  name: rh-sso-db-secret
                  key: POSTGRES_USERNAME
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: rh-sso-db-secret
                  key: POSTGRES_PASSWORD
            - name: DB_DATABASE
              valueFrom:
                secretKeyRef:
                  name: rh-sso-db-secret
                  key: POSTGRES_DATABASE
            - name: JGROUPS_PING_PROTOCOL
              value: dns.DNS_PING
            - name: OPENSHIFT_DNS_PING_SERVICE_NAME
              value: rh-sso-discovery.rh-sso-demo.svc.cluster.local
            - name: CACHE_OWNERS_COUNT
              value: '2'
            - name: CACHE_OWNERS_AUTH_SESSIONS_COUNT
              value: '2'
            - name: SSO_ADMIN_USERNAME
              valueFrom:
                secretKeyRef:
                  name: credential-rh-sso
                  key: ADMIN_USERNAME
            - name: SSO_ADMIN_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: credential-rh-sso
                  key: ADMIN_PASSWORD
            - name: X509_CA_BUNDLE
              value: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            - name: STATISTICS_ENABLED
              value: 'TRUE'
          ports:
            - containerPort: 8443
              protocol: TCP
            - containerPort: 8080
              protocol: TCP
            - containerPort: 9990
              protocol: TCP
            - containerPort: 8778
              protocol: TCP
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - name: rh-sso-x509-https-secret
              mountPath: /etc/x509/https
            - name: rh-sso-extensions
              mountPath: /opt/eap/standalone/deployments
            - name: rh-sso-probes
              mountPath: /probes
          terminationMessagePolicy: File
          image: 'registry.redhat.io/rh-sso-7/sso74-openshift-rhel8:7.4'
      volumes:
        - name: rh-sso-x509-https-secret
          secret:
            secretName: rh-sso-x509-https-secret
            defaultMode: 420
            optional: true
        - name: rh-sso-extensions
          emptyDir: {}
        - name: rh-sso-probes
          configMap:
            name: rh-sso-probes
            defaultMode: 365
      dnsPolicy: ClusterFirst
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0
  revisionHistoryLimit: 10
```

