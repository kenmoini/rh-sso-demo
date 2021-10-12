import json
import sys
import random
import os
import logging
from time import sleep
from kafka import KafkaProducer

##############################################################################
# Set Variables and Global References
##############################################################################
DATA_SET_PATH = os.getenv('DATA_SET_PATH', './data-sets.json')
CYCLE_SECONDS = os.getenv('CYCLE_SECONDS', 30)
KAFKA_CLUSTER_ENDPOINT = os.getenv('KAFKA_CLUSTER_ENDPOINT', 'pet-cluster-kafka-bootstrap:9092')
KAFKA_TOPIC = os.getenv('KAFKA_TOPIC', 'new-adoptees')

# Delay between Adoptee submissions
SECONDS_WAIT = float(CYCLE_SECONDS)

# Logging
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

# Kakfa Producer
producer = KafkaProducer(bootstrap_servers=KAFKA_CLUSTER_ENDPOINT, value_serializer=lambda v: json.dumps(v).encode('utf-8'))

##############################################################################
## Functions
##############################################################################
def send_event(petInfo, kafkaTopic):
    """Sends an SMS event to the Kafka broker"""
    
    record = {'eventName': 'fureverHome:newAdoptee', 'petInfo': petInfo}
    logging.info("sending %s"% record)
    
    producer.send(kafkaTopic, {'Records': [record]})

def select_data(DATA_SET_PATH):
    """Selects a random set of data from the supplied data set JSON file"""

    f = open(DATA_SET_PATH,"r")
    data = json.loads(f.read())
    f.close()

    # Set Random Pet
    petTypeRoll = random.randrange(0, 2, 1)
    if petTypeRoll:
        petType = "dogs"
    else:
        petType = "cats"

    petSetLength = len(data[petType])
    petItemRoll = random.randrange(0, petSetLength, 1)
    petItem = data[petType][petItemRoll]

    # Set Random Location
    locationsSetLength = len(data['locations'])
    locationItemRoll = random.randrange(0, locationsSetLength, 1)
    locationItem = data['locations'][locationItemRoll]

    # Pull other data
    imageSourceRoot = data['file_root']

    # Assemble new JSON array
    return {'petType': petType[:-1], 'image_root': imageSourceRoot, 'bio': petItem, 'location': locationItem}

##############################################################################
## Main loop
##############################################################################
while SECONDS_WAIT != 0: #This allows the container to keep running but not send any pet if parameter is set to 0
    logging.info("submitting new pet for adoption")
    newPetAdoptee = select_data(DATA_SET_PATH)
    send_event(newPetAdoptee, KAFKA_TOPIC)
    sleep(SECONDS_WAIT)

# Dirty hack to keep container running even when no pets are to be submitted for adoption
os.system("tail -f /dev/null")