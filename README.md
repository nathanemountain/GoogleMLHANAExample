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

1. Import the following csv files from your cloned source directory to your HANA database:

 - tensordata.csv
 - tensortestdata.csv

  Note : [Tutorial to Import CSV File into SAP HANA](https://archive.sap.com/documents/docs/DOC-27960)
  
  If you have ftp or scp access to your HANA database server and can copy the source files over to the server, you can execute the load_data.sh script from the shell on the HANA server. Alternatively, you can execute the tensordata.sql sql script using the command line hdbsql utility.

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
## Execute the Application

1. Run the following command:

`python wide_n_deep_tutorial.py --model_type=wide`

2. The application has inserted results back into the database table named as `TENSORFLOWRESULT`.

3. Expose the data collected from the application as Odata Service using [this tutorial](https://www.sap.com/developer/tutorials/xsa-xsodata.html)
