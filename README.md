---
title: HANA TensorFlow Example
description: This application shows how to use TensorFlow with HANA.
---
## Prerequisites
 - A `HANA, express edition` database server must be set up, running and accessible on the Google Cloud Platform. Instructions on how to set up HANA, express edition on the Google Cloud Platform can be found [here](https://ideas.sap.com/ct/d.bix?c=A0DDEEB6-D896-4150-AF25-C755FCAF4E1C)
 - Familiarity with the Python language. Should we also state that Python, TensorFlow, and any other tools should be installed?

### Time to Complete
**25 Min**

## Prepare Your Environment

1. Open the Google Cloud Platform (GCP) in a browser. From the home page, look for the Resources tile, and click Compute Engine. 

2. Locate the HANA, express edition (HXE) database you wish to work on. Select it by clicking in the box and then click start to begin running the instance. A pop up window will appear stating "You will be billed for this instance while it is running. Are you sure you want to start instance "sap-hanaexpress-public-1-vm"? This counts toward the $300 free trail, remember to stop the instance when not using it. 

3. Click on the SSH drop down menu and select "open in browser window". You can use any SSH client you would like, but for the purposes of this tutorial it is assumed that the browser option selected.  

4. Log in as hxeadm. 

5. From the SSH browser client, create a directory called HanaTensorFlow. Command line `mkdir HanaTensorFlow`. Confirm file path.

6. Navigate to the newly created directory, HanaTensorFlow.

7. Clone this repository: 
`you run git <URL with github link>`

8. Run the following commands to create and activate your virtual environment and install the tensorflow required packages:
`virtualenv env`
`source env/bin/activate`

9. Execute the following commands to install TensorFlow, Python and Pandas:

`pip install tensorflow`

`pip install pyhdb`

`pip install pandas`

## Load Training and Testing Data
There are two files to import into your HANA database.
- tensordata.csv: This file contains the tensorflow training data to train the model.
- tensortestdata.csv: This contains the testdata to exercise the model.

Load the data on the server using HANA's command line `hdbsql` utility. 

- Navigate to the data directory created above. 
- Read the instructions in the tensordata.sql file to see what values to change. Make the changes and save.
- Run the hdbsql utility and point to the tensordata.sql file.
--  hdbsql -u <Your User> -d <YourDatabase> -p <YourPassword> -i <YourInstance> -I tensordata.sql

## Edit the Config File

1. Open the `params.config` file.  It has been filled in with default values for a HANA Express System Database. 

  `HOSTNAME=hxehost`

  `PORT=39013`

  `USER=system`

  `PASSWORD=MyPassword`

  `TENSOR_SCHEMA=TENSORFLOW`

  `TENSOR_TRAINING_DATA_TABLE=TENSORDATA`

  `TENSOR_TEST_DATA_TABLE=TENSORTESTDATA`

  `TENSOR_RESULT_TABLE=TENSORFLOWRESULT`


- Replace the `HOSTNAME, PORT, USER, PASSWORD` with your values for where the Hana Express is deployed.

- Replace the `TENSOR_SCHEMA, TENSOR_TRAINING_DATA_TABLE, TENSOR_TEST_DATA_TABLE, TENSOR_RESULT_TABLE` with the values you gave in the previous steps.

- Note: The System Database port is 3`<instance_number>`13 and Tenant Database port is 3`<instance_number>`15.


## Execute the Application

1. Run the following command:

`python wide_n_deep_tutorial.py --model_type=wide`

2. When the application executes successfully it inserts the results into the database table provided in the config file.

## Deploy a Flask Application to view results.

1. Navigate into *flaskTFResults* folder.

2. This app can then be deployed on Google Cloud App Engine. Follow this [tutorial](https://cloud.google.com/appengine/docs/standard/python/quickstart).
