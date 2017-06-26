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
   The $base_name utility creates the database schema and tables needed in the GoogleMLHANAExample and loads the data. 
   
   For this utility to work correctly the following must be true:
   
     - The user running this utility is able to execute hdbsql commands and has hdbsql in the path (e.g. hxeadm user on HANA Express).
     - This utility is located in the same directory as the training and test data files and the params.config file.

OPTIONS
  Generic Program Information
      -h, --help
             Print a usage message briefly summarizing the usage of this utility.

    
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
# Read the parameter file. 
# Return an error if it is invalid.
#########################################################################################
function readParamFile {
  # Check if the file exists
  if [ ! -f ${PARAM_FILE} ]; then
     errorMessage="The parameter file, ${PARAM_FILE}, was not found."
     handle_regular_error "$errorMessage"    
  fi

  #Read the parameters into environment variables of the same name
  while IFS='=' read -r key value
  do
    eval "${key}='${value}'"
  done < "${PARAM_FILE}"

}

############################################################################################
# Execute the SQL Scripts
# Return an error if it is invalid.
#########################################################################################
function executeSQL {
    
    echo Connecting on ${HOSTNAME}:${PORT} as ${USER}...
    echo
    hdbsql -u ${USER} -p ${PASSWORD} -n ${HOSTNAME}:${PORT} <<EOF

DROP SCHEMA ${TENSOR_SCHEMA} CASCADE;

CREATE SCHEMA ${TENSOR_SCHEMA};
 
CREATE COLUMN TABLE "${TENSOR_SCHEMA}"."${TENSOR_TRAINING_DATA_TABLE}" ("AGE" TINYINT CS_INT,    "WORKCLASS" NVARCHAR(30),    "FNLWGT" INTEGER CS_INT,    "EDUCATION" NVARCHAR(30),    "EDUCATION_NUM" TINYINT CS_INT,    "MARITAL_STATUS" NVARCHAR(30),    "OCCUPATION" NVARCHAR(30),    "RELATIONSHIP" NVARCHAR(30),    "RACE" NVARCHAR(30),    "GENDER" NVARCHAR(10),    "CAPITAL_GAIN" INTEGER CS_INT,    "CAPITAL_LOSS" SMALLINT CS_INT,    "HOURS_PER_WEEK" TINYINT CS_INT,    "NATIVE_COUNTRY" NVARCHAR(30),    "INCOME_BRACKET" NVARCHAR(7)) UNLOAD PRIORITY 5 AUTO MERGE; 

CREATE COLUMN TABLE "${TENSOR_SCHEMA}"."${TENSOR_TEST_DATA_TABLE}" ("AGE" TINYINT CS_INT,    "WORKCLASS" NVARCHAR(30),    "FNLWGT" INTEGER CS_INT,    "EDUCATION" NVARCHAR(30),    "EDUCATION_NUM" TINYINT CS_INT,    "MARITAL_STATUS" NVARCHAR(30),    "OCCUPATION" NVARCHAR(30),    "RELATIONSHIP" NVARCHAR(30),    "RACE" NVARCHAR(30),    "GENDER" NVARCHAR(10),    "CAPITAL_GAIN" INTEGER CS_INT,    "CAPITAL_LOSS" SMALLINT CS_INT,    "HOURS_PER_WEEK" TINYINT CS_INT,    "NATIVE_COUNTRY" NVARCHAR(30),    "INCOME_BRACKET" NVARCHAR(7)) UNLOAD PRIORITY 5 AUTO MERGE;

CREATE COLUMN TABLE "${TENSOR_SCHEMA}"."${TENSOR_RESULT_TABLE}" ("ID" TIMESTAMP PRIMARY KEY, "ACCURACY" NVARCHAR(4999), "ACCURACY_BASELINE_LABEL_MEAN" NVARCHAR(4999), "ACCURACY_THRESHOLD_MEAN" NVARCHAR(4999), "AUC" NVARCHAR(4999), "GLOBAL_STEP" NVARCHAR(4999), "LABEL_ACTUAL_MEAN" NVARCHAR(4999), "LABEL_PREDICTION_MEAN" NVARCHAR(4999), "LOSS" NVARCHAR(4999), "PRECISION" NVARCHAR(4999), "RECALL" NVARCHAR(4999)) UNLOAD PRIORITY 5 AUTO MERGE;

ALTER SYSTEM ALTER CONFIGURATION('nameserver.ini', 'SYSTEM') SET ('import_export', 'csv_import_path_filter') = '${SCRIPT_DIR}' WITH RECONFIGURE;

IMPORT FROM CSV FILE '${SCRIPT_DIR}/tensordata.csv' INTO "${TENSOR_SCHEMA}"."${TENSOR_TRAINING_DATA_TABLE}" WITH RECORD DELIMITED BY '\n' FIELD DELIMITED BY ',' SKIP FIRST 1 ROW ERROR LOG '${SCRIPT_DIR}/tensordata.err'; 

IMPORT FROM CSV FILE '${SCRIPT_DIR}/tensortestdata.csv' INTO "${TENSOR_SCHEMA}"."${TENSOR_TEST_DATA_TABLE}" WITH RECORD DELIMITED BY '\n' FIELD DELIMITED BY ',' SKIP FIRST 1 ROW ERROR LOG '${SCRIPT_DIR}/tensortestdata.err';

EOF
  
  echo 
  echo "Finished executing sql commands."
  echo 
  echo
  echo "You can execute the following command against the database to verify that your data was loaded: "
  echo
  echo "SELECT count(*) AS ROWSLOADED from \"${TENSOR_SCHEMA}\".\"${TENSOR_TRAINING_DATA_TABLE}\""
  echo "UNION"
  echo "SELECT count(*) from \"${TENSOR_SCHEMA}\".\"${TENSOR_TEST_DATA_TABLE}\";"
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
SCRIPT_DIR="$(cd "$(dirname ${0})"; pwd)"
PARAM_FILE=${SCRIPT_DIR}/params.config

#Error file used to capture errors
TMP_ERROR_FILE="/tmp/out.$$"

if [ $# -gt 0 ]; then
  PARSED_OPTIONS=`getopt -n "$base_name" -a -o h --long help -- "$@"`
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # Something has gone wrong with the getopt command
  if [ "$#" -eq 0 ]; then
    echo no arguments
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

readParamFile

executeSQL

echo "Script has completed."

