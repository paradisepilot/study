
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
        persist.fpc.scores_inner(
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
persist.fpc.scores_inner <- function(
    var.name     = NULL,
    parquet.file = NULL,
    nc.file      = NULL
    ) {

    thisFunctionName <- "persist.fpc.scores_inner";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(ncdf4);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nparquet.file = ",parquet.file,"\n");
    cat("\nnc.file = ",     nc.file,     "\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    print("A-0");

    DF.scores <- arrow::read_parquet(parquet.file);
    DF.scores <- DF.scores[order(DF.scores$lon,DF.scores$lat),];

    print("A-1");

    colnames.fpc.scores <- grep(x = colnames(DF.scores), pattern = "^fpc_", value = TRUE);
    n.fpc.scores <- length(colnames.fpc.scores);

    print("A-2");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.input <- ncdf4::nc_open(nc.file);

    print("A-3");

    n.lats <- ncdf4.object.input[['dim']][['lat']][['len']];
    n.lons <- ncdf4.object.input[['dim']][['lon']][['len']];

    print("A-4");

    dimension.fpc.score <- ncdf4::ncdim_def(
        name  = "fpc_score",
        units = "numeral",
        vals  = seq(1,n.fpc.scores)
        );

    print("A-5");

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

    print("A-6");

    ncdf4::nc_close(ncdf4.object.input);
    remove(list = c('ncdf4.object.input'));
    gc();

    print("A-7");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.file.output <- gsub(
        x           = nc.file,
        pattern     = "preprocessed",
        replacement = "fpc-scores"
        );

    print("A-8");

    ncdf4.object.output <- ncdf4::nc_create(
        filename = ncdf4.file.output,
        vars     = list.vars
        );

    print("A-9");

    for ( score.index in seq(1,n.fpc.scores) ) {

        print("B-0");

        colname.fpc.score <- colnames.fpc.scores[score.index];

        print("B-1");

        DF.temp <- matrix(data = DF.scores[,colname.fpc.score], nrow = n.lats, ncol = n.lons);

        print("B-2");

        ncdf4::ncvar_put(
            nc    = ncdf4.object.output,
            varid = var.name,
            vals  = DF.temp,
            start = c(1,1,score.index),
            count = c(n.lats,n.lons,1)
            );

        print("B-3");

        }

    print("A-10");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4::nc_close(ncdf4.object.output);
    remove(list = c(
        'DF.scores','DF.temp',
        'ncdf4.file.output','ncdf4.object.output',
        'n.fpc.scores','n.lats','n.lons',
        'colnames.fpc.scores','dimension.fpc.score','list.vars'
        ));
    gc();

    print("A-1");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }
