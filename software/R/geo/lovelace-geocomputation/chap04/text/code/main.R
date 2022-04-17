
command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- normalizePath(command.arguments[1]);
code.directory    <- normalizePath(command.arguments[2]);
output.directory  <- normalizePath(command.arguments[3]);

print( data.directory );
print( code.directory );
print( output.directory );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

start.proc.time <- proc.time();

# set working directory to output directory
setwd( output.directory );

##################################################
library(dplyr);
library(raster);
library(rgdal);
library(sf);
library(spData);
library(spDataLarge);
library(tidyr);

# source supporting R code
code.files <- c(
    "section-04-02.R"
    # "section-04-03.R"
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.seed <- 7654321;
set.seed(my.seed);

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
section.04.02();
# section.04.03();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
