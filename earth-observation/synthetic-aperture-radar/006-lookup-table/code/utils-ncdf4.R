
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
