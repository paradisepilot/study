
docker pull mcr.microsoft.com/mssql/server

docker run -d --name containerName -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Dummy20031230Password' -p 1433:1433 mcr.microsoft.com/mssql/server

# copy MS SQL backup file from host file system to Docker container file system:
docker cp <path to the file vPICList_lite_2022_02.bak in host file system> containerName:/var/opt/mssql/data/vPICList_lite_2022_02.bak

### run the following command in a Linux terminal to connect to the MSSQL server (using the mssql command-line client):
$ mssql -u SA -p Dummy20031230Password

### To see the names/paths of the files internal to the MS SQL backup file
### (This step can be skipped; it is used only to show the internal files
### whose locations in the restored database need to be specificed):
mssql> RESTORE FILELISTONLY FROM DISK = 'vPICList_lite_2022_02.bak'

### Restore the MS SQL backup file, explicitly specifying where the internal
### files should be saved to in the restored database:
mssql> restore database vPICList from disk='vPICList_lite_2022_02.bak' with move 'vPICList_Data' to '/var/opt/mssql/data/vPICList.mdf', move 'vPICList_log' to '/var/opt/mssql/data/vPICList.ldf'

### See list of all databases:
mssql> SELECT name, database_id, create_date FROM sys.databases;

### See all tables in the database vPICList:
mssql> SELECT * FROM vPICList.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

### View two particular tables in the database vPICList:
mssql> use vPICList; select * from dbo.FuelType 
mssql> use vPICList; select * from dbo.VinDescriptor

### View the stored procedures in the database vPICList:
mssql> USE vPICList; SELECT ROUTINE_SCHEMA, ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE';

### Use the spVinDecode stored procedure:
mssql> USE vPICList; EXEC [dbo].[spVinDecode] @v = N'3535353', @year = 2020

###########################
(base) % more /usr/local/etc/odbcinst.ini 

[ODBC Driver for MS SQL]
Driver=/usr/local/lib/libtdsodbc.so

###########################

### check host name (needed to connect from R)
mssql> SELECT HOST_NAME()

###########################

my.connection <- odbc::dbConnect(
    drv      = odbc::odbc(),
    Driver   = "ODBC Driver for MS SQL",     # defined in /usr/local/etc/odbcinst.ini
    Server   = "Kenneths-MacBook-Pro.local", # mssql> SELECT HOST_NAME()
    Database = "vPICList",
    UID      = "SA",
    PWD      = "Dummy20031230Password",
    Port     = 1433
    );  
 
my.results <- odbc::dbGetQuery(
    conn      = my.connection,
    statement = "USE vPICList; EXEC [dbo].[spVinDecode] @v = N'5N1AN0NU6BC'"
    ); 

###########################
https://randommer.io/generate-vin

###########################
### View ODBC configuration:
% odbcinst -j                                 
unixODBC 2.3.9
DRIVERS............: /etc/odbcinst.ini
SYSTEM DATA SOURCES: /etc/odbc.ini
FILE DATA SOURCES..: /etc/ODBCDataSources
USER DATA SOURCES..: /Users/kennethchu/.odbc.ini
SQLULEN Size.......: 8
SQLLEN Size........: 8
SQLSETPOSIROW Size.: 8

###########################
### Disregard the following
### Download vPIC backup file (MS SQL backup file) to MS SQL server file system:
wget https://vpic.nhtsa.dot.gov/api/vPICList_lite_2022_02.bak.zip
cd /var/opt/mssql/data
unzip vPICList_lite_2022_02.bak.zip

