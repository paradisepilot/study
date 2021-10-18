
get.nearest.lat.lon <- function(
    DF.training.coordinates = NULL,
    ncdf4.spatiotemporal    = 'data-input-spatiotemporal.nc',
    parquet.nearest.lat.lon = "DF-nearest-lat-lon.parquet"
    ) {

    thisFunctionName <- "get.nearest.lat.lon";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(arrow);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( (!is.null(parquet.nearest.lat.lon)) & file.exists(parquet.nearest.lat.lon) ) {
        DF.nearest.lat.lon <- arrow::read_parquet(file = parquet.nearest.lat.lon);
        cat(paste0("\n",thisFunctionName,"() quits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( DF.nearest.lat.lon );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object <- ncdf4::nc_open(ncdf4.spatiotemporal);
    unlabelled.lats <- ncdf4.object[['dim']][['lat']][['vals']];
    unlabelled.lons <- ncdf4.object[['dim']][['lon']][['vals']];
    ncdf4::nc_close(ncdf4.object);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- DF.training.coordinates;
    DF.output[,'lat'] <- vapply(
        X         = DF.output[,'latitude.training'],
        FUN       = function(x) {
            temp.vector <- abs(x - unlabelled.lats);
            return(unlabelled.lats[which(temp.vector == min(temp.vector))])
            } ,
        FUN.VALUE = 1.0
        );

    DF.output[,'lon'] <- vapply(
        X         = DF.output[,'longitude.training'],
        FUN       = function(x) {
            temp.vector <- abs(x - unlabelled.lons);
            return(unlabelled.lons[which(temp.vector == min(temp.vector))])
            } ,
        FUN.VALUE = 1.0
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output[,'lat_lon'] <- apply(
        X      = DF.output[,c('lat','lon')],
        MARGIN = 1,
        FUN    = function(x) { return(paste(x,collapse="_")) }
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output[,'dist.naive'] <- apply(
        X      = DF.output[,c('latitude.training','longitude.training','lat','lon')],
        MARGIN = 1,
        FUN    = function(x) { return(sqrt( (x[1]-x[3])^2 + (x[2]-x[4])^2 )) }
        );

    DF.output[,'dist.geo(m)'] <- apply(
        X      = DF.output[,c('latitude.training','longitude.training','lat','lon')],
        MARGIN = 1,
        FUN    = function(x) { return(as.numeric(geosphere::distm(x = c(x[2],x[1]), y = c(x[4],x[3])) )) }
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !is.null(parquet.nearest.lat.lon) ) {
        arrow::write_parquet(
            sink = parquet.nearest.lat.lon,
            x    = DF.output
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
