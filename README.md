# Retail Sales Analysis

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

## Tech Stack
- **Python** — exploratory data analysis and ETL pipeline orchestration
- **SQL Server** — relational database, data cleaning and star schema transformation
- **Power BI** — interactive dashboard and reporting
- **GitHub** — version control

## Project Overview
This project covers the full data analysis and Business Intelligence pipeline using synthetically generated retail sales data.
The data is extracted, cleaned and loaded into a normalised relational database in SQL Server. It is then transformed into a
star schema optimised for reporting in Power BI. The entire pipeline is automated using a Python ETL script.
Exploratory data analysis was performed in Python prior to cleaning to understand the data quality and structure.

## Star Schema
The final schema is a star schema with `fact_order_item` as the fact table. It has four dimensions: `dim_store`, `dim_product`, `dim_date` and `dim_customer`, each linked with their respective foreign keys. The `order_id` is a reference that links back to the relational layer.

<p align="center">
  <img src="images/star_schema.png" width="550">
  <br>
  <em>Star schema generated from SSMS Database Diagrams</em>
</p>

## Relational Schema
Even though the star schema was the final product, I first normalised the data into a fully relational database with proper primary and foreign key constraints. This reflects how real-world systems are often structured before being transformed into an analytical layer.

<p align="center">
  <img src="images/relational_schema.png" width="550">
  <br>
  <em>Relational schema generated from SSMS Database Diagrams</em>
</p>

## Pipeline
The entire ETL process is automated using a Python script that extracts raw CSV files, loads them into SQL Server as staging tables, then executes all SQL cleaning and transformation scripts in order.

```python
files = extract_data('./data/raw')
load_raw_data(files, server)
con = connect_to_database(server)
execute_scripts(con, './sql')
```

## How to Run
1. Clone the repository
```
git clone https://github.com/MarkSmolders/Retail-Sales-Analysis.git
```
2. Add your raw CSV files to `./data/raw`
3. Install dependencies
```
pip install -r requirements.txt
```
4. Run the pipeline
```
python etl.py
```
5. Enter your SQL Server instance name when prompted (e.g. `localhost` or `LAPTOP-NAME\instance`)
6. Open Power BI Desktop and connect to your SQL Server instance, database `RetailSales`

## Dashboard
The dashboard was built in Power BI Desktop and consists of four pages: Overview, Store Analysis, Products and Customer Analysis. It connects directly to the SQL Server database and reflects the star schema structure.

<p align="center">
  <img src="images/dashboard_overview.png" width="750">
  <br>
  <em>Overview page — Sales Dashboard</em>
</p>

The `.pbix` file is available in the `powerbi` folder and can be opened in Power BI Desktop. Connect to your local SQL Server instance with the `RetailSales` database to use the full dashboard.

## Folder Structure
```
Retail-Sales-Analysis/
├── data/
│   └── raw/          # Raw CSV files
├── images/           # Schema diagrams and visuals
├── notebooks/           # EDA jupyter notebook
├── powerbi/          # Power BI dashboard file
├── sql/              # SQL cleaning and transformation scripts
├── etl.py            # Python ETL pipeline
├── requirements.txt  # Python dependencies
└── README.md
```

## Known Limitations
- The pipeline assumes CSV files match the expected column structure — column names and data types must remain consistent with the original raw data format
- The data is synthetically generated and does not reflect real retail patterns
- New vs returning customer classification is a proxy based on order count rather than actual registration data