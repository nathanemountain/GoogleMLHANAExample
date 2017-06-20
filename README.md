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

4. Clone this repository or download and extract the zip file.

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

Option 1: Follow this [Tutorial to Import CSV File into SAP HANA](https://archive.sap.com/documents/docs/DOC-27960) if you want to install the data to the server using [HANA Studio Plugin for Eclipse](https://tools.hana.ondemand.com/#hanatools). Alternatively, you can watch the following [SAP HANA Academy tutorial](https://www.youtube.com/watch?v=4B55DrzFyIM) for instructions on loading from a csv file.

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

## Edit the Config File

1. Open the `params.config` file.  It should look like below.

  `HOSTNAME=<YOUR_HOSTNAME>`

  `PORT=<YOUR_PORT>`

  `USER=<YOUR_USER>`

  `PASSWORD=<YOUR_PASSWORD>`

  `TENSOR_SCHEMA=<YOUR_SCHEMA>`

  `TENSOR_TRAINING_DATA_TABLE=<YOUR_TENSOR_TRAINING_DATA_TABLE>`

  `TENSOR_TEST_DATA_TABLE=<YOUR_TENSOR_TEST_DATA_TABLE>`

  `TENSOR_RESULT_TABLE=<YOUR_TENSOR_RESULT_TABLE>`


- Replace the `YOUR_HOST_NAME, YOUR_PORT, YOUR_USER, YOUR_PASSWORD` with your values for where the Hana Express is deployed.

- Replace the `YOUR_SCHEMA, YOUR_TENSOR_TRAINING_DATA_TABLE, YOUR_TENSOR_TEST_DATA_TABLE, YOUR_TENSOR_RESULT_TABLE` with the values you gave in the previous steps.

- Note: The System Database port is 3`<instance_number>`13 and Tenant Database port is 3`<instance_number>`15.


## Execute the Application

1. Run the following command:

`python wide_n_deep_tutorial.py --model_type=wide`

2. When the application executes successfully it inserts the results into the database table provided in the config file.

## Deploy a Flask Application to view results.

1. Navigate into *flaskTFResults* folder.

2. This app can then be deployed on Google Cloud App Engine. Follow this [tutorial](https://cloud.google.com/appengine/docs/standard/python/quickstart).
