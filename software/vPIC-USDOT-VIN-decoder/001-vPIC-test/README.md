
# How to set up ODBC connection (in macOS)

1.  Install **unixodbc**

    ```
    brew install unixodbc
    ```

1.  Install FreeTDS

    ```
    brew install FreeTDS
    ```

1.  Create the file: /usr/local/etc/odbcinst.ini (needed to connect from R) with the following contents:

    [ODBC Driver for MS SQL]
    Driver=/usr/local/lib/libtdsodbc.so

# View ODBC configuration:

    ```
    % odbcinst -j                                 
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

1.  We assume Docker Desktop has been installed.
    If the MS SQL Docker image hasn't been previously pulled,
    do so with the following command in a terminal:

    ```
    docker pull mcr.microsoft.com/mssql/server
    ```

1.  Execute the following command in a terminal:

    ```
    docker run -d --name containerName -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Dummy20031230Password' -p 1433:1433 mcr.microsoft.com/mssql/server
    ```

# Connect to MS SQL Server from command-line client

*   Run the following command in a Linux terminal to connect to the MSSQL server (using the mssql command-line client):

    ```
    $ mssql -u <db_usered> -p <db_passwd>
    ```

# Some useful mssql commands:

*   Check the host name (needed to connect from R)

    ```
    mssql> SELECT HOST_NAME()
    ```

*   Restore the MS SQL backup file, explicitly specifying where the internal files should be saved to in the restored database:

    ```
    mssql> restore database vPICList from disk='vPICList_lite_2022_02.bak' with move 'vPICList_Data' to '/var/opt/mssql/data/vPICList.mdf', move 'vPICList_log' to '/var/opt/mssql/data/vPICList.ldf'
    ```

    Note that for the above mssql command to work,
    the backup file **vPICList_lite_2022_02.bak**
    must have been copied to the location
    **/var/opt/mssql/data/vPICList_lite_2022_02.bak**
    in file system of the MS SQL Server Docker container.

    This can be done with the following Docker command (if necessary):

    ```
    docker cp <HOST_FILE_SYSTEM_PATH to vPICList_lite_2022_02.bak> containerName:/var/opt/mssql/data/vPICList_lite_2022_02.bak
    ```

    But the restoration of the backup file can also be done with the R session.

*   See list of all databases:

    ```
    mssql> SELECT name, database_id, create_date FROM sys.databases;
    ```

*   To see the names/paths of the files internal to the MS SQL backup file
    (This step can be skipped; it is used only to show the internal files
    whose locations in the restored database need to be specificed):

   ```
   mssql> RESTORE FILELISTONLY FROM DISK = 'vPICList_lite_2022_02.bak'
   ```

*   See all tables in the database vPICList:

    ```
    mssql> SELECT * FROM vPICList.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
    ```

*   View two particular tables in the database vPICList:

    ```
    mssql> use vPICList; select * from dbo.FuelType
    ```

    ```
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
  docker container kill containerName
  ```
  ```
  docker container rm --volumes containerName
  ```
