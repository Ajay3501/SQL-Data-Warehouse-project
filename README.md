# SQL-Data-Warehouse-project

Welcome to the ** Data warehouse and Analytics Projects ** repository ! 
This Project demonstrate a comprehensive data warehousing and analytics solution , from building a data warehouse t genearting actionable insights , designed a portfolio project high;ights industury best in data engeneering and analytics.

---
## Project Requirements

### Objective
Develop a modern data warehouse using MYSQL to consolidate asles data, enabling analytical reporting and infornmed decision-making.

#### Specifications
  ** Data Source ** : Import data from two source systems (ERP and CRM) provided as CSV files.<br>
  ** Data Quality ** : Cleanse and resolver data quality issues prior to analysis.<br>
  ** Integration ** : Combone both sources into a single , user-friendly data model design for analytical queries.<br>
  ** Scope** : Focused on the latest datasets only, Historization of the data is not required.<br>
  ** Documentation ** : Provide clear documentation of the model to support both busniess,stakeholders and analytics teams.<br>

  ---
---
## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
![Data Architecture](docs/data_architecture.png)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---
## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

🎯 This repository is an excellent resource for professionals and students looking to showcase expertise in:
- SQL Development
- Data Architect
- Data Engineering  
- ETL Pipeline Developer  
- Data Modeling  
- Data Analytics  

---
  ### BI : Analytics & Reporting (Data Analytics)
### Building the Data Warehouse (Data Engineering)

  #### Objectives
  Develop SQL-based analytics to deliver detailed insights into :-<br>
    1). **Customer Behaviour**<br>
    2). **Product Perfomance**<br>
    3). **Sales Trends**
   
  These insights empower stakeholder with key business metrics, strategic decision-makiing.

## 📂 Repository Structure
<pre>
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)              
│
├── docs/                               # Project documentation and architecture details                     
│   ├── etl.drawio                      # Draw.io file shows all different techniquies and methods of ETL  
│   ├── data_architecture.drawio        # Draw.io file shows the project's architecture                      
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata     
│   ├── data_flow.drawio                # Draw.io file for the data flow diagram                              
│   ├── data_models.drawio              # Draw.io file for data models (star schema)                          
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files         
│
├── scripts/                            # SQL scripts for ETL and transformations                             
│   ├── bronze/                         # Scripts for extracting and loading raw data                          
│   ├── silver/                         # Scripts for cleaning and transforming data                          
│   ├── gold/                           # Scripts for creating analytical models                              
│
├── tests/                              # Test scripts and quality files                                        
│
├── README.md                           # Project overview and instructions                                     
├── LICENSE                             # License information for the repository                                 
├── .gitignore                          # Files and directories to be ignored by Git                              
└── requirements.txt                    # Dependencies and requirements for the project                           
</pre>
## Liecense 

This Project is liecensed under the [MIT Liecense](Liecense). you are free to use, modify  and share this project with proper attribution.

## About Me

Hi there I'm ** Ajay Kumar Rana**, also known as ** jaycode**, I'm here to share my knowledge.
















