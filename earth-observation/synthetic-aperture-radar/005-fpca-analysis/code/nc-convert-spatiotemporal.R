
getData <- function(
    input.file   = NULL,
    RData.output = "list-arrays.RData"
    ) {

    thisFunctionName <- "getData";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(RData.output) ) {

        # cat(paste0("\n# ",RData.output," already exists; loading this file ...\n"));
        # list.arrays <- readRDS(file = RData.output);
        # cat(paste0("\n# Loading complete: ",RData.output,"\n"));

    } else {

        my.ncdf4.object <- ncdf4::nc_open(input.file);
        cat("\n# names(my.ncdf4.object[['var']])\n");
        print(   names(my.ncdf4.object[['var']])   );

        list.arrays <- getData_all.variables(
            ncdf4.object = my.ncdf4.object
            );

        # list.nc.attributes <- ncdf4::ncatt_get(
        #     nc    = my.ncdf4.object,
        #     varid = 0
        #     );

        # temp.results <- getData_one.variable(
        #     ncdf4.object = my.ncdf4.object,
        #     varid        = "Sigma0_VH_db_mst_26Dec2019"
        #     );

        ncdf4::nc_close(my.ncdf4.object);

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\n# str(list.arrays)\n");
    print(   str(list.arrays)   );

    saveRDS(
        file   = RData.output,
        object = list.arrays
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
getData_all.variables <- function(
    ncdf4.object = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    band.names <- names(ncdf4.object[['var']]);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    date.suffixes <- unique(stringr::str_extract(string = band.names, pattern = "[0-9]{1,2}[A-Za-z]{3}[0-9]{4}"));
    DF.dates <- data.frame(
        date.suffix = date.suffixes,
        date        = as.Date(x = date.suffixes, format = "%d%B%Y", tz = "UTC")
        );
    DF.dates <- DF.dates[order(DF.dates[,'date']),c('date.suffix','date')];
    DF.dates[,'date.integer'] <- as.integer(DF.dates[,'date'] - as.Date("1970-01-01", tz = "UTC"));
    rownames(DF.dates) <- seq(1,nrow(DF.dates));

    n.dates <- nrow(DF.dates);

    cat("\nDF.dates\n");
    print( DF.dates   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.dim <- ncdf4.object[['dim']];

    n.lat <- ncdf4.object[['dim']][['lat']][['len']];
    n.lon <- ncdf4.object[['dim']][['lon']][['len']];

    cat("\nn.lat = ",n.lat);
    cat("\nn.lon = ",n.lon);
    cat("\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    var.names <- band.names;
    var.names <- unique(gsub(x = var.names, pattern = "_{1,}[0-9]{1,2}[A-Za-z]{3}[0-9]{4}", replacement = ""));
    var.names <- unique(gsub(x = var.names, pattern = "_{1,}(mst|slv[0-9]{1,})",            replacement = ""));

    cat("\nvar.names\n");
    print( var.names   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.arrays <- list();
    for ( var.name in var.names ) {
        list.arrays[[var.name]] <- base::array(dim = c(n.dates,n.lat,n.lon));
        }

    for (  date.index in base::seq(1,nrow(DF.dates)) ) {
        date.suffix <- DF.dates[date.index,'date.suffix'];
        for ( var.name in var.names ) {
            band.name <- base::grep(x = band.names, pattern = base::paste0(var.name,".+",date.suffix), value = TRUE);
            DF.band   <- ncdf4::ncvar_get(nc = ncdf4.object, varid = band.name);
            if ( all(dim(DF.band) == c(n.lat,n.lon)) ) {
                list.arrays[[var.name]][date.index,,] <- DF.band;
            } else {
                list.arrays[[var.name]][date.index,,] <- base::t(DF.band);
                }
            cat("\n(date.suffix, var.name, band.name, dim(DF.band)) = (",date.suffix,",",var.name,",",band.name,",",base::paste(dim(DF.band),collapse=" x "),")");
            cat("\n")
            }
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( list.arrays );

    }

getData_one.variable <- function(
    ncdf4.object = NULL,
    varid        = NULL
    ) {

    coords.1 <- ncdf4.object[['var']][[varid]][['dim']][[1]][['vals']];
    coords.2 <- ncdf4.object[['var']][[varid]][['dim']][[2]][['vals']];

    DF.data <- ncdf4::ncvar_get(nc = ncdf4.object, varid = varid);

    DF.output <- getData_one.variable_elongate(
        varid    = varid,
        coords.1 = coords.1,
        coords.2 = coords.2,
        DF.data  = DF.data
        );

    date.string <- stringr::str_extract(string = varid, pattern="[0-9]{1,2}[A-Za-z]{3}[0-9]{4}");
    DF.output[,'date'] <- as.Date(x = date.string, format = "%d%B%Y");
    DF.output <- DF.output[,c('date','coord.1','coord.2','varname')];

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
        pattern     = "varname",
        replacement = varid
        );

    return( DF.output );

    }

getData_one.variable_elongate <- function(
    varid    = NULL,
    coords.1 = NULL,
    coords.2 = NULL,
    DF.data  = NULL
    ) {

    byrow.1 <- ifelse(base::length(coords.1) == base::ncol(DF.data),TRUE,FALSE);
    byrow.2 <- ifelse(base::length(coords.2) == base::ncol(DF.data),TRUE,FALSE);

    DF.coords.1 <- matrix(data = coords.1, byrow = byrow.1, nrow = base::nrow(DF.data), ncol = base::ncol(DF.data));
    DF.coords.2 <- matrix(data = coords.2, byrow = byrow.2, nrow = base::nrow(DF.data), ncol = base::ncol(DF.data));

    DF.output <- base::data.frame(
        coord.1 = base::as.vector(DF.coords.1),
        coord.2 = base::as.vector(DF.coords.2),
        varname = base::as.vector(DF.data)
        );

    return( DF.output );

    }

test_getData_one.variable_elongate <- function() {

    thisFunctionName <- "test_getData_one.variable_elongate";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    m <- 5;
    n <- 3;

    coords.1 <- seq(1,m);
    coords.2 <- seq(1,n);

    DF.rows <- matrix(data = coords.1, nrow = m, ncol = n);
    DF.cols <- matrix(data = coords.2, nrow = m, ncol = n, byrow = TRUE);

    DF.input <- 10 * DF.rows + DF.cols;

    cat("\n# DF.input\n");
    print(   DF.input   );

    DF.output <- getData_one.variable_elongate(
        varid    = varid,
        coords.1 = coords.1,
        coords.2 = coords.2,
        DF.data  = DF.input
        );

    cat("\n# DF.output\n");
    print(   DF.output   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }
