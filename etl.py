import pandas as pd
import os 
import pyodbc
from sqlalchemy import create_engine


def extract_data(filepath='./data/raw'):
    """
    Scans a folder for CSV files and loads them into a dictionary of DataFrames.
    
    Parameters:
        filepath (str): Path to the folder containing raw CSV files.
                        Defaults to '../data/raw'.
    
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


def connect_to_database(username, password):
    """
    Establishes a connection to the RetailSales database on localhost.
    
    Parameters:
        username (str): SQL Server username.
        password (str): SQL Server password.
    
    Returns:
        pyodbc.Connection: An active connection object to the database.
    """
    con = pyodbc.connect(f'DRIVER={{SQL Server}};SERVER=localhost;DATABASE=RetailSales;UID={username};PWD={password}')
    return con

def load_raw_data(files, username, password):
    """
    Loads a dictionary of DataFrames into SQL Server as raw tables.
    
    Parameters:
        files (dict): Dictionary of DataFrames from extract_data()
        username (str): SQL Server username
        password (str): SQL Server password
    """
    engine = create_engine(f'mssql+pyodbc://{username}:{password}@localhost/RetailSales?driver=SQL+Server')
    
    for name, df in files.items():
        df.to_sql(name, engine, if_exists='replace', index=False)


def execute_scripts(con, scripts_path='./sql'):
    """
    Executes all SQL scripts in numerical order against the database.
    
    Parameters:
        con (pyodbc.Connection): Active database connection from connect_to_database().
        scripts_path (str): Path to the folder containing SQL scripts.
                           Defaults to '../scripts'.
    """
    cursor = con.cursor()
    
    scripts = sorted([f for f in os.listdir(scripts_path) if f.endswith('.sql')])
    
    for script in scripts:
        with open(f'{scripts_path}/{script}', 'r') as f:
            sql = f.read()
            cursor.execute(sql)
            con.commit()

def main():
    """
    Runs the full ETL pipeline:
    1. Extracts raw CSV files into DataFrames
    2. Loads raw data into SQL Server
    3. Connects to the database
    4. Executes SQL cleaning and transformation scripts in order
    """
    username = input('Enter username: ')
    password = input('Enter password: ')
    
    files = extract_data()
    load_raw_data(files, username, password)
    con = connect_to_database(username, password)
    execute_scripts(con)
    con.close()

if __name__ == '__main__':
    main()