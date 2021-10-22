
compute.and.save.fpc.scores <- function(
    ncdf4.spatiotemporal = NULL,
    RData.trained.engine = NULL,
    ncdf4.output         = NULL
    ) {

    thisFunctionName <- "compute.and.save.fpc.scores";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.partition.table <- compute.and.save.fpc.scores_get.partition.table(
        ncdf4.spatiotemporal = ncdf4.spatiotemporal
        );
    cat("\nstr(DF.partition.table)\n");
    print( str(DF.partition.table)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # if ( file.exists(parquet.output) ) {
    #     DF.output <- arrow::read_parquet(file = parquet.output);
    #     cat(paste0("\n",thisFunctionName,"() exits."));
    #     cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    #     return( DF.output );
    #     }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # initial.directory <- getwd();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # temp.directory <- file.path(initial.directory,"data");
    # if ( !dir.exists(temp.directory) ) {
    #     dir.create(path = temp.directory, recursive = TRUE);
    #     }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # years <- getData.labelled_getYears(
    #     data.directory = data.directory,
    #     exclude.years  = exclude.years
    #     );

    # cat(paste0("\n# ",thisFunctionName,"(): years:","\n"));
    # print( years );
    #
    # DF.output <- data.frame();
    # for ( temp.year in years ) {
    #
    #     list.data <- getData.labelled_helper(
    #         data.directory     = data.directory,
    #         year               = temp.year,
    #         exclude.land.types = exclude.land.types,
    #         output.file        = file.path(temp.directory,paste0("data-",temp.year,"-raw.RData"))
    #         );
    #
    #     cat(paste0("\nstr(list.data) -- ",temp.year,"\n"));
    #     print(        str(list.data) );
    #
    #     DF.data.reshaped <- reshapeData(
    #         list.input      = list.data,
    #         colname.pattern = colname.pattern,
    #         land.cover      = land.cover,
    #         output.file     = file.path(temp.directory,paste0("data-",temp.year,"-reshaped.RData"))
    #         );
    #
    #     cat(paste0("\nstr(DF.data.reshaped) -- ",temp.year,"\n"));
    #     print(        str(DF.data.reshaped) );
    #
    #     DF.output <- rbind(DF.output,DF.data.reshaped);
    #
    #     }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # if (!is.null(parquet.output)) {
    #     arrow::write_parquet(x = DF.output, sink = parquet.output);
    #     }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # remove(list = c("list.data"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
compute.and.save.fpc.scores_get.partition.table <- function(
    ncdf4.spatiotemporal = NULL,
    n.partitions.lat     = 10,
    n.partitions.lon     = 10
    ) {

    require(ncdf4);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.spatiotemporal <- ncdf4::nc_open(ncdf4.spatiotemporal);
    length.lat <- ncdf4.object.spatiotemporal[['dim']][['lat']][['len']];
    length.lon <- ncdf4.object.spatiotemporal[['dim']][['lon']][['len']];
    ncdf4::nc_close(ncdf4.object.spatiotemporal);

    cat("\nlength.lat\n");
    print( length.lat   );

    cat("\nlength.lon\n");
    print( length.lon   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    partition.size.lat <- length.lat %/% n.partitions.lat;
    partition.size.lon <- length.lon %/% n.partitions.lon;

    cat("\npartition.size.lat\n");
    print( partition.size.lat   );

    cat("\npartition.size.lon\n");
    print( partition.size.lon   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    starts.lat = 1 + seq(0,n.partitions.lat) * partition.size.lat;
    starts.lon = 1 + seq(0,n.partitions.lon) * partition.size.lon;

    DF.output <- expand.grid(
        lat.start = starts.lat,
        lon.start = starts.lon
        );
    DF.output[,'lat.count'] <- rep(partition.size.lat,nrow(DF.output));
    DF.output[,'lon.count'] <- rep(partition.size.lon,nrow(DF.output));
    DF.output <- DF.output[,c('lat.start','lat.count','lon.start','lon.count')];

    DF.output[,'lat.count'] <- apply(
        X      = DF.output[,c('lat.start','lat.count')],
        MARGIN = 1,
        FUN    = function(x) {return(ifelse( (sum(x)-1) > length.lat, length.lat - x[1]+1, x[2] ))}
        );

    DF.output[,'lon.count'] <- apply(
        X      = DF.output[,c('lon.start','lon.count')],
        MARGIN = 1,
        FUN    = function(x) {return(ifelse( (sum(x)-1) > length.lon, length.lon - x[1]+1, x[2] ))}
        );

    DF.output[,'lat.stop'] <- DF.output[,'lat.start'] + DF.output[,'lat.count'] - 1;
    DF.output[,'lon.stop'] <- DF.output[,'lon.start'] + DF.output[,'lon.count'] - 1;

    DF.output <- DF.output[,c('lat.start','lat.stop','lat.count','lon.start','lon.stop','lon.count')];

    cat("\nDF.output\n");
    print( DF.output   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # return( DF.output );
    return( NULL );

    }
