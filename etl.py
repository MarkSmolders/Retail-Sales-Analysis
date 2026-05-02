import pandas as pd
import os 
import pyodbc
from sqlalchemy import create_engine


def extract_data(filepath='./data/raw'):
    """
    Scans a folder for CSV files and loads them into a dictionary of DataFrames.
    
    Parameters:
        filepath (str): Path to the folder containing raw CSV files.
                        Defaults to './data/raw'.
    
    Returns:
        dict: A dictionary where keys are filenames (without .csv) 
              and values are pandas DataFrames.
    """
    files = {}
    for file in os.scandir(filepath):
        if file.name.endswith('.csv'):
            key = file.name.replace('.csv', '')
            dataframe = pd.read_csv(file.path)
            files[key] = dataframe
    return files


def connect_to_database(server):
    """
    Establishes a connection to the RetailSales database using Windows Authentication.
    
    Parameters:
        server (str): SQL Server instance name.

    Returns:
        pyodbc.Connection: An active connection object to the database.
    """
    con = pyodbc.connect(f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE=RetailSales;Trusted_Connection=yes')
    return con


def load_raw_data(files, server):
    """
    Loads a dictionary of DataFrames into SQL Server as raw tables.
    
    Parameters:
        files (dict): Dictionary of DataFrames from extract_data()
        server (str): SQL Server instance name.
    """
    server_encoded = server.replace('\\', '\\\\')
    engine = create_engine(f'mssql+pyodbc://{server_encoded}/RetailSales?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes')
    
    for name, df in files.items():
        df.to_sql(name, engine, if_exists='replace', index=False)


def execute_scripts(con, scripts_path='./sql', server='localhost'):
    """
    Executes all SQL scripts in numerical order against the database.
    Skips script 01 as it is handled separately in main.
    
    Parameters:
        con (pyodbc.Connection): Active database connection from connect_to_database().
        scripts_path (str): Path to the folder containing SQL scripts.
        server (str): SQL Server instance name.
    """
    con.autocommit = True
    cursor = con.cursor()

    scripts = sorted([f for f in os.listdir(scripts_path) if f.endswith('.sql')])

    for script in scripts:
        if script.startswith('01'):
            continue
        with open(f'{scripts_path}/{script}', 'r') as f:
            sql = f.read()
            batches = sql.split('\nGO\n')
            for batch in batches:
                batch = batch.strip()
                if batch:
                    cursor.execute(batch)


def main():
    """
    Runs the full ETL pipeline:
    1. Runs script 01 on master to create the database and tables
    2. Connects to RetailSales and runs remaining SQL scripts
    3. Extracts raw CSV files into DataFrames
    4. Loads raw data into SQL Server
    """
    server = input('Enter server name (e.g. LAPTOP-NAME\\instance): ')

    print("Running setup script...")
    con = pyodbc.connect(f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE=master;Trusted_Connection=yes')
    con.autocommit = True
    cursor = con.cursor()
    with open('./sql/01_create_database.sql', 'r') as f:
        sql = f.read()
        batches = sql.split('\nGO\n')
        for batch in batches:
            batch = batch.strip()
            if batch:
                cursor.execute(batch)
    con.close()
    print("Setup done.")

    print("Connecting to RetailSales...")
    con = connect_to_database(server)
    con.autocommit = True
    print("Connected.")

    print("Running SQL scripts...")
    execute_scripts(con, server=server)
    print("Scripts done.")

    print("Extracting CSV files...")
    files = extract_data()
    print(f"Found {len(files)} files.")

    print("Loading raw data...")
    load_raw_data(files, server)
    print("Done.")

    con.close()

if __name__ == '__main__':
    main()