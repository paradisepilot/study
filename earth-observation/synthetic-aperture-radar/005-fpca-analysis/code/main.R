
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
    "getData-labelled.R",
    "getData-labelled-helper.R",
    "nc-convert-spatiotemporal.R",
    "reshapeData.R",
    "test-raster.R",
    "test-terrainr.R",
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

# test_getData_one.variable_elongate();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
temp.dir   <- gsub(x = output.directory, pattern = "005-fpca-analysis.+", replacement = "");
temp.dir   <- file.path(temp.dir,"004-preprocess","02-bay-of-quinte","01-AAW","output.AAW.kc-512.2021-10-04.01");
temp.file  <- "coregistered_stack.nc";
ncdf4.snap <- file.path(temp.dir,temp.file)

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# nc_convert.spatiotemporal(
#     input.file   = ncdf4.snap,
#     ncdf4.output = ncdf4.spatiotemporal
#     );
#
# verify.nc_convert.spatiotemporal(
#     ncdf4.spatiotemporal = ncdf4.spatiotemporal,
#     ncdf4.snap           = ncdf4.snap
#     );
#
# list.data.frames <- getData(
#     ncdf4.input  = ncdf4.spatiotemporal,
#     RData.output = RData.output
#     );
#
# test.raster(
#     ncdf4.spatiotemporal = ncdf4.spatiotemporal
#     );
#
# test.terrainr(
#     list.data.frames = list.data.frames
#     );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.colour.scheme <- data.frame(
    land_cover = c("marsh",  "swamp",  "water",  "forest", "ag",     "shallow"),
    colour     = c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","red"    )
    );
rownames(DF.colour.scheme) <- DF.colour.scheme[,"land_cover"];

labelled.data.snapshot  <- "2020-12-30.01";
labelled.data.directory <- file.path(data.directory,"bay-of-quinte-labelled",labelled.data.snapshot,"micro-mission-1","Sentinel1","IW","4");

list.files(labelled.data.directory);

colname.pattern <- "V";

DF.labelled <- getData.labelled(
    data.directory  = labelled.data.directory,
    colname.pattern = colname.pattern,
    land.cover      = DF.colour.scheme[,'land_cover'],
    RData.output    = paste0("data-labelled.RData")
    );

print( str(DF.labelled) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
print( warnings() );

print( getOption('repos') );

print( .libPaths() );

print( sessionInfo() );

print( format(Sys.time(),"%Y-%m-%d %T %Z") );

stop.proc.time <- proc.time();
print( stop.proc.time - start.proc.time );
