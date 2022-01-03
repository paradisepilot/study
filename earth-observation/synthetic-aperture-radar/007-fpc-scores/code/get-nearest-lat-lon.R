
get.nearest.lat.lon <- function(
    DF.training.coordinates = NULL,
    DF.preprocessed         = NULL,
    parquet.nearest.lat.lon = "DF-nearest-lat-lon.parquet"
    ) {

    thisFunctionName <- "get.nearest.lat.lon";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(arrow);
    require(ncdf4);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( (!is.null(parquet.nearest.lat.lon)) & file.exists(parquet.nearest.lat.lon) ) {
        DF.nearest.lat.lon <- arrow::read_parquet(file = parquet.nearest.lat.lon);
        cat(paste0("\n",thisFunctionName,"() quits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( DF.nearest.lat.lon );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.spatiotemporal <- DF.preprocessed[1,'nc_file'];
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
    DF.output <- get.nearest.lat.lon_deduplicate(DF.input = DF.output);

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
get.nearest.lat.lon_deduplicate <- function(
    DF.input = NULL
    ) {

    thisFunctionName <- "get.nearest.lat.lon_deduplicate";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    is.EESD <- as.character(DF.input[,'land_cover']) %in% c('blue','green','grey');

    DF.EESD <- DF.input[ is.EESD,];
    DF.AGRI <- DF.input[!is.EESD,];

    DF.AGRI[,'lat_lon'] <- apply(
        X      = DF.AGRI[,c('lat','lon')],
        MARGIN = 1,
        FUN    = function(x) { return( paste(x, collapse = "_") ) }
        );

    DF.EESD[,'lat_lon'] <- apply(
        X      = DF.EESD[,c('lat','lon')],
        MARGIN = 1,
        FUN    = function(x) { return( paste(x, collapse = "_") ) }
        );

    DF.AGRI[,'in_EESD'] <- apply(
        X      = DF.AGRI[,c('lat_lon','land_cover')],
        MARGIN = 1,
        FUN    = function(x) { return( x[1] %in% DF.EESD[,'lat_lon'] ) }
        );

    DF.EESD[,'in_AGRI'] <- apply(
        X      = DF.EESD[,c('lat_lon','land_cover')],
        MARGIN = 1,
        FUN    = function(x) { return( x[1] %in% DF.AGRI[,'lat_lon'] ) }
        );

    cat("\nstr(DF.AGRI)\n");
    print( str(DF.AGRI)   );

    cat("\nstr(DF.EESD)\n");
    print( str(DF.EESD)   );

    cat("\nsummary(DF.AGRI)\n");
    print( summary(DF.AGRI)   );

    cat("\nsummary(DF.EESD)\n");
    print( summary(DF.EESD)   );

    cat("\ntable(DF.AGRI[,c('land_cover','in_EESD')])\n");
    print( table(DF.AGRI[,c('land_cover','in_EESD')])   );

    cat("\ntable(DF.EESD[,c('land_cover','in_AGRI')])\n");
    print( table(DF.EESD[,c('land_cover','in_AGRI')])   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.intersection <- DF.EESD[DF.EESD[,'in_AGRI'],c('lat_lon','land_cover')];
    colnames(DF.intersection) <- gsub(
        x           = colnames(DF.intersection),
        pattern     = '^land_cover$',
        replacement = 'land_cover_EESD'
        );

    DF.intersection <- merge(
        x  = DF.intersection,
        y  = DF.AGRI[DF.AGRI[,'in_EESD'],c('lat_lon','land_cover')],
        by = 'lat_lon'
        );
    colnames(DF.intersection) <- gsub(
        x           = colnames(DF.intersection),
        pattern     = '^land_cover$',
        replacement = 'land_cover_AGRI'
        );

    cat("\ntable(DF.intersection[,c('land_cover_AGRI','land_cover_EESD')])\n");
    print( table(DF.intersection[,c('land_cover_AGRI','land_cover_EESD')])   );

    remove(list = c('is.EESD','DF.intersection'));
    gc();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- rbind(
        DF.AGRI[,                    colnames(DF.input)],
        DF.EESD[!DF.EESD[,'in_AGRI'],colnames(DF.input)]
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    remove(list = c('DF.AGRI','DF.EESD'));
    gc();
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }
