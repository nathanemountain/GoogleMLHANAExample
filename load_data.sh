#!/bin/bash
############################################################################################
# Print usage
############################################################################################
usage() {
cat <<-EOF


NAME
   $base_name

SYNOPSIS
   $base_name [options]

DESCRIPTION
   The $base_name utility creates the database objects needed in the HANATensorFlowExample. 
   
   This utility must be run by a user that is able to execute hdbsql commands and has hdbsql in the path. 

OPTIONS
  Generic Program Information
      -h, --help
             Print a usage message briefly summarizing these command-line options, then exit.  

  Connection Information  
      -u, --user
             Database technical user name. The user must have permission to alter the global.ini file and to read from system tables.
             The default value is "system".
   
      -p, --password
             Database technical user password. If the password is not entered on the command line, the user will be prompted to enter the password.
             There is no default value.
             
      -d, --database
             Tenant database technical user password. If the password is not entered on the command line, the user will be prompted to enter the password.
             The default value is "SystemDB".            

      -i, --instance 
             The instance number of the HANA database server. 
             The default value is "90".
 
  Reporting Options

      -f, --filepath
             The path where the tensordata.csv and tensortestdata.csv files can be found.
             The default value is "/usr/sap/HXE/home/downloads/tensorflow/".
             
      -s, --schema
             The schema in which the example tables will be created.
             The default value is "TENSORFLOW".

EXAMPLES
  Accept all the default values.
    $base_name -p myPassword

  Create the objects with the user "MYUSER", password "MYPASSWORD", database "MYDB", instance "00", and filepath "/tmp/myfiles/"
    $base_name -u MYUSER -p MYPASSWORD -d MYDB -i 00 -f /tmp/myfiles/
    
EOF
}

############################################################################################
# Non-HDB error handler
# Print the error that is passed in.
# arg1 - Error message that should be printed.
############################################################################################
handle_regular_error() {
  echo
  echo "ERROR" 
  echo "$1"
  echo
  exit 1
}

############################################################################################
# Validate the password. If the password is blank, prompt the user to enter the password.
#########################################################################################
function validatePassword {
   #prompt the user to enter the password if it is blank.
   if [ -z "$PASSWORD" ]; then
     read -s -p "Enter the user password: " PASSWORD
     printf "\n"
   fi
   #If the database password is still blank, fail the execution.
   if [ -z "$PASSWORD" ]; then
     errorMessage="Password cannot be left blank."
     handle_regular_error "$errorMessage"
   fi
}

############################################################################################
# Validate the filepath. 
# Return an error if it is invalid.
#########################################################################################
function validateFilePath {
  if [ ! -d ${FILE_PATH} ]; then
     errorMessage="The output directory ${FILE_PATH} is not a valid directory."
     handle_regular_error "$errorMessage"    
  fi

}

############################################################################################
# Execute the SQL Scripts
# Return an error if it is invalid.
#########################################################################################
function executeSQL {

    hdbsql -u $USER_NAME -p $PASSWORD -i $INSTANCE -d $DATABASE <<EOF

DROP SCHEMA ${SCHEMA} CASCADE;

CREATE SCHEMA ${SCHEMA};
 
CREATE COLUMN TABLE "${SCHEMA}"."TENSORDATA" ("AGE" TINYINT CS_INT,    "WORKCLASS" NVARCHAR(30),    "FNLWGT" INTEGER CS_INT,    "EDUCATION" NVARCHAR(30),    "EDUCATION_NUM" TINYINT CS_INT,    "MARITAL_STATUS" NVARCHAR(30),    "OCCUPATION" NVARCHAR(30),    "RELATIONSHIP" NVARCHAR(30),    "RACE" NVARCHAR(30),    "GENDER" NVARCHAR(10),    "CAPITAL_GAIN" INTEGER CS_INT,    "CAPITAL_LOSS" SMALLINT CS_INT,    "HOURS_PER_WEEK" TINYINT CS_INT,    "NATIVE_COUNTRY" NVARCHAR(30),    "INCOME_BRACKET" NVARCHAR(7)) UNLOAD PRIORITY 5 AUTO MERGE; 

CREATE COLUMN TABLE "${SCHEMA}"."TENSORTESTDATA" ("AGE" TINYINT CS_INT,    "WORKCLASS" NVARCHAR(30),    "FNLWGT" INTEGER CS_INT,    "EDUCATION" NVARCHAR(30),    "EDUCATION_NUM" TINYINT CS_INT,    "MARITAL_STATUS" NVARCHAR(30),    "OCCUPATION" NVARCHAR(30),    "RELATIONSHIP" NVARCHAR(30),    "RACE" NVARCHAR(30),    "GENDER" NVARCHAR(10),    "CAPITAL_GAIN" INTEGER CS_INT,    "CAPITAL_LOSS" SMALLINT CS_INT,    "HOURS_PER_WEEK" TINYINT CS_INT,    "NATIVE_COUNTRY" NVARCHAR(30),    "INCOME_BRACKET" NVARCHAR(7)) UNLOAD PRIORITY 5 AUTO MERGE;

CREATE COLUMN TABLE "${SCHEMA}"."TENSORFLOWRESULT" ("ID" TIMESTAMP PRIMARY KEY, "ACCURACY" NVARCHAR(4999), "ACCURACY_BASELINE_LABEL_MEAN" NVARCHAR(4999), "ACCURACY_THRESHOLD_MEAN" NVARCHAR(4999), "AUC" NVARCHAR(4999), "GLOBAL_STEP" NVARCHAR(4999), "LABEL_ACTUAL_MEAN" NVARCHAR(4999), "LABEL_PREDICTION_MEAN" NVARCHAR(4999), "LOSS" NVARCHAR(4999), "PRECISION" NVARCHAR(4999), "RECALL" NVARCHAR(4999)) UNLOAD PRIORITY 5 AUTO MERGE;

ALTER SYSTEM ALTER CONFIGURATION('nameserver.ini', 'SYSTEM') SET ('import_export', 'csv_import_path_filter') = '${FILE_PATH}' WITH RECONFIGURE;

IMPORT FROM CSV FILE '${FILE_PATH}tensordata.csv' INTO "${SCHEMA}"."TENSORDATA" WITH RECORD DELIMITED BY '\n' FIELD DELIMITED BY ',' SKIP FIRST 1 ROW ERROR LOG '${FILE_PATH}tensordata.err'; 

IMPORT FROM CSV FILE '${FILE_PATH}tensortestdata.csv' INTO "${SCHEMA}"."TENSORTESTDATA" WITH RECORD DELIMITED BY '\n' FIELD DELIMITED BY ',' SKIP FIRST 1 ROW ERROR LOG '${FILE_PATH}tensortestdata.err';

EOF
  
  echo 
  echo "Finished executing sql commands."
  echo 
  echo
  echo "You can execute the following command against the database to verify that your data was loaded: "
  echo
  echo "SELECT count(*) AS ROWSLOADED from "TENSORFLOW"."TENSORDATA"" 
  echo "UNION"
  echo "SELECT count(*) from "TENSORFLOW"."TENSORTESTDATA";"
  echo
  echo
}
############################################################################################
# Main
#########################################################################################
# Get the base_name of this script
base_name=`basename $0`
#
# Parse command line arguments
#
#Default values
USER_NAME="SYSTEM"
PASSWORD=""
INSTANCE="90"
DATABASE="SystemDB"
FILE_PATH="/usr/sap/HXE/home/downloads/tensorflow/"
SCHEMA="TENSORFLOW"

#Error file used to capture errors
TMP_ERROR_FILE="/tmp/out.$$"

if [ $# -eq 0 ]; then
   usage
   exit 1
fi 

if [ $# -gt 0 ]; then
  PARSED_OPTIONS=`getopt -n "$base_name" -a -o hu:p:d:i:f:s: --long help,user:,password:,database:,instance:,filepath:,schema: -- "$@"`
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # Something has gone wrong with the getopt command
  if [ "$#" -eq 0 ]; then
    usage
    exit 1
  fi

  # Process command line arguments
  eval set -- "$PARSED_OPTIONS"
  while true
  do
    case "$1" in
    -h|--help)
      usage
      exit 0
      break;;
    -u|--user)
      USER_NAME="$2"
      shift 2;;
    -p|--password)
      PASSWORD="$2"
      shift 2;;      
    -d|--database)
      DATABASE="$2"
      shift 2;;      
    -i|--instance)
      INSTANCE="$2"
      shift 2;;
    -f|--filepath)
      FILE_PATH="$2"
      shift 2;;
    -s|--schema)
      SCHEMA="$2"
      shift 2;;      
    --)
      shift
      break;;
    *)
      echo "Invalid \"$1\" argument."
      usage
      exit 1
    esac
  done
fi

validatePassword
validateFilePath

executeSQL

echo "Script has completed."

