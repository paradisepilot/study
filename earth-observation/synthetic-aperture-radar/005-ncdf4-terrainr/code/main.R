
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
require(arrow);
require(ggplot2);
require(ncdf4);
require(raster);
require(terrainr);
require(stringr);

# source supporting R code
code.files <- c(
    "getData.R",
    "nc-convert-spatiotemporal.R",
    "test-terrainr.R",
    "utils-ncdf4.R",
    "utils-rgb.R",
    "verify-nc-convert-spatiotemporal.R"
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
set.seed(7654321);

ncdf4.spatiotemporal <- 'data-input-spatiotemporal.nc';
RData.output         <- 'data-long.RData';

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
temp.dir   <- gsub(x = output.directory, pattern = "005-ncdf4-terrainr.+", replacement = "");
# temp.dir <- file.path(temp.dir,"004-preprocess","02-bay-of-quinte","01-AAW","output.AAW.kc-512.2021-10-04.01");
# temp.dir <- file.path(temp.dir,"004-preprocess","02-bay-of-quinte","01-AAW","output.AAW.kc-512.2021-10-07.01.coreg.only");
# temp.dir <- file.path(temp.dir,"004-preprocess","04-drummondville","01-AAW","output.AAW.kc-512.2021-12-25.01");
temp.dir   <- file.path(temp.dir,"004-preprocess","04-drummondville","01-AAW","output.AAW.kc-512.2021-12-29.02");
temp.file  <- "coregistered_stack.nc";
ncdf4.snap <- file.path(temp.dir,temp.file)

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
nc_convert.spatiotemporal(
    ncdf4.file.input  = ncdf4.snap,
    ncdf4.file.output = ncdf4.spatiotemporal
    );
gc();

verify.nc_convert.spatiotemporal(
    ncdf4.spatiotemporal = ncdf4.spatiotemporal,
    ncdf4.snap           = ncdf4.snap
    );
gc();

test.terrainr(
    ncdf4.spatiotemporal = ncdf4.spatiotemporal
    );
gc();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
