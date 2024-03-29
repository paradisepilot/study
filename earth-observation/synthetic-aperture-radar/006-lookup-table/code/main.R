
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
require(doParallel);
require(foreach);
require(ggplot2);
require(ncdf4);
require(openssl);
require(parallel);
require(raster);
require(terrainr);
require(sf);
require(stringr);
require(tidyr);

require(fpcFeatures);

# source supporting R code
code.files <- c(
    "compare-lat-lon.R",
    "compute-and-save-fpc-scores.R",
    "getData-labelled.R",
    "getData-labelled-helper.R",
    "get-nearest-lat-lon.R",
    "nc-convert-spatiotemporal.R",
    "plot-labelled-data-geography.R",
    "reshapeData.R",
    "plot-RGB-fpc-scores.R",
    "test-terrainr.R",
    "train-fpc-FeatureEngine.R",
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

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
temp.dir   <- gsub(x = output.directory, pattern = "006-lookup-table.+", replacement = "");
#temp.dir  <- file.path(temp.dir,"004-preprocess","02-bay-of-quinte","01-AAW","output.AAW.kc-512.2021-10-04.01");
temp.dir   <- file.path(temp.dir,"004-preprocess","02-bay-of-quinte","01-AAW","output.AAW.kc-512.2021-10-07.01.coreg.only");
temp.file  <- "coregistered_stack.nc";
ncdf4.snap <- file.path(temp.dir,temp.file);

labelled.data.snapshot  <- "2020-12-30.01";
labelled.data.directory <- file.path(data.directory,"bay-of-quinte-labelled",labelled.data.snapshot,"micro-mission-1","Sentinel1","IW","4");
list.files(labelled.data.directory);

target.variable      <- 'Sigma0_VV_db';
ncdf4.spatiotemporal <- 'data-input-spatiotemporal.nc';
ncdf4.fpc.scores     <- 'data-output-fpc-scores.nc';
RData.trained.engine <- 'trained-fpc-FeatureEngine.RData';
n.harmonics          <- 7;

is.macOS <- grepl(x = sessionInfo()[['platform']], pattern = 'apple', ignore.case = TRUE);
n.cores  <- ifelse(test = is.macOS, yes = 4, no = parallel::detectCores());
print( n.cores );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
nc_convert.spatiotemporal(
    ncdf4.file.input  = ncdf4.snap,
    ncdf4.file.output = ncdf4.spatiotemporal
    );
gc();

# verify.nc_convert.spatiotemporal(
#     ncdf4.spatiotemporal = ncdf4.spatiotemporal,
#     ncdf4.snap           = ncdf4.snap
#     );
# gc();
#
# test.terrainr(
#     ncdf4.spatiotemporal = ncdf4.spatiotemporal
#     );
# gc();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.colour.scheme <- data.frame(
    land_cover = c("marsh",  "swamp",  "water",  "forest", "ag",     "shallow"),
    colour     = c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","red"    )
    );
rownames(DF.colour.scheme) <- DF.colour.scheme[,"land_cover"];

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
colname.pattern <- "V";

DF.labelled <- getData.labelled(
    data.directory  = labelled.data.directory,
    colname.pattern = colname.pattern,
    land.cover      = DF.colour.scheme[,'land_cover'],
    parquet.output  = paste0("data-labelled.parquet")
    );
colnames(DF.labelled) <- gsub(
    x           = colnames(DF.labelled),
    pattern     = "^X$",
    replacement = "longitude.training"
    );
colnames(DF.labelled) <- gsub(
    x           = colnames(DF.labelled),
    pattern     = "^Y$",
    replacement = "latitude.training"
    );
print( str(DF.labelled) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.training.coordinates <- as.data.frame(unique(DF.labelled[,c('latitude.training','longitude.training','land_cover')]));
print( str(DF.training.coordinates) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
# compare.lat.lon(
#     ncdf4.spatiotemporal    = ncdf4.spatiotemporal,
#     DF.training.coordinates = DF.training.coordinates
#     );

DF.nearest.lat.lon <- get.nearest.lat.lon(
    DF.training.coordinates = DF.training.coordinates,
    ncdf4.spatiotemporal    = ncdf4.spatiotemporal
    );
print( str(    DF.nearest.lat.lon) );
print( summary(DF.nearest.lat.lon) );

# plot.labelled.data.geography(
#     DF.nearest.lat.lon   = DF.nearest.lat.lon,
#     ncdf4.spatiotemporal = ncdf4.spatiotemporal,
#     plot.date            = as.Date("2019-07-23"),
#     DF.colour.scheme     = DF.colour.scheme
#     );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
ncdf4.object.spatiotemporal <- ncdf4::nc_open(ncdf4.spatiotemporal);
DF.training <- nc_getTidyData.byCoordinates(
    ncdf4.object   = ncdf4.object.spatiotemporal,
    DF.coordinates = DF.nearest.lat.lon[,c('lat','lon')],
    parquet.output = "data-training.parquet"
    );
ncdf4::nc_close(ncdf4.object.spatiotemporal);
print( str(DF.training) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
trained.fpc.FeatureEngine <- train.fpc.FeatureEngine(
    DF.training      = DF.training,
    DF.land.cover    = DF.nearest.lat.lon[,c('lat_lon','land_cover')],
    x                = 'lon',
    y                = 'lat',
    date             = 'date',
    variable         = target.variable,
    min.date         = as.Date("2019-04-06"),
    max.date         = as.Date("2019-10-27"),
    n.harmonics      = 7,
    DF.colour.scheme = DF.colour.scheme,
    RData.output     = RData.trained.engine
    );
print( str(trained.fpc.FeatureEngine) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
CSV.partitions       <- "DF-partitions.csv";
directory.fpc.scores <- "tmp-fpc-scores";

compute.and.save.fpc.scores(
    ncdf4.spatiotemporal = ncdf4.spatiotemporal,
    RData.trained.engine = RData.trained.engine,
    variable             = target.variable,
    ncdf4.output         = ncdf4.fpc.scores,
    CSV.partitions       = CSV.partitions,
    n.cores              = n.cores,
    directory.fpc.scores = directory.fpc.scores
    );

plot.RGB.fpc.scores(
    CSV.partitions       = CSV.partitions,
    directory.fpc.scores = directory.fpc.scores,
    parquet.tidy.scores  = "DF-tidy-scores.parquet",
    PNG.output           = "plot-RGB-fpc-scores.png"
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
