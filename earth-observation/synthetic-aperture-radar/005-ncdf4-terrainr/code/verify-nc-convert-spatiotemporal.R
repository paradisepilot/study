
verify.nc_convert.spatiotemporal <- function(
    year                 = NULL,
    ncdf4.spatiotemporal = NULL,
    ncdf4.snap           = NULL
    ) {

    thisFunctionName <- "verify.nc_convert.spatiotemporal";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\n### verifying data in: ",ncdf4.spatiotemporal,"\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.spatiotemppral <- ncdf4::nc_open(ncdf4.spatiotemporal);
    ncdf4.object.snap           <- ncdf4::nc_open(ncdf4.snap);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    reference.date <- gsub(
        x = ncdf4.object.spatiotemppral[['dim']][['time']][['units']],
        pattern = "days since ",
        replacement = ""
        );
    cat("\nreference.date: ",reference.date);
    reference.date <- as.Date(x = reference.date, tz = "UTC");

    date.integers <- ncdf4.object.spatiotemppral[['dim']][['time']][['vals']];

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    band.names <- names(ncdf4.object.snap[['var']]);
    band.names <- grep(x = band.names, pattern = as.character(year), value = TRUE);

    DF.output <- data.frame(
        band.name       = character(length = length(band.names)),
        var.name        = character(length = length(band.names)),
        var.date        = rep(as.Date("0000-01-01"), times = length(band.names)),
        date.int        = integer(length = length(band.names)),
        date.index      = integer(length = length(band.names)),
        num.NaN.snap    = numeric(length = length(band.names)),
        num.NaN.sptmpl  = numeric(length = length(band.names)),
        num.NaN.ab.diff = numeric(length = length(band.names)),
        max.ab.diff     = numeric(length = length(band.names))
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( i in seq(1,length(band.names)) ) {

        band.name <- band.names[i];
        cat("\n\n### band.name: ",band.name);

        var.name <- verify.nc_convert.spatiotemporal_extract.variable(band.name = band.name);

        var.date   <- verify.nc_convert.spatiotemporal_extract.date(band.name = band.name);
        date.int   <- as.integer(var.date - reference.date);
        date.index <- which(date.int == date.integers)[1];

        DF.snap <- ncdf4::ncvar_get(nc = ncdf4.object.snap, varid = band.name);

        n.coords.2 <- ncdf4.object.spatiotemppral[['var']][[var.name]][['dim']][[2]][['len']];
        n.coords.3 <- ncdf4.object.spatiotemppral[['var']][[var.name]][['dim']][[3]][['len']];
        DF.sptmpl <- ncdf4::ncvar_get(
            nc    = ncdf4.object.spatiotemppral,
            varid = var.name,
            start = c(date.index, 1, 1),
            count = c(1,n.coords.2,n.coords.3)
            );

        num.NaN.snap    <- sum(sapply(DF.snap,   FUN = is.nan));
        num.NaN.sptmpl  <- sum(sapply(DF.sptmpl, FUN = is.nan));
        num.NaN.ab.diff <- sum(is.nan(abs(DF.sptmpl - t(DF.snap))));
        max.ab.diff     <- max(abs(DF.sptmpl - t(DF.snap)), na.rm = TRUE);

        cat("\nstr(t(DF.snap)):\n");
        print( str(t(DF.snap))    );

        cat("\n# of NaN's in DF.snap:\n");
        print( num.NaN.snap );

        cat("\nstr(DF.sptmpl):\n");
        print( str(DF.sptmpl)    );

        cat("\n# of NaN's in DF.sptmpl:\n");
        print( num.NaN.sptmpl );

        cat("\nmax(abs(DF.sptmpl - t(DF.snap)), na.rm = TRUE)\n");
        print( max.ab.diff );

        cat("\nsum(is.nan(abs(DF.sptmpl - t(DF.snap))))\n");
        print( num.NaN.ab.diff );

        DF.temp <- data.frame(
            band.name       = band.name,
            var.name        = var.name,
            var.date        = var.date,
            date.int        = date.int,
            date.index      = date.index,
            num.NaN.snap    = num.NaN.snap,
            num.NaN.sptmpl  = num.NaN.sptmpl,
            num.NaN.ab.diff = num.NaN.ab.diff,
            max.ab.diff     = max.ab.diff
            );

        DF.output[i,] <- DF.temp;

        remove(list = c('DF.sptmpl','DF.snap','DF.temp'));

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4::nc_close(ncdf4.object.spatiotemppral);
    ncdf4::nc_close(ncdf4.object.snap);
    remove(list = c('ncdf4.object.spatiotemppral','ncdf4.object.snap'));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nDF.output\n");
    print( DF.output   );

    cat("\nmax(DF.output[,'max.ab.diff'], na.rm = TRUE)\n");
    print( max(DF.output[,'max.ab.diff'], na.rm = TRUE)   );

    cat("\nsum(is.nan(DF.output[,'max.ab.diff']))\n");
    print( sum(is.nan(DF.output[,'max.ab.diff']))   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    write.csv(
        x         = DF.output,
        file      = paste0("DF-verification-",year,".csv"),
        row.names = FALSE
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    remove(list = c('DF.output','reference.date','date.integers'));
    gc();
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
verify.nc_convert.spatiotemporal_extract.date <- function(
    band.name = NULL
    ) {
    date.string <- stringr::str_extract(
        string  = band.name,
        pattern = "[0-9]{2}[A-Za-z]{3}[0-9]{4}$"
        );
    return( as.Date(x = date.string, format = "%d%B%Y") );
    }

verify.nc_convert.spatiotemporal_extract.variable <- function(
    band.name = NULL
    ) {
    output.string <- gsub(
        x           = band.name,
        pattern     = "_{1,}(mst|slv[0-9]+)_{1,}[0-9]{2}[A-Za-z]{3}[0-9]{4}",
        replacement = ""
        );
    return(output.string);
    }
