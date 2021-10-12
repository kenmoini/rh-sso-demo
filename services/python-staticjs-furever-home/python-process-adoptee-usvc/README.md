# Process Adoptee Service

This service simply connects to a Kafka topic and consumes a new cat or dog to adopt, which is then processed into a database.

## About

This service takes information off a Kafka topic and then submits it to a database.

## Deployment - Manual

```bash
cd app

pip3 install -r requirements.txt

export KAFKA_CLUSTER_ENDPOINT="pet-cluster-kafka-bootstrap:9092"
export KAFKA_TOPIC="new-adoptees"

python3 app.py
```

## Deployment - OpenShift

1. Deploy a Kafka Cluster and Topic - Red Hat AMQ Streams Operator needs to already be installed

```bash
# The same namespace as your other furever-home services 
export OC_NAMESPACE="furever-home"
oc new-project ${OC_NAMESPACE}

# Deploy database
oc apply -n ${OC_NAMESPACE} -f openshift/database/

## Wait like, 30 seconds or so for the database to come up
# Configure the database
oc apply -n ${OC_NAMESPACE} -f openshift/database-config/
```

2. Deploy the Microservice

```bash
oc apply -n ${OC_NAMESPACE} -f openshift/process-adoptee-usvc/
```