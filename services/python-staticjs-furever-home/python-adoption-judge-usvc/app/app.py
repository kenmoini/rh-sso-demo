import sys
import logging
import os
import json
import random
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

##############################################################################
## Functions
##############################################################################

class Adopt(Resource):
    def post(self):

        # Set Random Pet Adoption Decision
        petTypeRoll = random.randrange(0, 2, 1)
        if petTypeRoll:
            decision = "approved"
        else:
            decision = "denied"
        
        parser = reqparse.RequestParser()  # initialize
        
        parser.add_argument('user_id', required=True)  # add args
        parser.add_argument('pet_id', required=True)
        
        args = parser.parse_args()  # parse arguments to dictionary


        try:
            cnx = mysql.connector.connect(user=DB_USER, password=DB_PASS, host=DB_HOST, database=DB_DB)

            cursor = cnx.cursor()
            query = "INSERT INTO adoption_submissions(user_id, pet_adoptee_id, status, updated_at, pet_name, pet_city, pet_locale) VALUES (%s, %s, %s, current_timestamp());"
            values = (args['user_id'], args['pet_id'], decision)
            cursor.execute(query, values)
            cnx.commit()
            cursor.close()
            
            if (decision == "approved"):
                cursor = cnx.cursor()
                query = "UPDATE pet_adoptees SET adopted_at = current_timestamp(), adopted_by = '%s' WHERE id = %s;"
                values = (args['user_id'], args['pet_id'])
                cursor.execute(query, values)
                cnx.commit()
                cursor.close()
            
            cnx.close()

            response = jsonify(status="success")

            response.headers.add("Access-Control-Allow-Origin", "*")
            response.status_code = 200
            #return response, 200
            return make_response(response)

        except Exception as e:
            logging.error(f"Unexpected error: {e}")
            response = jsonify(status="failed")

            # Enable Access-Control-Allow-Origin
            response.headers.add("Access-Control-Allow-Origin", "*")
            response.status_code = 500
            return response


        response = jsonify(pets=json.dumps(pets, sort_keys=True, default=str))

        # Enable Access-Control-Allow-Origin
        response.headers.add("Access-Control-Allow-Origin", "*")
        return response

api.add_resource(Adopt, '/adopt')

##############################################################################
## Main loop
##############################################################################
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=API_PORT)