import os
script_dir = os.path.dirname(__file__)
rel_path = "params.config"
abs_file_path = os.path.join(script_dir, rel_path)


HOSTNAME='HOSTNAME'
PORT='PORT'
USER='USER'
PASSWORD='PASSWORD'
TENSOR_SCHEMA='TENSOR_SCHEMA'
TENSOR_TRAINING_DATA_TABLE='TENSOR_TRAINING_DATA_TABLE'
TENSOR_TEST_DATA_TABLE='TENSOR_TEST_DATA_TABLE'
TENSOR_RESULT_TABLE='TENSOR_RESULT_TABLE'

def getParamsFromFile():
    with open(abs_file_path) as f:
       lines = list(f)
    params = {}
    for l in lines:
        l = l.rstrip("\r\n")
        entry = l.split('=')
        params[str(entry[0])] = str(entry[1])
    return params
