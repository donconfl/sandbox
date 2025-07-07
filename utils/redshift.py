import pandas as pd
import getpass
import psycopg2
import boto3
import pyodbc


class Redshift:
    """
    A class for interacting with Redshift - executing queries, loading/unloading to S3, etc.

    Attributes
    ----------
    username : str
        Redshift username
    password : str
        password for corresponding username, if None supplied user will be prompted to create at initialisation
    host : str
        redshift hostname for psycopg2 connection
    database : str
        database to access
    port : str
        port to use for pyscopg2 connection


    Methods
    -------
    execute_query
    query_to_df
    unload_query_to_s3
    copy_from_S3_to_redshift
    """

    def __init__(
        self,
        username: str = None,
        password: str = None,
        host: str = "redshift.app.betfair",
        database: str = "edcrsdbprod",
        port: int = 5439,
    ):
        self.host = host
        self.port = port
        self.database = database
        self.username = username
        if username == "app_sgmk_trading" and password is None:
            ssm = boto3.client("ssm")
            self.password = ssm.get_parameter(
                Name=f"/prod/sagemaker/Risk-Trading/redshift_pass_app_sgmk_trading",
                WithDecryption=True,
            )["Parameter"]["Value"]
        else:
            self.password = (
                getpass.getpass(prompt="Password: ", stream=None)
                if password is None and username is not None
                else password
            )
            
         
    
    def execute_query(self, query: str, return_rows_cols: bool = False, use_credentials:bool =False, ad_connection_str:str ='DSN=Redshift ODBC' ):
        """
        Executes a Redshift sql query. By default only executes the query and does not fetch/return rows. This can be specified if required.
        """
        use_credentials = True if self.username is not None else use_credentials
        return self.execute_credential_query(query, return_rows_cols) if use_credentials else self.execute_AD_query(query, ad_connection_str, return_rows_cols)
        
        
    def execute_credential_query(self, query: str, return_rows_cols: bool = False):
        # open connection
        conn = psycopg2.connect(
            host=self.host,
            port=self.port,
            user=self.username,
            password=self.password,
            database=self.database,
        )
        cur = conn.cursor()

        # execute query
        cur.execute(query)
        conn.commit()

        # return the data if specified
        if return_rows_cols:
            rows = cur.fetchall()
            cols = [i[0] for i in cur.description]
            cur.close()
            conn.close()
            return rows, cols

        # close connection
        cur.close()
        conn.close()
        
        
    def query_is_not_legitimate(self, query: str) -> bool:
        return len(query) < 13


    def execute_AD_query(self, query:str, ad_connection_str:str, return_rows_cols: bool = False):
        # open connection
        conn = pyodbc.connect(ad_connection_str)
        conn.autocommit = True
        cur = conn.cursor()

        if ';' in query:
            query_list = query.split(';')
            final_query = query_list[-1]

            if self.query_is_not_legitimate(final_query):
                list_queries = query_list[0:len(query_list)-1]
            else:
                list_queries = query_list
        else:
            list_queries = [query]
        
        for q in list_queries:
            cur.execute(q)
        
        # return the data if specified
        if return_rows_cols:
            rows = cur.fetchall()
            cols = [i[0] for i in cur.description]
            cur.close()
            conn.close()
            return rows, cols

        # close connection
        cur.close()
        conn.close()
    
    
    def query_to_df(self, query: str, use_credentials:bool=False):
        """
        Excutes a Redshift query and returns the output as a pandas dataframe.
        """        
        rows, cols = self.execute_query(
            query = query, 
            return_rows_cols=True, 
            use_credentials = use_credentials
        )  # rows are pyodbc rows
        return pd.DataFrame((tuple(t) for t in rows), columns=cols)

    def unload_query_to_s3(
        self,
        query,
        outFile,
        role=765819017647,
        objPath="edcs3.prod.risk-and-trading",
        bucket="rs-edcs3.prod.risk-and-trading-rw",
    ):
        """Unload to S3 - i.e. export to a csv so it can be downloaded locally"""

        cmd = f"""unload('{query.replace("'","''")}')
                 to 's3://{objPath}/{outFile}'
                 iam_role 'arn:aws:iam::{role}:role/{bucket}' 
                 delimiter ','
                 parallel false
                 header;
                 """

        self.execute_query(cmd)

    def copy_from_S3_to_redshift(
        self,
        s3File,
        redshiftTable,
        role=765819017647,
        objPath="edcs3.prod.risk-and-trading",
        bucket="rs-edcs3.prod.risk-and-trading-rw",
    ):
        """Load a data from a file in S3 to a redshift table. Must already"""

        cmd = f"""copy {redshiftTable} from 's3://{objPath}/{s3File}'
                  iam_role 'arn:aws:iam::{role}:role/{bucket}'
                  delimiter as ','
                  NULL AS 'NULL'
                  --timeformat 'DD/MM/YYYY HH24:MI'
                  ignoreheader 1;
                 """
        self.execute_query(cmd)