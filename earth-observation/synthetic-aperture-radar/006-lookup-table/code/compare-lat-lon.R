
compare.lat.lon <- function(
    ncdf4.spatiotemporal    = 'data-input-spatiotemporal.nc',
    DF.training.coordinates = NULL
    ) {

    thisFunctionName <- "compare.lat.lon";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nstr( DF.training.coordinates)\n");
    print( str( DF.training.coordinates)   );

    cat("\nrange(DF.training.coordinates[,'latitude.training'])\n");
    print( range(DF.training.coordinates[,'latitude.training'])   );

    cat("\nrange(DF.training.coordinates[,'longitude.training'])\n");
    print( range(DF.training.coordinates[,'longitude.training'])   );

    cat("\nhead(DF.training.coordinates)\n");
    print( head(DF.training.coordinates)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\n");
    cat("\nlength(unique(DF.training.coordinates$latitude.training)): ",length(unique(DF.training.coordinates$latitude.training)));
    cat("\nlength(unique(round(DF.training.coordinates$latitude.training, digits = 5))): ",length(unique(round(DF.training.coordinates$latitude.training, digits = 5))));

    cat("\nlength(unique(DF.training.coordinates$longitude.training)): ",length(unique(DF.training.coordinates$longitude.training)));
    cat("\nlength(unique(round(DF.training.coordinates$longitude.training, digits = 5))): ",length(unique(round(DF.training.coordinates$longitude.training, digits = 5))));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object <- ncdf4::nc_open(ncdf4.spatiotemporal);

    unlabelled.lats <- ncdf4.object[['dim']][['lat']][['vals']];
    unlabelled.lons <- ncdf4.object[['dim']][['lon']][['vals']];

    cat("\n");
    cat("\nlength(unique(unlabelled.lats)): ",length(unique(unlabelled.lats)));
    cat("\nlength(unique(round(unlabelled.lats, digits = 5))): ",length(unique(round(unlabelled.lats, digits = 5))));

    cat("\nlength(unique(unlabelled.lons)): ",length(unique(unlabelled.lons)));
    cat("\nlength(unique(round(unlabelled.lons, digits = 5))): ",length(unique(round(unlabelled.lons, digits = 5))));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    unlabelled.lats.diff <- unlabelled.lats[seq(1,length(unlabelled.lats)-1)] - unlabelled.lats[seq(2,length(unlabelled.lats))];
    unlabelled.lons.diff <- unlabelled.lons[seq(1,length(unlabelled.lons)-1)] - unlabelled.lons[seq(2,length(unlabelled.lons))];

    cat("\n");
    cat("\nsummary(unlabelled.lats.diff)\n");
    print( summary(unlabelled.lats.diff)   );

    cat("\nsummary(unlabelled.lons.diff)\n");
    print( summary(unlabelled.lons.diff)   );

    cat("\n");
    cat("\ngeosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[2],unlabelled.lats[1]))\n");
    print( geosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[2],unlabelled.lats[1]))   );

    cat("\ngeosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[1],unlabelled.lats[2]))\n");
    print( geosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[1],unlabelled.lats[2]))   );

    cat("\ngeosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[2],unlabelled.lats[2]))\n");
    print( geosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[2],unlabelled.lats[2]))   );

    cat("\n");
    cat("\ngeosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[length(unlabelled.lons)],unlabelled.lats[1]))\n");
    print( geosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[length(unlabelled.lons)],unlabelled.lats[1]))   );

    cat("\ngeosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[1],unlabelled.lats[length(unlabelled.lats)]))\n");
    print( geosphere::distm(c(unlabelled.lons[1],unlabelled.lats[1]),c(unlabelled.lons[1],unlabelled.lats[length(unlabelled.lats)]))   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.labelled.lat.lon <- DF.training.coordinates;
    DF.labelled.lat.lon[,'lat'] <- vapply(
        X         = DF.labelled.lat.lon[,'latitude.training'],
        FUN       = function(x) {
            temp.vector <- abs(x - unlabelled.lats);
            return(unlabelled.lats[which(temp.vector == min(temp.vector))])
            } ,
        FUN.VALUE = 1.0
        );

    DF.labelled.lat.lon[,'lon'] <- vapply(
        X         = DF.labelled.lat.lon[,'longitude.training'],
        FUN       = function(x) {
            temp.vector <- abs(x - unlabelled.lons);
            return(unlabelled.lons[which(temp.vector == min(temp.vector))])
            } ,
        FUN.VALUE = 1.0
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.labelled.lat.lon[,'dist.naive'] <- apply(
        X      = DF.labelled.lat.lon[,c('latitude.training','longitude.training','lat','lon')],
        MARGIN = 1,
        FUN    = function(x) { return(sqrt( (x[1]-x[3])^2 + (x[2]-x[4])^2 )) }
        );

    DF.labelled.lat.lon[,'dist.geo(m)'] <- apply(
        X      = DF.labelled.lat.lon[,c('latitude.training','longitude.training','lat','lon')],
        MARGIN = 1,
        FUN    = function(x) { return(as.numeric(geosphere::distm(x = c(x[2],x[1]), y = c(x[4],x[3])) )) }
        );

    cat("\n");
    cat("\nstr(DF.labelled.lat.lon)\n");
    print( str(DF.labelled.lat.lon)   );

    cat("\nsummary(DF.labelled.lat.lon)\n");
    print( summary(DF.labelled.lat.lon)   );

    write.csv(
        file = "DF-labelled-lat-lon.csv",
        x    = DF.labelled.lat.lon
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4::nc_close(ncdf4.object);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
