import sys
import logging
import os
import mysql.connector
from flask import Flask
from flask_restful import Resource, Api, reqparse

##############################################################################
# Set Variables and Global References
##############################################################################
# Logging
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

# Flask
app = Flask(__name__)
api = Api(app)

# MySQL
DB_USER = os.getenv('DB_USER', 'petadoption')
DB_PASS = os.getenv('DB_PASS', 'petadoptionP455')
DB_HOST = os.getenv('database-host', 'petadoption-db')
DB_DB = os.getenv('DB_HOST', 'petadoption')

##############################################################################
## Functions
##############################################################################

class Pets(Resource):
    def get(self):
        mydb = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_DB)
        mycursor = mydb.cursor()
        mycursor.execute("SELECT * FROM pet_adoptees")

        pets = []
        myresult = mycursor.fetchall()
        for x in myresult:
          pets.append(myresult)
        return {'pets': pets}, 200  # return data and 200 OK code

class Pet(Resource):
    def get(self):
        mydb = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_DB)
        mycursor = mydb.cursor()
        mycursor.execute("SELECT * FROM pet_adoptees")

        pets = []
        myresult = mycursor.fetchall()
        for x in myresult:
          pets.append(myresult)
        return {'pets': pets}, 200  # return data and 200 OK code


api.add_resource(Pets, '/pets')
api.add_resource(Pet, '/pet')

##############################################################################
## Main loop
##############################################################################
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)