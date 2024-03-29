
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
require(terra);
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
    "initializePlot.R",
    "nc-convert-spatiotemporal.R",
    "plot-labelled-data-geography.R",
    "reshapeData.R",
    "persist-fpc-scores.R",
    "plot-RGB-fpc-scores.R",
    "test-terrainr.R",
    "train-fpc-FeatureEngine.R",
    "utils-ncdf4.R",
    "utils-rgb.R",
    "verify-nc-convert-spatiotemporal.R",
    "visualize-fpc-approximations.R",
    "visualize-training-data.R"
    );

for ( code.file in code.files ) {
    source(file.path(code.directory,code.file));
    }

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
my.seed <- 7654321;
set.seed(my.seed);

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
study.area <- "drummondville"; # "bay-of-quinte";

target.variable      <- 'Sigma0_VV_db';
RData.trained.engine <- 'trained-fpc-FeatureEngine.RData';
n.harmonics          <- 7;

is.macOS  <- grepl(x = sessionInfo()[['platform']], pattern = 'apple', ignore.case = TRUE);
n.cores   <- ifelse(test = is.macOS, yes = 4, no = parallel::detectCores() - 1);
# n.cores <- ifelse(test = is.macOS, yes = 4, no = 10);
# n.cores <- ifelse(test = is.macOS, yes = 4, no =  5);
# n.cores <- ifelse(test = is.macOS, yes = 4, no =  2);
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

print( levels(DF.labelled[,'land_cover']) );

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
    DF.preprocessed         = DF.preprocessed,
    DF.colour.scheme        = DF.colour.scheme
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
visualize.training.data(
    DF.nearest.lat.lon = DF.nearest.lat.lon,
    DF.training        = DF.training,
    colname.pattern    = "Sigma0_(VV|VH)_db",
    DF.colour.scheme   = DF.colour.scheme,
    output.directory   = "plot-training-data"
    );
gc();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
trained.fpc.FeatureEngine <- train.fpc.FeatureEngine(
    DF.training      = DF.training,
    DF.land.cover    = DF.nearest.lat.lon[,c('lat_lon','land_cover')],
    x                = 'lon',
    y                = 'lat',
    date             = 'date',
    variable         = target.variable,
    min.date         = as.Date("2019-01-15"),
    max.date         = as.Date("2019-12-16"),
    n.harmonics      = 7,
    DF.colour.scheme = DF.colour.scheme,
    RData.output     = RData.trained.engine
    );
gc();
print( str(trained.fpc.FeatureEngine) );

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
approximations.directory <- file.path(getwd(),"tmp-fpc-approximations");

DF.training[,"lat_lon"] <- apply(
    X      = DF.training[,c("lat","lon")],
    MARGIN = 1,
    FUN    = function(x) { return(paste(x = x, collapse = "_")) }
    );

print( str(DF.training) );

print( str(unique(DF.training)) );

print( str(DF.nearest.lat.lon) );

print( str(unique(DF.nearest.lat.lon)) );

print( setdiff(DF.training$lat_lon,DF.nearest.lat.lon$lat_lon) );

print( setdiff(DF.nearest.lat.lon$lat_lon,DF.training$lat_lon) );

DF.training <- merge(
    x     = DF.training,
    y     = DF.nearest.lat.lon[,c('lat_lon','land_cover')],
    by    = 'lat_lon',
    all.x = TRUE
    );
DF.training <- unique(DF.training);

visualize.fpc.approximations(
    featureEngine    = trained.fpc.FeatureEngine,
    DF.variable      = DF.training,
    location         = 'lat_lon',
    date             = 'date',
    land.cover       = 'land_cover',
    variable         = target.variable,
    n.locations      = 10,
    DF.colour.scheme = DF.colour.scheme,
    my.seed          = my.seed,
    output.directory = approximations.directory
    );

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
    PNG.output.file.stem = "plot-RGB-fpc-scores",
    dots.per.inch        = ifelse(test = is.macOS, yes = 1000, no = 300)
    );
gc();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
persist.fpc.scores(
    var.name          = target.variable,
    nc.file.stem      = "data-preprocessed",
    parquet.file.stem = parquet.file.stem
    );

remove(list = c('DF.training'));
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
