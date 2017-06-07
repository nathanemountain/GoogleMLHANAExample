# [START app]
import logging

# [START imports]
from flask import Flask, render_template, request
import pyhdb as db
# [END imports]

# [START create_app]
app = Flask(__name__)
# [END create_app]

# [START ODATA]
@app.route('/tensorResults')
def hello():
    results = getResultsFromHANA()
    return render_template('tfresults.html', results=results)

def getResultsFromHANA():
    productNames = readDataFromSAPHana()
    return productNames


def readDataFromSAPHana():
    connection = getConnection()

    if not connection.isconnected():
        return 'HANA Server not accessible'
    #Connect to the database

    cursor = connection.cursor()
    #This is the data used to Train the Tensor Flow model
    cursor.execute("SELECT * FROM <YOUR_SCHEMA>.TENSORFLOWRESULT")
    myData = cursor.fetchall()
    cursor.close()
    print(myData)
    return myData

def getConnection():
    myConnection = db.connect(
          # replace with the ip address of your HXE Host (This may be a virtual machine)
          host='<HXE_HOST>',
          # 39013 is the systemDB port for HXE on the default instance of 90.
          # Replace 90 with your instance number as needed (e.g. 30013 for instance 00)
          port=39015,
          #Replace user and password with your user and password.
          user='<USER_ID>',
          password='<PASSWORD>'
          )
    return myConnection

@app.errorhandler(500)
def server_error(e):
    # Log the error and stacktrace.
    logging.exception('An error occurred during a request.')
    return 'An internal error occurred.', 500
# [END app]

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=80)
