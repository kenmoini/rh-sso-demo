import sys
import logging
import os
import json
import mysql.connector
from flask import request, jsonify, Flask, make_response
from flask_restful import Resource, Api, reqparse
from flask_cors import CORS

##############################################################################
# Set Variables and Global References
##############################################################################
# Logging
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

# Flask
app = Flask(__name__)
api = Api(app)
API_PORT = os.getenv('API_PORT', '8080')

# MySQL
DB_USER = os.getenv('DB_USER', 'petadoption')
DB_PASS = os.getenv('DB_PASS', 'petadoptionP455')
DB_HOST = os.getenv('DB_HOST', 'petadoption-db')
DB_DB = os.getenv('DB_DB', 'petadoption')

# Replace with an actual query of the JWT User ID
USER_ID=1

##############################################################################
## Functions
##############################################################################

class Pets(Resource):
    def get(self):
        mydb = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_DB)
        mycursor = mydb.cursor()
        mycursor.execute("SELECT * FROM pet_adoptees WHERE adopted_at IS NULL LIMIT 50")

        pets = []
        myresult = mycursor.fetchall()
        for x in myresult:
            pets.append(myresult)

        response = jsonify(pets=json.dumps(pets, sort_keys=True, default=str))

        # Enable Access-Control-Allow-Origin
        response.headers.add("Access-Control-Allow-Origin", "*")
        return response

class Pet(Resource):
    def get(self):
        query_parameters = request.args
        petID = query_parameters.get('id')
        mydb = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_DB)
        mycursor = mydb.cursor()
        mycursor.execute("SELECT * FROM pet_adoptees LIMIT 50")

        pets = []
        myresult = mycursor.fetchall()
        for x in myresult:
            pets.append(myresult)

        response = jsonify(pets=json.dumps(pets, sort_keys=True, default=str))

        # Enable Access-Control-Allow-Origin
        response.headers.add("Access-Control-Allow-Origin", "*")
        return response

class Submissions(Resource):
    def get(self):

        pets = []
        query_parameters = request.args
        userID = query_parameters.get('user_id')

        if (userID != None):
            mydb = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_DB)
            mycursor = mydb.cursor()
            mycursor.execute("SELECT * FROM adoption_submissions WHERE user_id='"+str(userID)+"' LIMIT 50")

            myresult = mycursor.fetchall()
            for x in myresult:
                pets.append(myresult)

        response = jsonify(submissions=json.dumps(pets, sort_keys=True, default=str))

        # Enable Access-Control-Allow-Origin
        response.headers.add("Access-Control-Allow-Origin", "*")
        return response


api.add_resource(Pets, '/pets')
api.add_resource(Pet, '/pet')
api.add_resource(Submissions, '/submissions')

##############################################################################
## Main loop
##############################################################################
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=API_PORT)