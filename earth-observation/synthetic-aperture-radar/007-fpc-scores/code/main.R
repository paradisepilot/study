
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
    "getData-labelled-bay-of-quinte.R",
    "getData-labelled-drummondville.R",
    "get-ncdf4-snap.R",
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
study.area <- "drummondville"; # "bay-of-quinte";

target.variable      <- 'Sigma0_VV_db';
RData.trained.engine <- 'trained-fpc-FeatureEngine.RData';
n.harmonics          <- 7;

is.macOS  <- grepl(x = sessionInfo()[['platform']], pattern = 'apple', ignore.case = TRUE);
# n.cores <- ifelse(test = is.macOS, yes = 4, no = parallel::detectCores());
n.cores   <- ifelse(test = is.macOS, yes = 4, no = 10);
print( n.cores );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
list.data.labelled <- getData.labelled(
    study.area     = study.area,
    data.directory = data.directory,
    RData.output   = "data-labelled.RData"
    );

DF.labelled      <- list.data.labelled[['data'         ]];
DF.colour.scheme <- list.data.labelled[['colour_scheme']];

print( str(DF.labelled     ) );
print( str(DF.colour.scheme) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.training.coordinates <- as.data.frame(unique(DF.labelled[,c('latitude.training','longitude.training','land_cover')]));
print( str(DF.training.coordinates) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
ncdf4.snap <- get.ncdf4.snap(
    study.area       = study.area,
    output.directory = output.directory
    );

DF.preprocessed <- nc_convert.spatiotemporal(
    ncdf4.file.input = ncdf4.snap
    );
gc();

                        # verify.nc_convert.spatiotemporal(
                        #     ncdf4.spatiotemporal = ncdf4.spatiotemporal,
                        #     ncdf4.snap           = ncdf4.snap
                        #     );
                        # gc();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
                        # compare.lat.lon(
                        #     ncdf4.spatiotemporal    = ncdf4.spatiotemporal,
                        #     DF.training.coordinates = DF.training.coordinates
                        #     );

DF.nearest.lat.lon <- get.nearest.lat.lon(
    DF.training.coordinates = DF.training.coordinates,
    DF.preprocessed         = DF.preprocessed
    );
gc();
print( str(    DF.nearest.lat.lon) );
print( summary(DF.nearest.lat.lon) );

plot.labelled.data.geography(
    DF.nearest.lat.lon   = DF.nearest.lat.lon,
    DF.preprocessed      = DF.preprocessed,
    plot.date            = NULL, # use default method to choose date
    DF.colour.scheme     = DF.colour.scheme
    );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
DF.training <- nc_getTidyData.byCoordinates(
    DF.preprocessed = DF.preprocessed,
    DF.coordinates  = DF.nearest.lat.lon[,c('lat','lon')],
    parquet.output  = "data-training.parquet"
    );
gc();
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
gc();
print( str(trained.fpc.FeatureEngine) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
CSV.partitions       <- "DF-partitions-scores.csv";
directory.fpc.scores <- "tmp-fpc-scores";
parquet.file.stem    <- "DF-tidy-scores";

compute.and.save.fpc.scores(
    DF.preprocessed      = DF.preprocessed,
    RData.trained.engine = RData.trained.engine,
    variable             = target.variable,
    ncdf4.output         = ncdf4.fpc.scores,
    CSV.partitions       = CSV.partitions,
    n.cores              = n.cores,
    n.partitions.lat     = 30,
    n.partitions.lon     = 30,
    directory.fpc.scores = directory.fpc.scores,
    parquet.file.stem    = parquet.file.stem
    );
gc();

plot.RGB.fpc.scores(
    directory.fpc.scores = directory.fpc.scores,
    parquet.file.stem    = parquet.file.stem,
    PNG.output.file.stem = "plot-RGB-fpc-scores"
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
