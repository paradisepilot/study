
persist.fpc.scores <- function(
    var.name          = NULL,
    nc.file.stem      = NULL,
    parquet.file.stem = NULL
    ) {

    thisFunctionName <- "persist.fpc.scores";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    parquet.files <- list.files(pattern = parquet.file.stem);
    cat("\nparquet.files\n");
    print( parquet.files   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( parquet.file in parquet.files ) {

        nc.file <- parquet.file;
        nc.file <- gsub(x = nc.file, pattern = parquet.file.stem, replacement = nc.file.stem);
        nc.file <- gsub(x = nc.file, pattern = "\\.parquet$",     replacement = ".nc"       );

        persist.fpc.scores_ncdf4(
            var.name     = var.name,
            parquet.file = parquet.file,
            nc.file      = nc.file
            );

        persist.fpc.scores_tiff(
            var.name     = var.name,
            parquet.file = parquet.file,
            nc.file      = nc.file
            );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
persist.fpc.scores_tiff <- function(
    var.name     = NULL,
    parquet.file = NULL,
    nc.file      = NULL
    ) {

    thisFunctionName <- "persist.fpc.scores_tiff";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(raster);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nparquet.file = ",parquet.file,"\n");
    cat("\nnc.file = ",     nc.file,     "\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.scores <- arrow::read_parquet(parquet.file);
    DF.scores <- DF.scores[order(DF.scores$lon,-DF.scores$lat),];

    colnames.fpc.scores <- grep(x = colnames(DF.scores), pattern = "^fpc_", value = TRUE);
    n.fpc.scores <- length(colnames.fpc.scores);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.input <- ncdf4::nc_open(nc.file);

    n.lats <- ncdf4.object.input[['dim']][['lat']][['len']];
    n.lons <- ncdf4.object.input[['dim']][['lon']][['len']];

    lat.min <- min(ncdf4.object.input[['dim']][['lat']][['vals']]);
    lat.max <- max(ncdf4.object.input[['dim']][['lat']][['vals']]);
    lon.min <- min(ncdf4.object.input[['dim']][['lon']][['vals']]);
    lon.max <- max(ncdf4.object.input[['dim']][['lon']][['vals']]);

    ncdf4::nc_close(ncdf4.object.input);
    remove(list = c('ncdf4.object.input'));
    gc();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.layers <- list();
    for ( colname.fpc.score in colnames.fpc.scores ) {
        DF.temp <- matrix(data = DF.scores[,colname.fpc.score], nrow = n.lats, ncol = n.lons);
        layer.temp <- raster::raster(nrows = n.lats, ncols = n.lons);
        raster::values(layer.temp) <- DF.temp;
        list.layers[[colname.fpc.score]] <- layer.temp;
        }

    remove(list = c(
        'layer.temp','DF.temp',
        'colname.fpc.score','score.index'
        ));
    gc();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my.stack <- raster::stack(x = list.layers);

    matrix.extent <- matrix(
        data  = c(lon.min,lon.max,lat.min,lat.max),
        nrow  = 2,
        ncol  = 2,
        byrow = TRUE
        );

    my.stack <- setExtent(
        x   = my.stack,
        ext = raster::extent(matrix.extent)
        );

    cat("\nstr(my.stack)\n");
    print( str(my.stack)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    tiff.file.output <- nc.file;

    tiff.file.output <- gsub(
        x           = tiff.file.output,
        pattern     = "preprocessed",
        replacement = "fpc-scores"
        );

    tiff.file.output <- gsub(
        x           = tiff.file.output,
        pattern     = "\\.nc",
        replacement = ".tiff"
        );

    writeRaster(x = my.stack, filename = tiff.file.output);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    remove(list = c(
        'my.stack','tiff.file.output',
        'list.layers','DF.scores',
        'n.fpc.scores','n.lats','n.lons',
        'colnames.fpc.scores','dimension.fpc.score'
        ));
    gc();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

persist.fpc.scores_ncdf4 <- function(
    var.name     = NULL,
    parquet.file = NULL,
    nc.file      = NULL
    ) {

    thisFunctionName <- "persist.fpc.scores_ncdf4";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(ncdf4);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nparquet.file = ",parquet.file,"\n");
    cat("\nnc.file = ",     nc.file,     "\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.scores <- arrow::read_parquet(parquet.file);
    DF.scores <- DF.scores[order(DF.scores$lon,-DF.scores$lat),];

    colnames.fpc.scores <- grep(x = colnames(DF.scores), pattern = "^fpc_", value = TRUE);
    n.fpc.scores <- length(colnames.fpc.scores);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.input <- ncdf4::nc_open(nc.file);

    n.lats <- ncdf4.object.input[['dim']][['lat']][['len']];
    n.lons <- ncdf4.object.input[['dim']][['lon']][['len']];

    dimension.fpc.score <- ncdf4::ncdim_def(
        name  = "fpc_score",
        units = "numeral",
        vals  = seq(1,n.fpc.scores)
        );

    list.vars <- list();
    list.vars[[var.name]] <- ncdf4::ncvar_def(
        name  = var.name,
        units = "fpc_score_dimensionless",
        dim   = list(
            lat       = ncdf4.object.input[['dim']][['lat']],
            lon       = ncdf4.object.input[['dim']][['lon']],
            fpc_score = dimension.fpc.score
            )
        );

    ncdf4::nc_close(ncdf4.object.input);
    remove(list = c('ncdf4.object.input'));
    gc();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.file.output <- gsub(
        x           = nc.file,
        pattern     = "preprocessed",
        replacement = "fpc-scores"
        );

    ncdf4.object.output <- ncdf4::nc_create(
        filename = ncdf4.file.output,
        vars     = list.vars
        );

    for ( score.index in seq(1,n.fpc.scores) ) {

        colname.fpc.score <- colnames.fpc.scores[score.index];
        DF.temp <- matrix(data = DF.scores[,colname.fpc.score], nrow = n.lats, ncol = n.lons);

        ncdf4::ncvar_put(
            nc    = ncdf4.object.output,
            varid = var.name,
            vals  = DF.temp,
            start = c(1,1,score.index),
            count = c(n.lats,n.lons,1)
            );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4::nc_close(ncdf4.object.output);
    remove(list = c(
        'DF.scores','DF.temp',
        'ncdf4.file.output','ncdf4.object.output',
        'n.fpc.scores','n.lats','n.lons',
        'colnames.fpc.scores','dimension.fpc.score','list.vars'
        ));
    gc();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }
