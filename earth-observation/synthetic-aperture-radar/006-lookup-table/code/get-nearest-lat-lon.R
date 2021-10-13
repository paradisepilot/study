
get.nearest.lat.lon <- function(
    DF.labelled             = NULL,
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
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.labelled.lat.lon <- unique(DF.labelled[,c('Y','X','land_cover')]);
    DF.labelled.lat.lon <- as.data.frame(DF.labelled.lat.lon);
    colnames(DF.labelled.lat.lon) <- gsub(
        x           = colnames(DF.labelled.lat.lon),
        pattern     = "^X$",
        replacement = "lon"
        );
    colnames(DF.labelled.lat.lon) <- gsub(
        x           = colnames(DF.labelled.lat.lon),
        pattern     = "^Y$",
        replacement = "lat"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object <- ncdf4::nc_open(ncdf4.spatiotemporal);
    unlabelled.lats <- ncdf4.object[['dim']][['lat']][['vals']];
    unlabelled.lons <- ncdf4.object[['dim']][['lon']][['vals']];
    ncdf4::nc_close(ncdf4.object);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.labelled.lat.lon[,'nearest.lat'] <- vapply(
        X         = DF.labelled.lat.lon[,'lat'],
        FUN       = function(x) {
            temp.vector <- abs(x - unlabelled.lats);
            return(unlabelled.lats[which(temp.vector == min(temp.vector))])
            } ,
        FUN.VALUE = 1.0
        );

    DF.labelled.lat.lon[,'nearest.lon'] <- vapply(
        X         = DF.labelled.lat.lon[,'lon'],
        FUN       = function(x) {
            temp.vector <- abs(x - unlabelled.lons);
            return(unlabelled.lons[which(temp.vector == min(temp.vector))])
            } ,
        FUN.VALUE = 1.0
        );

    DF.labelled.lat.lon[,'dist.naive'] <- apply(
        X      = DF.labelled.lat.lon[,c('lat','lon','nearest.lat','nearest.lon')],
        MARGIN = 1,
        FUN    = function(x) { return(sqrt( (x[1]-x[3])^2 + (x[2]-x[4])^2 )) }
        );

    DF.labelled.lat.lon[,'dist.geo(m)'] <- apply(
        X      = DF.labelled.lat.lon[,c('lat','lon','nearest.lat','nearest.lon')],
        MARGIN = 1,
        FUN    = function(x) { return(as.numeric(geosphere::distm(x = c(x[2],x[1]), y = c(x[4],x[3])) )) }
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !is.null(parquet.nearest.lat.lon) ) {
        arrow::write_parquet(
            sink = parquet.nearest.lat.lon,
            x    = DF.labelled.lat.lon
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.labelled.lat.lon );

    }

##################################################
