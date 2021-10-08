
nc_convert.spatiotemporal <- function(
    ncdf4.file.input  = NULL,
    ncdf4.file.output = 'data-input-spatiotemporal.nc',
    date.reference    = as.Date("1970-01-01", tz = "UTC")
    ) {

    thisFunctionName <- "nc_convert.spatiotemporal";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(ncdf4.file.output) ) {

        # cat(paste0("\n# ",ncdf4.output," already exists; loading this file ...\n"));
        # list.arrays <- readRDS(file = ncdf4.output);
        # cat(paste0("\n# Loading complete: ",ncdf4.output,"\n"));
        cat(paste0("\n# ",ncdf4.file.output," already exists; do nothing ...\n"));

    } else {

        ncdf4.object.input <- ncdf4::nc_open(ncdf4.file.input);
        cat("\n# names(ncdf4.object.input[['var']])\n");
        print(   names(ncdf4.object.input[['var']])   );

        nc_convert.spatiotemporal_inner(
            ncdf4.object.input = ncdf4.object.input,
            ncdf4.file.output  = ncdf4.file.output,
            date.reference     = date.reference
            );

        ncdf4::nc_close(ncdf4.object.input);
        remove(list = c('list.data','ncdf4.object.input'));
        gc();

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
nc_convert.spatiotemporal_inner <- function(
    ncdf4.object.input = NULL,
    ncdf4.file.output  = NULL,
    date.reference     = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    band.names <- names(ncdf4.object.input[['var']]);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    date.suffixes <- unique(stringr::str_extract(string = band.names, pattern = "[0-9]{1,2}[A-Za-z]{3}[0-9]{4}"));
    DF.dates <- data.frame(
        date.suffix = date.suffixes,
        date        = as.Date(x = date.suffixes, format = "%d%B%Y", tz = "UTC")
        );
    DF.dates <- DF.dates[order(DF.dates[,'date']),c('date.suffix','date')];
    DF.dates[,'date.integer'] <- as.integer(DF.dates[,'date'] - date.reference);
    rownames(DF.dates) <- seq(1,nrow(DF.dates));

    cat("\nDF.dates\n");
    print( DF.dates   );

    dimension.time <- ncdf4::ncdim_def(
        name  = "time",
        units = paste("days since",date.reference,"UTC"),
        vals  = DF.dates[,'date.integer']
        );

    remove(list = c("date.suffixes"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    var.names <- band.names;
    var.names <- unique(gsub(x = var.names, pattern = "_{1,}[0-9]{1,2}[A-Za-z]{3}[0-9]{4}", replacement = ""));
    var.names <- unique(gsub(x = var.names, pattern = "_{1,}(mst|slv[0-9]{1,})",            replacement = ""));

    cat("\nvar.names\n");
    print( var.names   );

    list.vars <- list();
    for ( var.name in var.names ) {
        list.vars[[var.name]] <- ncdf4::ncvar_def(
            name  = var.name,
            units = ncdf4.object.input[['var']][[1]][['units']],
            dim   = list(
                time = dimension.time,
                lat  = ncdf4.object.input[['dim']][['lat']],
                lon  = ncdf4.object.input[['dim']][['lon']]
                )
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.output <- ncdf4::nc_create(
        filename = ncdf4.file.output,
        vars     = list.vars
        );
    remove(list = c("dimension.time","list.vars"));
    gc();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    global.attributes   <- ncdf4::ncatt_get(nc = ncdf4.object.input, varid = 0);
    retained.attributes <- c('Conventions','TileSize','title');
    for ( retained.attribute in retained.attributes ) {
        if ( retained.attribute %in% names(global.attributes) ) {
            ncdf4::ncatt_put(
                nc         = ncdf4.object.output,
                varid      = 0,
                attname    = retained.attribute,
                attval     = global.attributes[[retained.attribute]],
                prec       = NA,
                verbose    = FALSE,
                definemode = FALSE
                );
            }
        }
    remove(list = c("global.attributes","retained.attributes"));
    gc();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    n.lats <- ncdf4.object.input[['dim']][['lat']][['len']];
    n.lons <- ncdf4.object.input[['dim']][['lon']][['len']];

    for (  date.index in base::seq(1,nrow(DF.dates)) ) {
        date.suffix <- DF.dates[date.index,'date.suffix'];
        for ( var.name in var.names ) {
            band.name <- base::grep(x = band.names, pattern = base::paste0(var.name,".+",date.suffix), value = TRUE);
            DF.band   <- ncdf4::ncvar_get(nc = ncdf4.object.input, varid = band.name);
            if ( all(dim(DF.band) == c(n.lats,n.lons)) ) {
                ncdf4::ncvar_put(
                    nc    = ncdf4.object.output,
                    varid = var.name,
                    vals  = DF.band,
                    start = c(date.index,1,1),
                    count = c(1,n.lats,n.lons)
                    );
            } else {
                ncdf4::ncvar_put(
                    nc    = ncdf4.object.output,
                    varid = var.name,
                    vals  = base::t(DF.band),
                    start = c(date.index,1,1),
                    count = c(1,n.lats,n.lons)
                    );
                }
            cat("\n(",date.suffix,",",var.name,",",band.name,"): dim(DF.band) =",base::paste(dim(DF.band),collapse = " x "),"\n");
            remove(list = c('DF.band'));
            }
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4::nc_close(ncdf4.object.output);
    remove(list = c('DF.dates','ncdf4.object.output','n.lats','n.lons'));
    gc();
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }
