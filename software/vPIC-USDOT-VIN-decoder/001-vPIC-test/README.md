
# How to set up ODBC connection (in macOS)

1.  Install `unixodbc`
    ```
    % brew install unixodbc
    ```

1.  Install `FreeTDS`
    ```
    % brew install FreeTDS
    ```

1.  Create the file `/usr/local/etc/odbcinst.ini` (needed to connect from R) with the following contents:
    ```
    [ODBC Driver for MS SQL]
    Driver=/usr/local/lib/libtdsodbc.so
    ```

### Examine the ODBC configuration

Once `unixodbc` has been installed, we can view the ODBC configuration via the following command in a terminal:
```
% odbcinst -j                                 
```

Sample output:
```
unixODBC 2.3.9
DRIVERS............: /etc/odbcinst.ini
SYSTEM DATA SOURCES: /etc/odbc.ini
FILE DATA SOURCES..: /etc/ODBCDataSources
USER DATA SOURCES..: /Users/kennethchu/.odbc.ini
SQLULEN Size.......: 8
SQLLEN Size........: 8
SQLSETPOSIROW Size.: 8
```

# How to launch an MS SQL Server Docker container

1.  **Launch `Docker Desktop` (assumed installed).**

1.  We assume Docker Desktop has been installed.
    If the MS SQL Docker image hasn't been previously pulled,
    do so with the following command in a terminal:
    ```
    % docker pull mcr.microsoft.com/mssql/server
    ```

1.  Execute the following command in a terminal to launch the MS SQL Server container:
    ```
    % docker run -d --name containerName -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=L96175e3EH48MGqw0g' -p 1433:1433 mcr.microsoft.com/mssql/server
    ```

# Preparation for restoring the `vPICList` database

*   Download the `vPIC` MS SQL backup file from
    ```
    https://vpic.nhtsa.dot.gov/api/
    ```
    For example,
    ```
    https://vpic.nhtsa.dot.gov/api/vPICList_lite_2022_02.bak.zip
    ```

*   Copy the downloaded backup file `vPICList_lite_2022_02.bak`
    to the location
    `/var/opt/mssql/data/vPICList_lite_2022_02.bak`
    in file system of the MS SQL Server Docker container,
    via the following Docker command in a terminal:
    ```
    % docker cp <HOST_FILE_SYSTEM_PATH to vPICList_lite_2022_02.bak> containerName:/var/opt/mssql/data/vPICList_lite_2022_02.bak
    ```

# Connect to MS SQL Server from command-line client (`mssql`)

*   If the SQL client `sql-cli` (`mssql`) hasn't been installed yet,
    execute the following command in a terminal to install it:
    ```
    % npm install -g sql-cli
    ```

*   Run the following command in a Linux terminal to connect to the MSSQL server (using the mssql command-line client):
    ```
    % mssql -u <db_usered> -p <db_passwd>
    ```

    The parameters `db_usered` and `db_passwd` must matched the ones used
    to launch the MS SQL Server container; see launch command above,
    where `db_usered = SA` and `db_passwd = L96175e3EH48MGqw0g`.  


# Restoring the `vPICList` database

In this `vPIC` test pipeline, the restoration of the `vPICList` database
is actually performed within the main program `main.R`.
Here, we document the instructions how the restoration could be done
using the command-line client (in particular, outside of an R session).

*   Restore the MS SQL backup file,
    explicitly specifying where the internal files should be saved to
    in the restored database:
    ```
    mssql> restore database vPICList from disk='vPICList_lite_2022_02.bak' with move 'vPICList_Data' to '/var/opt/mssql/data/vPICList.mdf', move 'vPICList_log' to '/var/opt/mssql/data/vPICList.ldf'
    ```

*   Explanation of the two `move` components of the above `restore database` command:

    The database `vPICList` has two internal objects (`vPICList_Data`,`vPICList_log`),
    whose default file system locations must be appropriately overridden
    for the restoration of `vPICList` to be successful.

    The following `mssql` command can be executed prior to the restoration of
    `vPICList` and it shows the two aforementioned internal objects
    (inside the backup file):
    ```
    mssql> RESTORE FILELISTONLY FROM DISK = 'vPICList_lite_2022_02.bak'
    ```

# Some useful `mssql` commands:

*   Check the host name
    ```
    mssql> SELECT HOST_NAME()
    ```
    The output of this `mssql` command is needed to connect from R.
    More precisely, the output of the this command is supplied to
    `odbc::dbConnect(.)` via the `Server` input parameter.

*   See list of all databases:
    ```
    mssql> SELECT name, database_id, create_date FROM sys.databases;
    ```

*   See all tables in the database vPICList:
    ```
    mssql> SELECT * FROM vPICList.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
    ```

*   View two particular tables in the database vPICList:
    ```
    mssql> use vPICList; select * from dbo.FuelType
    mssql> use vPICList; select * from dbo.VinDescriptor
    ````

*   View the stored procedures in the database vPICList:
    ```
    mssql> USE vPICList; SELECT ROUTINE_SCHEMA, ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE';
    ```

*   Use the spVinDecode stored procedure:
    ```
    mssql> USE vPICList; EXEC [dbo].[spVinDecode] @v = N'3535353', @year = 2020
    ```

# How to kill/stop and remove the MS SQL Server Docker container
  ```
  % docker container kill containerName
  % docker container rm --volumes containerName
  ```
