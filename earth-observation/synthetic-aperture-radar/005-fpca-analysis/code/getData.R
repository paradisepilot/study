
getData <- function(
    ncdf4.input  = 'data-input-spatiotemporal.nc',
    RData.output = 'data-long.RData'
    ) {

    thisFunctionName <- "getData";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(RData.output) ) {

        cat(paste0("\n# ",RData.output," already exists; loading this file ...\n"));
        DF.output <- readRDS(file = RData.output);
        cat(paste0("\n# Loading complete: ",RData.output,"\n"));

    } else {

        ncdf4.object <- ncdf4::nc_open(ncdf4.input);
        getData_all.variables(
            ncdf4.object = ncdf4.object
            );
        ncdf4::nc_close(ncdf4.object);

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
getData_all.variables <- function(
    ncdf4.object = NULL
    ) {

    var.names <- names(ncdf4.object[['var']]);

    reference.date <- as.Date(stringr::str_extract(
        string  = ncdf4.object[['dim']][['time']][['units']],
        pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}.+"
        ));

    for ( var.index in seq(1,length(var.names)) ) {

        var.name <- var.names[var.index];

        DF.temp <- getData_one.variable(
            ncdf4.object = ncdf4.object,
            varid        = var.name
            );

        colnames(DF.temp) <- gsub(
            x           = colnames(DF.temp),
            pattern     = "time",
            replacement = "date"
            );

        DF.temp[,'date'] <- reference.date + DF.temp[,'date'];

        cat("\nstr(DF.temp)\n");
        print( str(DF.temp)   );

        arrow::write_parquet(
            x    = DF.temp,
            sink = paste0(var.name,".parquet")
            );

        # saveRDS(
        #     file   = paste0(var.name,".RData"),
        #     object = DF.temp
        #     );

        }

    return( NULL );

    }

getData_one.variable <- function(
    ncdf4.object = NULL,
    varid        = NULL
    ) {

    data.array <- ncdf4::ncvar_get(nc = ncdf4.object, varid = varid);

    DF.output <- getData_one.variable_elongate(
        varid      = varid,
        coords.1   = ncdf4.object[['var']][[varid]][['dim']][[1]][['vals']],
        coords.2   = ncdf4.object[['var']][[varid]][['dim']][[2]][['vals']],
        coords.3   = ncdf4.object[['var']][[varid]][['dim']][[3]][['vals']],
        data.array = data.array
        );

    date.string <- stringr::str_extract(string = varid, pattern="[0-9]{1,2}[A-Za-z]{3}[0-9]{4}");
    DF.output[,'date'] <- as.Date(x = date.string, format = "%d%B%Y");
    DF.output <- DF.output[,c('coord.1','coord.2','coord.3','varname')];

    colnames(DF.output) <- gsub(
        x           = colnames(DF.output),
        pattern     = "coord.1",
        replacement = ncdf4.object[['var']][[varid]][['dim']][[1]][['name']]
        );

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

getData_one.variable_elongate <- function(
    varid      = NULL,
    coords.1   = NULL,
    coords.2   = NULL,
    coords.3   = NULL,
    data.array = NULL
    ) {

    DF.output <- base::data.frame(
        coord.1 = base::rep(x = coords.1, times = base::length(coords.2) * base::length(coords.3)),
        coord.2 = base::rep(x = base::rep(x = coords.2, each = base::length(coords.1)), times = base::length(coords.3)),
        coord.3 = base::rep(x = coords.3, each  = base::length(coords.1) * base::length(coords.2)),
        varname = base::as.vector(data.array)
        );

    return( DF.output );

    }

test_getData_one.variable_elongate <- function() {

    thisFunctionName <- "test_getData_one.variable_elongate";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    n.x1 <- 7;
    n.x2 <- 5;
    n.x3 <- 3;

    VC.x1 <- seq(1,n.x1);
    VC.x2 <- seq(1,n.x2);
    VC.x3 <- seq(1,n.x3);

    my.dimnames <- list(
        'x1' = as.character(VC.x1),
        'x2' = as.character(VC.x2),
        'x3' = as.character(VC.x3)
        );

    DF.x2 <- matrix(data = VC.x2, nrow = n.x2, ncol = n.x3);
    DF.x3 <- matrix(data = VC.x3, nrow = n.x2, ncol = n.x3, byrow = TRUE);

    DF.x2.x3 <- 10 * DF.x2 + DF.x3;

    AR.input <- array(dim = c(n.x1,n.x2,n.x3), dimnames = my.dimnames);
    for ( k in seq(1,n.x1,1) ) {
        AR.input [k,,] <- 100 * VC.x1[k] + DF.x2.x3;
        cat("\n# AR.input[",k,",,]\n");
        print(   AR.input[k,,]   );
        }

    DF.output <- getData_one.variable_elongate(
        varid      = varid,
        coords.1   = VC.x1,
        coords.2   = VC.x2,
        coords.3   = VC.x3,
        data.array = AR.input
        );
    DF.output[,'100_x1_10_x2_x3'] <- 100 * DF.output[,'coord.1'] + 10 * DF.output[,'coord.2'] + DF.output[,'coord.3'];
    DF.output[,'check'] <- abs(DF.output[,'varname'] - DF.output['100_x1_10_x2_x3'])

    cat("\n# DF.output\n");
    print(   DF.output   );

    cat("\n# max(DF.output[,'check'])\n");
    print(   max(DF.output[,'check'])   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }
