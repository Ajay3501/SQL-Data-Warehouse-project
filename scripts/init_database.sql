/*
======================================================================
Create Database and Schemas
======================================================================
Script Purpose:
	This script creates a new database named 'DataWarehouse' after checking if it already exists
    If the databse exists, it is dropped and repeated. Additionally, the script sets up three schemas
    within the database: 'Bronze', 'Silver' and 'Gold'.alter
    
WARNING:
	Running this script will drop the entire 'DataWerehouse' database if it exists.
	All data int he database will be permanently deleted. Procees with caution
	and ensure you have proper backups before running this script.
  we are using fresh database already exist thing can be skipped during creating these.
*/

USE mysql;

-- create and use database 'DataWerehouse'  

CREATE DATABASE DataWarehouse;
USE DataWarehouse;

-- create schemas
 
CREATE SCHEMA Bronze;
CREATE SCHEMA Silver;
CREATE SCHEMA Gold;
