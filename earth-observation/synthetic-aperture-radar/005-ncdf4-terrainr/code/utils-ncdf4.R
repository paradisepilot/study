
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

getTidyData.byDate <- function(
    ncdf4.object   = NULL,
    date.requested = NULL
    ) {

    thisFunctionName <- "getTidyData.byDate";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- getTidyData.byDate_all.variables(
        ncdf4.object   = ncdf4.object,
        date.requested = date.requested
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
getTidyData.byDate_all.variables <- function(
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
    DF.output <- getTidyData.byDate_one.variable(
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
        DF.temp  <- getTidyData.byDate_one.variable(
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

getTidyData.byDate_one.variable <- function(
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

    DF.output <- getTidyData.byDate_one.variable_elongate(
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

getTidyData.byDate_one.variable_elongate <- function(
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
