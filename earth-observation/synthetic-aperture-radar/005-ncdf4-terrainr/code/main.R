
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
    "get-ncdf4-snap.R",
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

study.area <- "drummondville"; # "bay-of-quinte";

is.macOS  <- grepl(x = sessionInfo()[['platform']], pattern = 'apple', ignore.case = TRUE);
# n.cores <- ifelse(test = is.macOS, yes = 4, no = parallel::detectCores());
# n.cores <- ifelse(test = is.macOS, yes = 4, no = 10);
n.cores   <- ifelse(test = is.macOS, yes = 2, no =  5);
print( n.cores );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
ncdf4.snap <- get.ncdf4.snap(
    study.area       = study.area,
    output.directory = output.directory
    );

DF.preprocessed <- nc_convert.spatiotemporal(
    ncdf4.file.input = ncdf4.snap
    );
gc();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
for ( row.index in seq(1,nrow(DF.preprocessed)) ) {
    verify.nc_convert.spatiotemporal(
        year                 = DF.preprocessed[row.index,'year'   ],
        ncdf4.spatiotemporal = DF.preprocessed[row.index,'nc_file'],
        ncdf4.snap           = ncdf4.snap
        );
    gc();
    }

cat("\n");

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
for ( row.index in seq(1,nrow(DF.preprocessed)) ) {
    ncdf4.spatiotemporal <- DF.preprocessed[row.index,'nc_file'];
    cat("\n# plotting images in: ",ncdf4.spatiotemporal,"\n");
    test.terrainr(
        ncdf4.spatiotemporal = ncdf4.spatiotemporal
        );
    gc();
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
