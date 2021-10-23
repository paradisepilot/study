
compute.and.save.fpc.scores <- function(
    ncdf4.spatiotemporal = NULL,
    RData.trained.engine = NULL,
    variable             = NULL,
    ncdf4.output         = NULL,
    n.cores              = NULL
    ) {

    thisFunctionName <- "compute.and.save.fpc.scores";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.partitions <- compute.and.save.fpc.scores_get.DF.partitions(
        ncdf4.spatiotemporal = ncdf4.spatiotemporal
        );
    base::gc();
    cat("\nstr(DF.partitions)\n");
    print( str(DF.partitions)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    compute.and.save.fpc.scores_parallel(
        DF.partitions        = DF.partitions,
        ncdf4.spatiotemporal = ncdf4.spatiotemporal,
        RData.trained.engine = RData.trained.engine,
        variable             = variable,
        n.cores              = n.cores
        );
    base::gc();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # remove(list = c("DF.partitions"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
compute.and.save.fpc.scores_parallel <- function(
    DF.partitions        = NULL,
    ncdf4.spatiotemporal = NULL,
    RData.trained.engine = NULL,
    variable             = NULL,
    n.cores              = NULL
    ) {

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(foreach);
    require(parallel);
    require(doParallel);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    doParallel::registerDoParallel(n.cores);

  # foreach ( partition.index = seq(1,4) ) %dopar% {
    foreach ( batch.index = seq(1,nrow(DF.partitions)) ) %dopar% {

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        lat.start <- DF.partitions[partition.index,'lat.start'];
        lon.start <- DF.partitions[partition.index,'lon.start'];

        lat.count <- DF.partitions[partition.index,'lat.count'];
        lon.count <- DF.partitions[partition.index,'lon.count'];

        parquet.file <- paste0(
            stringr::str_pad(string = lat.start, width = 5),
            "-",
            stringr::str_pad(string = lon.start, width = 5),
            ".parque"
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        directory.original <- getwd();
        directory.log      <- file.path(directory.original,"logs");
        directory.tmp      <- file.path(directory.original,"tmp" );

        if ( !dir.exists(directory.log) ) {
            dir.create(path = directory.log, recursive = TRUE);
            }

        if ( !dir.exists(directory.tmp) ) {
            dir.create(path = directory.tmp, recursive = TRUE);
            }

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        file.stem <- paste0(
            stringr::str_pad(string = lat.start, width = 5, pad = "0"),
            "-",
            stringr::str_pad(string = lon.start, width = 5, pad = "0")
            );

        file.sink.out <- paste0("sink-",file.stem,".out");
        file.sink.msg <- paste0("sink-",file.stem,".msg");

        file.sink.out <- file(description = file.path(directory.log,file.sink.out), open = "wt");
        file.sink.msg <- file(description = file.path(directory.log,file.sink.msg), open = "wt");

        sink(file = file.sink.out, type = "output" );
        sink(file = file.sink.msg, type = "message");

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");

        # print system time to log
        cat(paste0("\n##### Sys.time(): ",Sys.time(),"\n"));

        start.proc.time <- proc.time();

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        ncdf4.object.spatiotemporal <- ncdf4::nc_open(ncdf4.spatiotemporal);
        DF.tidy <- nc_getTidyData.byLatLon(
            ncdf4.object = ncdf4.object.spatiotemporal,
            varid        = variable,
            lat.start    = lat.start,
            lat.count    = lat.count,
            lon.start    = lon.start,
            lon.count    = lon.count
            );
        base::gc();
        ncdf4::nc_close(ncdf4.object.spatiotemporal);

        DF.tidy[,'lat_lon'] <- apply(
             X      = DF.tidy[,c('lat','lon')],
             MARGIN = 1,
             FUN    = function(x) { return( paste(x = x, collapse = "_") ) }
             );
        cat("\nstr(DF.tidy)\n");
        print( str(DF.tidy)   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        trained.fpc.FeatureEngine <- readRDS(RData.trained.engine);
        DF.scores <- trained.fpc.FeatureEngine$transform(
            newdata  = DF.tidy,
            location = 'lat_lon',
            date     = 'date',
            variable = variable
            );
        base::gc();
        retained.colnames <- grep(x = colnames(DF.scores), pattern = "^[0-9]+$", invert = TRUE, value = TRUE);
        DF.scores <- DF.scores[,retained.colnames];
        cat("\nstr(DF.scores)\n");
        print( str(DF.scores)   );
        arrow::write_parquet(
            x    = DF.scores,
            sink = file.path(directory.tmp,paste0("fpc-scores-",file.stem,".parquet"))
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        remove(list = c(
            "DF.scores","trained.fpc.FeatureEngine",
            "DF.tidy",
            "lat.start","lat.count","lon.start","lon.count",
            "file.stem","file.sink.out","file.sink.msg"
            ));

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        # print warning messages to log
        cat("\n##### warnings()\n")
        print(warnings());

        # print session info to log
        cat("\n##### sessionInfo()\n")
        print( sessionInfo() );

        # print system time to log
        cat(paste0("\n##### Sys.time(): ",Sys.time(),"\n"));

        # print elapsed time to log
        stop.proc.time <- proc.time();
        cat("\n##### start.proc.time() - stop.proc.time()\n");
        print( stop.proc.time - start.proc.time );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        sink(file = NULL, type = "output" );
        sink(file = NULL, type = "message");
        sink();

        Sys.sleep(time = 5);

        } # foreach () {}
    stopImplicitCluster();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    return( NULL );

    }

compute.and.save.fpc.scores_get.DF.partitions <- function(
    ncdf4.spatiotemporal = NULL,
    n.partitions.lat     = 10,
    n.partitions.lon     = 10
    ) {

    require(ncdf4);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.spatiotemporal <- ncdf4::nc_open(ncdf4.spatiotemporal);
    length.lat <- ncdf4.object.spatiotemporal[['dim']][['lat']][['len']];
    length.lon <- ncdf4.object.spatiotemporal[['dim']][['lon']][['len']];
    ncdf4::nc_close(ncdf4.object.spatiotemporal);

    cat("\nlength.lat\n");
    print( length.lat   );

    cat("\nlength.lon\n");
    print( length.lon   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    partition.size.lat <- length.lat %/% n.partitions.lat;
    partition.size.lon <- length.lon %/% n.partitions.lon;

    cat("\npartition.size.lat\n");
    print( partition.size.lat   );

    cat("\npartition.size.lon\n");
    print( partition.size.lon   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
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

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # return( DF.output );
    return( DF.output );

    }
