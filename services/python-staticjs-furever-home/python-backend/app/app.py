import sys
import logging
import os
import mysql.connector
from flask import request, jsonify, Flask
from flask_restful import Resource, Api, reqparse

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
DB_HOST = os.getenv('database-host', 'petadoption-db')
DB_DB = os.getenv('DB_HOST', 'petadoption')

# Replace with an actual query of the JWT User ID
USER_ID=1

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
        return {'pets': json.dumps(pets, indent=4, sort_keys=True, default=str)}, 200  # return data and 200 OK code

class Pet(Resource):
    def get(self):
        query_parameters = request.args
        petID = query_parameters.get('id')
        mydb = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_DB)
        mycursor = mydb.cursor()
        mycursor.execute("SELECT * FROM pet_adoptees")

        pets = []
        myresult = mycursor.fetchall()
        for x in myresult:
          pets.append(myresult)
        return {'pet': json.dumps(pets, indent=4, sort_keys=True, default=str)}, 200  # return data and 200 OK code

class Submissions(Resource):
    def get(self):
        query = "SELECT * FROM adoption_submissions WHERE"
        to_filter = []

        if USER_ID:
            query += ' user_id=? AND'
            to_filter.append(USER_ID)
        if not (USER_ID):
            return page_not_found(404)

        query = query[:-4] + ';'

        mydb = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASS, database=DB_DB)
        mycursor = mydb.cursor()
        mycursor.execute(query, to_filter)

        pets = []
        myresult = mycursor.fetchall()
        for x in myresult:
          pets.append(myresult)
        return {'submissions': json.dumps(pets, indent=4, sort_keys=True, default=str)}, 200  # return data and 200 OK code


api.add_resource(Pets, '/pets')
api.add_resource(Pet, '/pet')
api.add_resource(Submissions, '/submissions')

##############################################################################
## Main loop
##############################################################################
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=API_PORT)