--This script can be executed using the hdbsql command line with the following syntax
--hdbsql -u <Your User> -d <YourDatabase> -p <YourPassword> -i <YourInstance> -I tensordata.sql


--Drop the schema and all its objects
DROP SCHEMA TENSORFLOW CASCADE;

--Create the schema. If you change the schema be sure to change it in the 
--Create table statements and the import statement and select count queries.
CREATE SCHEMA TENSORFLOW;
 
--Create the tensordata table. Change the schema if required
CREATE COLUMN TABLE "TENSORFLOW"."TENSORDATA" ("AGE" TINYINT CS_INT,
	 "WORKCLASS" NVARCHAR(30),
	 "FNLWGT" INTEGER CS_INT,
	 "EDUCATION" NVARCHAR(30),
	 "EDUCATION_NUM" TINYINT CS_INT,
	 "MARITAL_STATUS" NVARCHAR(30),
	 "OCCUPATION" NVARCHAR(30),
	 "RELATIONSHIP" NVARCHAR(30),
	 "RACE" NVARCHAR(30),
	 "GENDER" NVARCHAR(10),
	 "CAPITAL_GAIN" INTEGER CS_INT,
	 "CAPITAL_LOSS" SMALLINT CS_INT,
	 "HOURS_PER_WEEK" TINYINT CS_INT,
	 "NATIVE_COUNTRY" NVARCHAR(30),
	 "INCOME_BRACKET" NVARCHAR(7)) UNLOAD PRIORITY 5 AUTO MERGE;

--Create the tensortestdata table. Change the schema if required     
CREATE COLUMN TABLE "TENSORFLOW"."TENSORTESTDATA" ("AGE" TINYINT CS_INT,
	 "WORKCLASS" NVARCHAR(30),
	 "FNLWGT" INTEGER CS_INT,
	 "EDUCATION" NVARCHAR(30),
	 "EDUCATION_NUM" TINYINT CS_INT,
	 "MARITAL_STATUS" NVARCHAR(30),
	 "OCCUPATION" NVARCHAR(30),
	 "RELATIONSHIP" NVARCHAR(30),
	 "RACE" NVARCHAR(30),
	 "GENDER" NVARCHAR(10),
	 "CAPITAL_GAIN" INTEGER CS_INT,
	 "CAPITAL_LOSS" SMALLINT CS_INT,
	 "HOURS_PER_WEEK" TINYINT CS_INT,
	 "NATIVE_COUNTRY" NVARCHAR(30),
	 "INCOME_BRACKET" NVARCHAR(7)) UNLOAD PRIORITY 5 AUTO MERGE;

--Create the tensorresultdata table. Change the schema if required
CREATE COLUMN TABLE "TENSORFLOW"."TENSORFLOWRESULT" ("ID" TIMESTAMP PRIMARY KEY,
	"ACCURACY" NVARCHAR(4999),
     	"ACCURACY_BASELINE_LABEL_MEAN" NVARCHAR(4999),
     	"ACCURACY_THRESHOLD_MEAN" NVARCHAR(4999),
     	"AUC" NVARCHAR(4999),
     	"GLOBAL_STEP" NVARCHAR(4999),
     	"LABEL_ACTUAL_MEAN" NVARCHAR(4999),
     	"LABEL_PREDICTION_MEAN" NVARCHAR(4999),
     	"LOSS" NVARCHAR(4999),
     	"PRECISION" NVARCHAR(4999),
     	"RECALL" NVARCHAR(4999)) UNLOAD PRIORITY 5 AUTO MERGE;
 
--Change the file_path to the path where your files are located.
ALTER SYSTEM ALTER CONFIGURATION('nameserver.ini', 'SYSTEM') 
   SET ('import_export', 'csv_import_path_filter') = '/usr/sap/HXE/home/downloads/tensorflow/' 
   WITH RECONFIGURE;

--Change the file_path to the path where your files are located and update schema if required.
IMPORT FROM CSV FILE '/usr/sap/HXE/home/downloads/tensorflow/tensordata.csv' INTO "TENSORFLOW"."TENSORDATA"
   WITH RECORD DELIMITED BY '\n'
   FIELD DELIMITED BY ','
   SKIP FIRST 1 ROW
   ERROR LOG '/usr/sap/HXE/home/downloads/tensorflow/tensordata.err';
   
--Change the file_path to the path where your files are located and update schema if required.
IMPORT FROM CSV FILE '/usr/sap/HXE/home/downloads/tensorflow/tensortestdata.csv' INTO "TENSORFLOW"."TENSORTESTDATA"
   WITH RECORD DELIMITED BY '\n'
   FIELD DELIMITED BY ','
   SKIP FIRST 1 ROW
   ERROR LOG '/usr/sap/HXE/home/downloads/tensorflow/tensortestdata.err'; 

--Change the schema if required.   
SELECT count(*) AS ROWSLOADED from "TENSORFLOW"."TENSORDATA" 
 UNION
SELECT count(*) from "TENSORFLOW"."TENSORTESTDATA";
    