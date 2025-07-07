import boto3
import socket
# !pip install psycopg2-binary
import psycopg2
import os
import pandas as pd


def get_sloth_credentials():
    # Get sloth credentials
    ssm_client = boto3.client('ssm')
    sloth_credentials = {
        k.replace("REDSHIFT_", "").lower(): ssm_client.get_parameter(Name=f'/prod/sagemaker/BIADS/sloth/{k}', WithDecryption=True)['Parameter']['Value']
        for k in ['REDSHIFT_USER', 'REDSHIFT_NAME', 'REDSHIFT_DNS', 'REDSHIFT_PORT', 'REDSHIFT_DATABASE', 'IAM_ROLE', 'KMS_KEY_ID']
    }

    # Get sloth password
    sloth_credentials["password"] = ssm_client.get_parameter(
        Name=f"/prod/sagemaker/{sloth_credentials['name']}/redshift_pass_{sloth_credentials['user']}",
        WithDecryption=True
    )["Parameter"]["Value"]

    # Get sloth host
    sloth_credentials["host"] = socket.gethostbyname(sloth_credentials["dns"])

    return sloth_credentials


def connect_to_redshift(sloth_credentials):
    return psycopg2.connect(
        user=sloth_credentials["user"],
        password=sloth_credentials["password"],
        host=sloth_credentials["host"],
        port=sloth_credentials["port"],
        database=sloth_credentials["database"],
    )


# Function to read in parameterized SQL files or SQL strings
def read_sql(sql, params=None, input_type='file'):
    """Function to read in a SQl file
    Args:
        - sql: can be either a .sql file or a string object containing a query
        - params: optional parameter to include a dictonary with parameters
        - input_type: default is "file" for .sql files. Use "string" for SQL string objects
    Returns:
        - sql_string: string object containing the parsed SQL script
    """
    # Open SQL file
    if input_type == 'file' and os.path.exists(sql):
        with open(sql) as f:
            sql_string = f.read()
    elif input_type == 'file' and os.path.exists(sql) is False:
        raise Exception('The input file does not exist. Check if the path, file name and the input_type are correct')
    elif input_type == 'string' and sql[-4:] == '.sql':
        warnings.warn('The input looks like a .sql file. Please check if it was imported correctly and change to input_file = "file" if needed.')
        sql_string = sql
    elif input_type == 'string':
        sql_string = sql
    # Parse parameters into SQL
    if params:
        sql_string = sql_string.format(**params)
    else:
        sql_string = sql_string
    return sql_string


# Function to execute parameterized SQL files or SQL strings
def execute_sql(RSconn, sql, params=None, input_type='file', verbosity=False):
    """Function to execute SQL scripts in Redshift(read, write, unload)
    Args:
        - RSconn: a psycopg2 connection object, used to create a cursor
        - sql: path+name of the sql_file or string object
        - params: optional parameter to include dictonary with parameters
        - input_type: default is "file" for .sql files. Use "string" for SQL stored string objects
        - verbosity: Adds verbosity (bool)
    Returns:
        - df: pandas dataframe if it is a select query
    """
    # 1. Read in SQL
    sql_string = read_sql(sql=sql, params=params, input_type=input_type)
    # 2. Execute SQL
    with RSconn:
        with RSconn.cursor() as curs:
            curs.execute(sql_string)
            if verbosity:
                print('Query has been executed')
            try:
                data = curs.fetchall()
            except psycopg2.ProgrammingError as e:
                print(e)
                data = None

        if data is None:
            if verbosity:
                print("No data has been fetched")
        else:
            df = pd.DataFrame(data, columns=[i.name for i in curs.description])
            if verbosity:
                print('Data has been fetched')
            return df
