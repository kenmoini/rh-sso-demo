# Add Adoptee Service

This service simply connects to a Kafka topic and submits a new cat or dog to adopt, which is then picked up by other services.

## About

This service takes a set of data sets as a seed and then generates a random pet.

Dogs/Cats > Name and Photo pairing

Age is randomly generated.

## Deployment - Manual

```bash
cd app

pip3 install -r requirements.txt

export DATA_SET_PATH="./data-sets.json"
export KAFKA_CLUSTER_ENDPOINT="pet-cluster-kafka-bootstrap:9092"
export KAFKA_TOPIC="new-adoptees"

python3 app.py
```

## Deployment - OpenShift

1. Deploy a Kafka Cluster and Topic - Red Hat AMQ Streams Operator needs to already be installed

```bash
export OC_NAMESPACE="furever-home"
oc new-project ${OC_NAMESPACE}

oc apply -n ${OC_NAMESPACE} -f openshift/kafka-instance/

## Wait like, 30 seconds or so for the cluster to come up

oc apply -n ${OC_NAMESPACE} -f openshift/kafka-topic/
```

2. Deploy the Microservice

```bash
oc apply -n ${OC_NAMESPACE} -f openshift/add-adoptee-usvc/
```