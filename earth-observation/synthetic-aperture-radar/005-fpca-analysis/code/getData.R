
getData <- function(
    input.file   = NULL,
    RData.output = "data-ncdf4.RData"
    ) {

    thisFunctionName <- "getData";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(RData.output) ) {

        # cat(paste0("\n# ",RData.output," already exists; loading this file ...\n"));
        # list.data <- readRDS(file = RData.output);
        # cat(paste0("\n# Loading complete: ",RData.output,"\n"));

    } else {

        require(ncdf4);

        my.ncdf4.object <- ncdf4::nc_open(input.file);
        cat("\n# names(my.ncdf4.object[['var']])\n");
        print(   names(my.ncdf4.object[['var']])   );

        # list.nc.attributes <- ncdf4::ncatt_get(
        #     nc    = my.ncdf4.object,
        #     varid = 0
        #     );

        temp.results <- getData_one.variable(
            ncdf4.object = my.ncdf4.object,
            varid        = "Sigma0_VH_db_mst_26Dec2019"
            );

        ncdf4::nc_open(temp.path);

        }


    cat("\n# str(temp.results)\n");
    print(   str(temp.results)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
getData_one.variable <- function(
    ncdf4.object = NULL,
    varid        = NULL
    ) {

    coords.1 <- ncdf4.object[['var']][[varid]][['dim']][[1]][['vals']];
    coords.2 <- ncdf4.object[['var']][[varid]][['dim']][[2]][['vals']];

    DF.data <- ncdf4::ncvar_get(nc = ncdf4.object, varid = varid);

    byrow.1 <- ifelse(base::length(coords.1) == base::ncol(DF.data),TRUE,FALSE);
    byrow.2 <- ifelse(base::length(coords.2) == base::ncol(DF.data),TRUE,FALSE);

    DF.coords.1 <- matrix(data = coords.1, byrow = byrow.1, nrow = base::nrow(DF.data), ncol = base::ncol(DF.data));
    DF.coords.2 <- matrix(data = coords.2, byrow = byrow.2, nrow = base::nrow(DF.data), ncol = base::ncol(DF.data));

    date.string <- stringr::str_extract(string = varid, pattern="[0-9]{1,2}[A-Za-z]{3}[0-9]{4}");
    ;

    DF.output <- base::data.frame(
        date    = as.Date(x = date.string, format = "%d%B%Y"),
        coord.1 = base::as.vector(DF.coords.1),
        coord.2 = base::as.vector(DF.coords.2),
        varname = base::as.vector(DF.data)
        );
    temp.colnames <- base::c(
        "date",
        ncdf4.object[['var']][[varid]][['dim']][[1]][['name']],
        ncdf4.object[['var']][[varid]][['dim']][[2]][['name']],
        varid
        );
    colnames(DF.output) <- temp.colnames;


    return( DF.output );

    }
