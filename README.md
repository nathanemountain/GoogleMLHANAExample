---
title: HANA TensorFlow Example
description: This application shows how to use TensorFlow with HANA.
---
## Prerequisites
 - A `HANA, express edition` database server must be running and accessible.
 - Familiarity with the Python language.

### Time to Complete
**25 Min**

## Prepare Your Environment

1. Create a directory called HanaTensorFlow.

2. Navigate to the newly created directory, HanaTensorFlow.

3. If you do not have *virtualenv* installed, execute the following command:

`pip install virtualenv`

4. Clone the [HANATensorFlowExample git repository](https://github.wdf.sap.corp/I825357/HANATensorFlowExample) or download and extract the zip file.

5. Run the following commands to create and activate your virtual environment and install the tensorflow required packages.

`virtualenv env`

`source env/bin/activate`

Note : If you are running Windows : it would be `source env/Scripts/activate`

`pip install tensorflow`

`pip install pyhdb`

`pip install pandas`

## Load Training and Testing Data

There are two files to import into your HANA database. 

 - tensordata.csv: This file contains the tensorflow training data to train the model.
 - tensortestdata.csv: This contains the testdata to exercise the model.
 
Here are three different options for loading the data. Option 1 is for loading data from the client. Option 2a and 2b require that you have ftp or scp access to the HANA database server.

Option 1: Follow this [Tutorial to Import CSV File into SAP HANA](https://archive.sap.com/documents/docs/DOC-27960) if you want to install the data to the server using [HANA Studio Plugin for Eclipse](https://tools.hana.ondemand.com/#hanatools).

Option 2: FTP the data to the HANA server and then use either option 2a or option 2b to load it into the database.

- Create a data directory on the HANA server. 
- Upload the following files to this directory:
-- load_data.sh
-- tensordata.csv
-- tensortestdata.csv
-- tensordata.sql

- Make sure you are logged in as a user with rights to execute the hdbsql utility. You can use the sid adm user. On the HANA Express database, this is the user `hxeadm`.

Option 2a: Load the data using the load_data.sh script.

- Navigate to the data directory created above. 
- Make the load_data.sh file executable: chmod a+x load_data.sh.
- Run the load_data.sh script using the instructions explained in the load_data.sh help: "load_data.sh -h".

Option 2b: Load the data on the server using HANA's command line `hdbsql` utility. 

- Navigate to the data directory created above. 
- Read the instructions in the tensordata.sql file to see what values to change. Make the changes and save.
- Run the hdbsql utility and point to the tensordata.sql file.
--  hdbsql -u <Your User> -d <YourDatabase> -p <YourPassword> -i <YourInstance> -I tensordata.sql

## Edit the Python File

1. Make the following edits to the `readDataFromSAPHana` function of the *wide_n_deep_tutorial.py* file.

  - Replace the YOUR_HXE_HOST_NAME, USER_ID, USER_PASSWORD with your values.
  - Replace the YOUR_SCHEMA with your values.
  - If you are not using a multi-tenant HANA Database with instance number 90, you will also need to change your port.


```
def readDataFromSAPHana():
    connection = pyhdb.connect(
          # replace with the ip address of your HXE Host (This may be a virtual machine)
          host='<YOUR_HXE_HOST_NAME>',
          # 39013 is the systemDB port for HXE on the default instance of 90.
          # Replace 90 with your instance number as needed (e.g. 30013 for instance 00)
          port=39013,
          #Replace user and password with your user and password.
          user='<USER_ID>',
          password='<USER_PASSWORD'>
          )
    if not connection.isconnected():
        return 'HANA Server not accessible'
    #Connect to the database

    cursor = connection.cursor()
    #This is the data used to Train the Tensor Flow model
    cursor.execute("SELECT * FROM <YOUR_SCHEMA>.TENSORDATA")
    myData = cursor.fetchall()
    trainData = pd.DataFrame(myData)
    trainData.columns = COLUMNS
    cursor.close()

    #This is the data used to Test the Tensor Flow model
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM <YOUR_SCHEMA>.TENSORTESTDATA")
    myData = cursor.fetchall()
    testData = pd.DataFrame(myData)
    testData.columns = COLUMNS

    # print (xx)
    #Close the cursor
    cursor.close()
    return (trainData, testData)

```
## Execute the ML Computation

1. Run the following command:

`python wide_n_deep_tutorial.py --model_type=wide`

2. The application has inserted results back into the database table named as `TENSORFLOWRESULT`.

## Deploy as a Flask Application

1. Navigate into *flaskTFResults* folder and locate the *main.py* file. Make the following edits to the `readDataFromSAPHana` and `getConnection` function of the *main.py* file.

  - Replace the YOUR_HXE_HOST_NAME, USER_ID, USER_PASSWORD with your values.
  - Replace the YOUR_SCHEMA with your values.
  - If you are not using a multi-tenant HANA Database with instance number 90, you will also need to change your port.

```
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

```

2. This app can then be deployed on Google Cloud App Engine. Follow this [tutorial](https://cloud.google.com/appengine/docs/standard/python/quickstart).
