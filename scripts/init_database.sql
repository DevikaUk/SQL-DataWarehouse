-- Purpose: Initialize DataWarehouse database and create the bronze, silver, and gold schemas.

-- Switch to the master database
USE master;
GO

-- Create the DataWarehouse database
CREATE DATABASE DataWarehouse;
GO

-- Switch to newly created database
USE DataWarehouse;
GO

-- Create Bronze schema for raw data
CREATE SCHEMA bronze;
GO

-- Create Silver schema for cleaned and transformed data
CREATE SCHEMA silver;
GO

-- Create Gold schema for business-ready and reporting data
CREATE SCHEMA gold;
GO
