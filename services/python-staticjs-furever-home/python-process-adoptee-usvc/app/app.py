import io
import logging
import os
import sys
import mysql.connector
from kafka import KafkaConsumer
from json import loads

##############################################################################
# Set Variables and Global References
##############################################################################
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

# Delay between Adoptee submissions
CYCLE_SECONDS = os.getenv('CYCLE_SECONDS', 30)
SECONDS_WAIT = float(CYCLE_SECONDS)

# Helper database
DB_USER = os.getenv('DB_USER', 'petadoption')
DB_PASS = os.getenv('DB_PASS', 'petadoptionP455')
DB_HOST = os.getenv('database-host', 'petadoption-db')
DB_DB = os.getenv('DB_HOST', 'petadoption')

# Kafka Info
KAFKA_CLUSTER_ENDPOINT = os.getenv('KAFKA_CLUSTER_ENDPOINT', 'pet-cluster-kafka-bootstrap:9092')
KAFKA_TOPIC = os.getenv('KAFKA_TOPIC', 'new-adoptees')
KAFKA_GROUP_ID = os.getenv('KAFKA_GROUP_ID', 'process-pet-group')

# Kafka Consumer
consumer = KafkaConsumer(
    KAFKA_TOPIC,
    bootstrap_servers=[KAFKA_CLUSTER_ENDPOINT],
    auto_offset_reset='earliest',
    enable_auto_commit=True,
    group_id=KAFKA_GROUP_ID,
    value_deserializer=lambda x: loads(x.decode('utf-8')))

##############################################################################
## Functions
##############################################################################
def insertIntoDatabase(petInfo):
    """Takes data read from a Kafka topic and inserts it into a database"""
    pType = petInfo['petType']
    pName = petInfo['bio']['name']
    pImageURL = petInfo['image_root'] + petInfo['bio']['photo']
    pCity = petInfo['location']['city']
    pLocale = petInfo['location']['locale']

    try:
        cnx = mysql.connector.connect(user=DB_USER, password=DB_PASS, host=DB_HOST, database=DB_DB)
        cursor = cnx.cursor()

        query = "INSERT INTO pet_adoptees(type, name, image_url, city, locale) VALUES (%s, %s, %s, %s, %s);"
        values = (pType, pName, pImageURL, pCity, pLocale)
        cursor.execute(query, values)
        cnx.commit()
        cursor.close()
        cnx.close()

    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        raise

##############################################################################
## Main loop
##############################################################################
while SECONDS_WAIT != 0: #This allows the container to keep running but not send any pet if parameter is set to 0
    for msg in consumer:
        print("consuming: ")
        print(msg)
        record = msg.value['Records'][0]
        insertIntoDatabase(record['petInfo'])

    sleep(SECONDS_WAIT)

# Dirty hack to keep container running even when no pets are to be submitted for adoption
os.system("tail -f /dev/null")