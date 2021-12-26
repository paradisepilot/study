
get.DF.dates <- function(
    ncdf4.object = NULL
    ) {
    reference.date <- as.Date(stringr::str_extract(
        string  = ncdf4.object[['dim']][['time']][['units']],
        pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}.+"
        ));
    time.values <- ncdf4.object[['dim']][['time']][['vals']];
    DF.dates <- data.frame(
        date.index = seq(1,length(time.values)),
        date       = reference.date + time.values
        );
    return( DF.dates );
    }

nc_getTidyData.byDate <- function(
    ncdf4.object   = NULL,
    date.requested = NULL
    ) {

    thisFunctionName <- "nc_getTidyData.byDate";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- nc_getTidyData.byDate_all.variables(
        ncdf4.object   = ncdf4.object,
        date.requested = date.requested
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

nc_getTidyData.byCoordinates <- function(
    ncdf4.object   = NULL,
    DF.coordinates = NULL,
    parquet.output = "data-by-coordinates.parquet"
    ) {

    thisFunctionName <- "nc_getTidyData.byCoordinates";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    require(arrow);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(parquet.output) ) {
        DF.output <- arrow::read_parquet(file = parquet.output);
    } else {
        DF.output <- nc_getTidyData.byCoordinates_all.variables(
            ncdf4.object   = ncdf4.object,
            DF.coordinates = DF.coordinates
            );
        arrow::write_parquet(
            x    = DF.output,
            sink = parquet.output
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
my.numeric.hash <- function(x) {
    require(openssl);
    return( as.numeric(paste0("0x",openssl::md5(x))) );
    }

nc_getTidyData.byCoordinates_all.variables <- function(
    ncdf4.object   = NULL,
    DF.coordinates = NULL,
    CSV.partitions = "DF-partitions.csv"
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( "ncdf4" == class(ncdf4.object) ) {
        vals.lat   <- ncdf4.object[['dim']][['lat']][['vals']];
        vals.lon   <- ncdf4.object[['dim']][['lon']][['vals']];
    } else {
        ncdf4.object.temp <- ncdf4::nc_open(ncdf4.object);
        vals.lat   <- ncdf4.object.temp[['dim']][['lat']][['vals']];
        vals.lon   <- ncdf4.object.temp[['dim']][['lon']][['vals']];
        ncdf4::nc_close(ncdf4.object.temp);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.partitions <- nc_get.DF.partitions(
        ncdf4.spatiotemporal = ncdf4.object,
        n.partitions.lat     = 30,
        n.partitions.lon     = 30
        );

    cat("\nstr(DF.partitions)\n");
    print( str(DF.partitions)   );

    write.csv(
        x         = DF.partitions,
        file      = CSV.partitions,
        row.names = FALSE
        );

    lat.starts <- unique(DF.partitions[,'lat.start']);
    lon.starts <- unique(DF.partitions[,'lon.start']);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.coordinates[,'lat.index'] <- base::match(x = DF.coordinates[,'lat'], table = vals.lat);
    DF.coordinates[,'lon.index'] <- base::match(x = DF.coordinates[,'lon'], table = vals.lon);

    DF.coordinates[,'lat.start'] <- apply(
        X      = DF.coordinates[,c('lat.index','lon.index')],
        MARGIN = 1,
        FUN    = function(x) { max(lat.starts[lat.starts <= x[1]]) }
        );

    DF.coordinates[,'lon.start'] <- apply(
        X      = DF.coordinates[,c('lat.index','lon.index')],
        MARGIN = 1,
        FUN    = function(x) { max(lon.starts[lon.starts <= x[2]]) }
        );

    cat("\nstr(DF.coordinates)\n");
    print( str(DF.coordinates)   );

    write.csv(
        x         = DF.coordinates,
        file      = "DF-coordinates.csv",
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.dates  <- get.DF.dates(ncdf4.object = ncdf4.object);
    var.names <- names(ncdf4.object[['var']]);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- data.frame();
    for ( row.index in seq(1,nrow(DF.partitions),1) ) {

        cat(paste0("\n### DF.partitions, row.index = ",row.index,"\n"));

        temp.lat.start <- DF.partitions[row.index,'lat.start'];
        temp.lon.start <- DF.partitions[row.index,'lon.start'];

        DF.temp.coords <- DF.coordinates;
        DF.temp.coords <- DF.temp.coords[DF.temp.coords[,'lat.start'] == temp.lat.start,];
        DF.temp.coords <- DF.temp.coords[DF.temp.coords[,'lon.start'] == temp.lon.start,];

        cat("\nstr(DF.temp.coords)\n");
        print( str(DF.temp.coords)   );

        if ( nrow(DF.temp.coords) < 1 ) {
            cat("\nNo training data coordinates reside in this partition.\n");
            next;
            }

        training.lats <- unique(DF.temp.coords[,'lat']);
        training.lons <- unique(DF.temp.coords[,'lon']);

        training.lats.lons <- apply(
            X      = DF.temp.coords[,c('lat','lon')],
            MARGIN = 1,
            FUN    = function(x) { return(paste(x = x, collapse = "_")) }
            );

        hash.training.lats.lons <- my.numeric.hash(training.lats.lons);

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        var.name  <- var.names[1];
        DF.temp.0 <- nc_getTidyData.byLatLon(
            ncdf4.object = ncdf4.object,
            varid        = var.name,
            lat.start    = DF.partitions[row.index,'lat.start'],
            lat.count    = DF.partitions[row.index,'lat.count'],
            lon.start    = DF.partitions[row.index,'lon.start'],
            lon.count    = DF.partitions[row.index,'lon.count']
            );

        DF.temp.0 <- DF.temp.0[DF.temp.0[,'lat'] %in% training.lats,];
        DF.temp.0 <- DF.temp.0[DF.temp.0[,'lon'] %in% training.lons,];
        DF.temp.0[,'hash_lat_lon'] <- my.numeric.hash(apply(
            X      = DF.temp.0[,c('lat','lon')],
            MARGIN = 1,
            FUN    = function(x) { return(paste(x = x,collapse = "_")) }
            ));
        DF.temp.0 <- DF.temp.0[DF.temp.0[,'hash_lat_lon'] %in% hash.training.lats.lons,];

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        for ( var.index in seq(2,length(var.names)) ) {
            var.name  <- var.names[var.index];
            DF.temp.k <- nc_getTidyData.byLatLon(
                ncdf4.object = ncdf4.object,
                varid        = var.name,
                lat.start    = DF.partitions[row.index,'lat.start'],
                lat.count    = DF.partitions[row.index,'lat.count'],
                lon.start    = DF.partitions[row.index,'lon.start'],
                lon.count    = DF.partitions[row.index,'lon.count']
                );
            DF.temp.k <- DF.temp.k[DF.temp.k[,'lat'] %in% training.lats,];
            DF.temp.k <- DF.temp.k[DF.temp.k[,'lon'] %in% training.lons,];
            DF.temp.k[,'hash_lat_lon'] <- my.numeric.hash(apply(
                X      = DF.temp.k[,c('lat','lon')],
                MARGIN = 1,
                FUN    = function(x) { return(paste(x = x,collapse = "_")) }
                ));
            DF.temp.k <- DF.temp.k[DF.temp.k[,'hash_lat_lon'] %in% hash.training.lats.lons,];
            DF.temp.0 <- merge(
                x  = DF.temp.0,
                y  = DF.temp.k[,c("date","hash_lat_lon",var.name)],
                by = c("date","hash_lat_lon")
                );
            remove(list = c("DF.temp.k"))
            }

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        DF.output <- rbind(DF.output,DF.temp.0);

        cat("\nstr(DF.temp.0)\n");
        print( str(DF.temp.0)   );
        remove(list = c("DF.temp.0"))

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- DF.output[,setdiff(colnames(DF.output),"hash_lat_lon")];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( DF.output );

    }

nc_getTidyData.byCoordinates_all.variables_OBSOLETE <- function(
    ncdf4.object   = NULL,
    DF.coordinates = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    training.lats <- unique(DF.coordinates[,'lat']);
    training.lons <- unique(DF.coordinates[,'lon']);

    training.lats.lons <- apply(
        X      = DF.coordinates[,c('lat','lon')],
        MARGIN = 1,
        FUN    = function(x) { return(paste(x = x, collapse = "_")) }
        );

    hash.training.lats.lons <- my.numeric.hash(training.lats.lons);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.dates  <- get.DF.dates(ncdf4.object = ncdf4.object);
    var.names <- names(ncdf4.object[['var']]);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- data.frame();
    for ( temp.date.index in DF.dates[,'date.index'] ) {

        temp.date <- DF.dates[temp.date.index,'date'];
        cat("\n### temp.date: ",format(temp.date,"%Y-%m-%d"),"\n");

        var.name  <- var.names[1];
        DF.temp.0 <- nc_getTidyData.byDate_one.variable(
            ncdf4.object = ncdf4.object,
            date.index   = temp.date.index,
            varid        = var.name
            );

        DF.temp.0 <- DF.temp.0[DF.temp.0[,'lat'] %in% training.lats,];
        DF.temp.0 <- DF.temp.0[DF.temp.0[,'lon'] %in% training.lons,];
        DF.temp.0[,'hash_lat_lon'] <- my.numeric.hash(apply(
            X      = DF.temp.0[,c('lat','lon')],
            MARGIN = 1,
            FUN    = function(x) { return(paste(x = x,collapse = "_")) }
            ));

        DF.temp.0 <- DF.temp.0[DF.temp.0[,'hash_lat_lon'] %in% hash.training.lats.lons,];
        DF.temp.0 <- cbind(
            date = rep(x = temp.date, times = nrow(DF.temp.0)),
            DF.temp.0
            );

        for ( var.index in seq(2,length(var.names)) ) {
            var.name <- var.names[var.index];
            DF.temp.k  <- nc_getTidyData.byDate_one.variable(
                ncdf4.object = ncdf4.object,
                date.index   = temp.date.index,
                varid        = var.name
                );
            DF.temp.k <- DF.temp.k[DF.temp.k[,'lat'] %in% training.lats,];
            DF.temp.k <- DF.temp.k[DF.temp.k[,'lon'] %in% training.lons,];
            DF.temp.k[,'hash_lat_lon'] <- my.numeric.hash(apply(
                X      = DF.temp.k[,c('lat','lon')],
                MARGIN = 1,
                FUN    = function(x) { return(paste(x = x,collapse = "_")) }
                ));
            DF.temp.k <- DF.temp.k[DF.temp.k[,'hash_lat_lon'] %in% hash.training.lats.lons,];
            DF.temp.0 <- merge(
                x  = DF.temp.0,
                y  = DF.temp.k[,c("hash_lat_lon",var.name)],
                by = "hash_lat_lon"
                );
            remove(list = c("DF.temp.k"))
            }

        DF.output <- rbind(DF.output,DF.temp.0);
        remove(list = c("DF.temp.0"))

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- DF.output[,setdiff(colnames(DF.output),"hash_lat_lon")];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( DF.output );

    }

nc_getTidyData.byDate_all.variables <- function(
    ncdf4.object   = NULL,
    date.requested = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.dates <- get.DF.dates(ncdf4.object = ncdf4.object);
    if ( !(date.requested %in% DF.dates[,'date']) ) { return( NULL ) }
    date.index <- which(date.requested == DF.dates[,'date']);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    var.names <- names(ncdf4.object[['var']]);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    var.name  <- var.names[1];
    DF.output <- nc_getTidyData.byDate_one.variable(
        ncdf4.object = ncdf4.object,
        date.index   = date.index,
        varid        = var.name
        );
    DF.output <- cbind(
        date = rep(x = date.requested, times = nrow(DF.output)),
        DF.output
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( var.index in seq(2,length(var.names)) ) {
        var.name <- var.names[var.index];
        DF.temp  <- nc_getTidyData.byDate_one.variable(
            ncdf4.object = ncdf4.object,
            date.index   = date.index,
            varid        = var.name
            );
        DF.output <- cbind(
            DF.output,
            temp.colname = DF.temp[,var.name]
            );
        colnames(DF.output) <- gsub(
            x           = colnames(DF.output),
            pattern     = "^temp.colname$",
            replacement = var.name
            );
        remove(list = c("DF.temp"))
        }

    remove(list = c('DF.dates','date.index','var.names','var.name'));
    DF.output <- DF.output[,c('date',setdiff(colnames(DF.output),'date'))];
    return( DF.output );

    }

nc_getTidyData.byLatLon <- function(
    ncdf4.object = NULL,
    varid        = NULL,
    lat.start    = NULL,
    lat.count    = NULL,
    lon.start    = NULL,
    lon.count    = NULL
    ) {

    DF.dates <- get.DF.dates(ncdf4.object = ncdf4.object);
    n.dates  <- nrow(DF.dates);

    lats   <- ncdf4.object[['var']][[varid]][['dim']][[2]][['vals']];
    lats   <- lats[seq(lat.start,lat.start + lat.count - 1)];
    n.lats <- length(lats);

    lons   <- ncdf4.object[['var']][[varid]][['dim']][[3]][['vals']];
    lons   <- lons[seq(lon.start,lon.start + lon.count - 1)];
    n.lons <- length(lons);

    data.array <- ncdf4::ncvar_get(
        nc    = ncdf4.object,
        varid = varid,
        start = c(1,       lat.start, lon.start),
        count = c(n.dates, lat.count, lon.count)
        );

    DF.output <- data.frame(
        date    = rep(x = DF.dates[,'date'], times = n.lats * n.lons),
        lat     = rep(rep(x = lats, each = n.dates), times = n.lons),
        lon     = rep(x = lons,  each = n.dates * n.lats),
        varname = as.vector(data.array)
        );

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "varname",
        replacement = varid
        );

    remove(list = c("data.array","DF.dates","n.dates","lats","lons","n.lats","n.lons"));
    return( DF.output );

    }

nc_getTidyData.byDate_one.variable <- function(
    ncdf4.object = NULL,
    date.index   = NULL,
    varid        = NULL
    ) {

    coords.2 <- ncdf4.object[['var']][[varid]][['dim']][[2]][['vals']];
    coords.3 <- ncdf4.object[['var']][[varid]][['dim']][[3]][['vals']];

    data.array <- ncdf4::ncvar_get(
        nc    = ncdf4.object,
        varid = varid,
        start = c(date.index, 1, 1),
        count = c(1, length(coords.2), length(coords.3))
        );

    DF.output <- nc_getTidyData.byDate_one.variable_elongate(
        varid      = varid,
        coords.2   = coords.2,
        coords.3   = coords.3,
        data.array = data.array
        );
    DF.output <- DF.output[,c('coord.2','coord.3','varname')];

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "coord.2",
        replacement = ncdf4.object[['var']][[varid]][['dim']][[2]][['name']]
        );

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "coord.3",
        replacement = ncdf4.object[['var']][[varid]][['dim']][[3]][['name']]
        );

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "varname",
        replacement = varid
        );

    return( DF.output );

    }

nc_getTidyData.byDate_one.variable_elongate <- function(
    varid      = NULL,
    coords.2   = NULL,
    coords.3   = NULL,
    data.array = NULL
    ) {
    DF.output <- base::data.frame(
        coord.2 = base::rep(x = coords.2, times = base::length(coords.3)),
        coord.3 = base::rep(x = coords.3, each  = base::length(coords.2)),
        varname = base::as.vector(data.array)
        );
    return( DF.output );
    }

nc_get.DF.partitions <- function(
    ncdf4.spatiotemporal = NULL,
    n.partitions.lat     = 10,
    n.partitions.lon     = 10
    ) {

    require(ncdf4);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nclass(ncdf4.spatiotemporal)\n");
    print( class(ncdf4.spatiotemporal)   );

    cat("\ntypeof(ncdf4.spatiotemporal)\n");
    print( typeof(ncdf4.spatiotemporal)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( "ncdf4" == class(ncdf4.spatiotemporal) ) {
        length.lat <- ncdf4.spatiotemporal[['dim']][['lat']][['len' ]];
        length.lon <- ncdf4.spatiotemporal[['dim']][['lon']][['len' ]];
        vals.lat   <- ncdf4.spatiotemporal[['dim']][['lat']][['vals']];
        vals.lon   <- ncdf4.spatiotemporal[['dim']][['lon']][['vals']];
    } else {
        ncdf4.object.spatiotemporal <- ncdf4::nc_open(ncdf4.spatiotemporal);
        length.lat <- ncdf4.object.spatiotemporal[['dim']][['lat']][['len' ]];
        length.lon <- ncdf4.object.spatiotemporal[['dim']][['lon']][['len' ]];
        vals.lat   <- ncdf4.object.spatiotemporal[['dim']][['lat']][['vals']];
        vals.lon   <- ncdf4.object.spatiotemporal[['dim']][['lon']][['vals']];
        ncdf4::nc_close(ncdf4.object.spatiotemporal);
        }

    cat("\nlength.lat\n");
    print( length.lat   );

    cat("\nlength.lon\n");
    print( length.lon   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    partition.size.lat <- length.lat %/% n.partitions.lat;
    partition.size.lon <- length.lon %/% n.partitions.lon;

    cat("\npartition.size.lat\n");
    print( partition.size.lat   );

    cat("\npartition.size.lon\n");
    print( partition.size.lon   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    starts.lat = 1 + seq(0,n.partitions.lat) * partition.size.lat;
    starts.lon = 1 + seq(0,n.partitions.lon) * partition.size.lon;

    DF.output <- expand.grid(
        lat.start = starts.lat,
        lon.start = starts.lon
        );
    DF.output[,'lat.count'] <- rep(partition.size.lat,nrow(DF.output));
    DF.output[,'lon.count'] <- rep(partition.size.lon,nrow(DF.output));
    DF.output <- DF.output[,c('lat.start','lat.count','lon.start','lon.count')];

    DF.output[,'lat.count'] <- apply(
        X      = DF.output[,c('lat.start','lat.count')],
        MARGIN = 1,
        FUN    = function(x) {return(ifelse( (sum(x)-1) > length.lat, length.lat - x[1]+1, x[2] ))}
        );

    DF.output[,'lon.count'] <- apply(
        X      = DF.output[,c('lon.start','lon.count')],
        MARGIN = 1,
        FUN    = function(x) {return(ifelse( (sum(x)-1) > length.lon, length.lon - x[1]+1, x[2] ))}
        );

    DF.output[,'lat.stop'] <- DF.output[,'lat.start'] + DF.output[,'lat.count'] - 1;
    DF.output[,'lon.stop'] <- DF.output[,'lon.start'] + DF.output[,'lon.count'] - 1;

    # DF.output[,'file.stem'] <- apply(
    #     X      = DF.output[,c('lat.start','lon.start')],
    #     MARGIN = 1,
    #     FUN    = function(x) {
    #         file.stem <- paste0(
    #             stringr::str_pad(string = x[1], width = 5, pad = "0"),
    #             "-",
    #             stringr::str_pad(string = x[2], width = 5, pad = "0")
    #             );
    #         return( file.stem );
    #         }
    #     );
    #
    # DF.output[,'fpc.scores.parquet'] <- paste0("training-",DF.output[,'file.stem'],".parquet");

    # DF.output <- DF.output[,c('lat.start','lat.stop','lat.count','lon.start','lon.stop','lon.count','min.lat','min.lon','file.stem','training.parquet')];
    DF.output <- DF.output[,c('lat.start','lat.stop','lat.count','lon.start','lon.stop','lon.count')];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # return( DF.output );
    return( DF.output );

    }
