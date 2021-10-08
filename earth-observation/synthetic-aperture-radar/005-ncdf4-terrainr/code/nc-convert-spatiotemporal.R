
nc_convert.spatiotemporal <- function(
    input.file     = NULL,
    date.reference = as.Date("1970-01-01", tz = "UTC"),
    ncdf4.output   = 'data-input-spatiotemporal.nc'
    ) {

    thisFunctionName <- "nc_convert.spatiotemporal";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(ncdf4.output) ) {

        # cat(paste0("\n# ",ncdf4.output," already exists; loading this file ...\n"));
        # list.arrays <- readRDS(file = ncdf4.output);
        # cat(paste0("\n# Loading complete: ",ncdf4.output,"\n"));
        cat(paste0("\n# ",ncdf4.output," already exists; do nothing ...\n"));

    } else {

        my.ncdf4.object <- ncdf4::nc_open(input.file);
        cat("\n# names(my.ncdf4.object[['var']])\n");
        print(   names(my.ncdf4.object[['var']])   );

        list.data <- nc_convert.spatiotemporal_list.data(
            ncdf4.object   = my.ncdf4.object,
            date.reference = date.reference
            );
        cat("\n# str(list.data)\n");
        print(   str(list.data)   );

        nc_convert.spatiotemporal_ncdf4(
            ncdf4.object   = my.ncdf4.object,
            list.data      = list.data,
            date.reference = date.reference,
            ncdf4.output   = ncdf4.output
            );

        ncdf4::nc_close(my.ncdf4.object);
        remove(list = c('list.data'));

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
nc_convert.spatiotemporal_ncdf4 <- function(
    ncdf4.object   = NULL,
    list.data      = NULL,
    date.reference = NULL,
    ncdf4.output   = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    dimension.time <- ncdf4::ncdim_def(
        name  = "time",
        units = paste("days since",date.reference,"UTC"),
        vals  = list.data[['dates']][,'date.integer']
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.vars <- list();
    for ( var.name in names(list.data[['variables']]) ) {
        list.vars[[var.name]] <- ncdf4::ncvar_def(
            name  = var.name,
            units = "intensity_db",
            dim   = list(
                time = dimension.time,
                lat  = ncdf4.object[['dim']][['lat']],
                lon  = ncdf4.object[['dim']][['lon']]
                )
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    output.object <- ncdf4::nc_create(
        filename = ncdf4.output,
        vars     = list.vars
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    global.attributes <- ncatt_get(nc = ncdf4.object, varid = 0);
    retained.attributes <- c('Conventions','TileSize','title');
    for ( retained.attribute in retained.attributes ) {
        if ( retained.attribute %in% names(global.attributes) ) {
            ncdf4::ncatt_put(
                nc         = output.object,
                varid      = 0,
                attname    = retained.attribute,
                attval     = global.attributes[[retained.attribute]],
                prec       = NA,
                verbose    = FALSE,
                definemode = FALSE
                );
            }
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( var.name in names(list.data[['variables']]) ) {
        ncdf4::ncvar_put(
            nc    = output.object,
            varid = var.name,
            vals  = list.data[['variables']][[var.name]]
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4::nc_close(output.object);
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    remove(list = c('list.vars','dimension.time'));
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }

nc_convert.spatiotemporal_list.data <- function(
    ncdf4.object   = NULL,
    date.reference = NULL
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
    DF.dates[,'date.integer'] <- as.integer(DF.dates[,'date'] - date.reference);
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
    list.variables <- list();
    for ( var.name in var.names ) {
        list.variables[[var.name]] <- base::array(dim = c(n.dates,n.lat,n.lon));
        }

    for (  date.index in base::seq(1,nrow(DF.dates)) ) {
        date.suffix <- DF.dates[date.index,'date.suffix'];
        for ( var.name in var.names ) {
            band.name <- base::grep(x = band.names, pattern = base::paste0(var.name,".+",date.suffix), value = TRUE);
            DF.band   <- ncdf4::ncvar_get(nc = ncdf4.object, varid = band.name);
            if ( all(dim(DF.band) == c(n.lat,n.lon)) ) {
                list.variables[[var.name]][date.index,,] <- DF.band;
            } else {
                list.variables[[var.name]][date.index,,] <- base::t(DF.band);
                }
            cat("\n(date.suffix, var.name, band.name, dim(DF.band)) = (",date.suffix,",",var.name,",",band.name,",",base::paste(dim(DF.band),collapse=" x "),")");
            cat("\n")
            }
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.output <- list(
        dates     = DF.dates,
        variables = list.variables
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( list.output );

    }
