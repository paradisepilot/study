
command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- normalizePath(command.arguments[1]);
code.directory    <- normalizePath(command.arguments[2]);
output.directory  <- normalizePath(command.arguments[3]);
db.userid         <- command.arguments[4];
db.passwd         <- command.arguments[5];

print( data.directory );
print( code.directory );
print( output.directory );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

# set working directory to output directory
setwd( output.directory );

##################################################
require(odbc);
require(DBI);
require(arrow);
require(plyr);

# source supporting R code
code.files <- c(
    "decode-via-vPIC.R"
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# open connection to MS SQL server
my.connection <- odbc::dbConnect(
    drv      = odbc::odbc(),
    Driver   = "ODBC Driver for MS SQL",     # defined in /usr/local/etc/odbcinst.ini
    Server   = "Kenneths-MacBook-Pro.local", # mssql> SELECT HOST_NAME()
    UID      = db.userid, # "SA",
    PWD      = db.passwd, # "L96175e3EH48MGqw0g",
    Port     = 1433
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# restore vPIC database from MS SQL backup file
statement.restore.vPIC <- "restore database vPICList from disk='vPICList_lite_2022_02.bak' with move 'vPICList_Data' to '/var/opt/mssql/data/vPICList.mdf', move 'vPICList_log' to '/var/opt/mssql/data/vPICList.ldf'";
restore.vPIC <- odbc::dbGetQuery(
    conn      = my.connection,
    statement = statement.restore.vPIC
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# hard-coding four fictitious VINs (generated with https://randommer.io/generate-vin) and their respective VIN-11's
vin.17.s  <- c('1GCPCPC03BW4JTCSZ','1GCJC89U577PANEAH','1GTR2VC03B4V25VG5','1GTHC79U51HZF8UCA');
vin.11.s  <- as.character(sapply(X = vin.17.s, FUN = function(x) { return(substr(x,1,11)) } ));

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
temp.vins <- c(vin.11.s,vin.17.s);

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# loop through the VIN-17's and VIN-11's, decoding each one,
# print output of each to a separate CSV file
for (temp.vin in temp.vins) {
    my.results <- odbc::dbGetQuery(
        conn      = my.connection,
        statement = paste0("USE vPICList; EXEC [dbo].[spVinDecode] @v = N'",temp.vin,"'")
        );
    write.csv(
        file      = paste0(temp.vin,".csv"),
        x         = my.results,
        row.names = FALSE
        );
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# Extract the Value column from the vPIC output of each input VIN,
# stack up the transposes of these to form a single data.frame, and
# save the resulting output to disk in parquet format.
# do the same for the CreatedOn column.
decode.via.vPIC(
    vPIC.connection   = my.connection,
    input.vins        = temp.vins,
    output.value      = "output-value.parquet",
    output.created.on = "output-created-on.parquet"
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# close connection to MS SQL server
DBI::dbDisconnect(conn = my.connection);

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# read the two previously persisted parquet files, and
# write them back to disk in CSV format (to facilitate
# correctness test by inspection)
write.csv(
    file      = "output-value.csv",
    x         = arrow::read_parquet("output-value.parquet"),
    row.names = FALSE
    );

write.csv(
    file      = "output-created-on.csv",
    x         = arrow::read_parquet("output-created-on.parquet"),
    row.names = FALSE
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
