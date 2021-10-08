
test.terrainr <- function(
    list.data.frames = NULL
    ) {

    thisFunctionName <- "test.terrainr";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n"));

    require(terrainr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    var.names <- names(list.data.frames);
    cat("\n# var.names\n");
    print(   var.names   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.all.dates <- arrow::read_parquet(file = list.data.frames[[1]]);
    dates <- unique(DF.all.dates[,'date']);
    remove(list = c('DF.all.dates'));

    cat("\n# dates\n");
    print(   dates   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # for ( date.index in seq(15,15) ) {
    for ( date.index in seq(1,length(dates)) ) {

        temp.date <- dates[date.index];
        cat("\n# temp.date: ",format(temp.date,"%Y-%m-%d"),"\n",sep="");

        DF.date <- test.terrainr_get.DF.date(
            list.data.frames = list.data.frames,
            current.date     = temp.date
            );
        cat("\nstr(DF.date)\n");
        print( str(DF.date)   );
        cat("\nsummary(DF.date)\n");
        print( summary(DF.date)   );

        test.terrainr_plot(
           current.date = temp.date,
           DF.input     = DF.date
           );

        remove(list = c('DF.date'));

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
test.terrainr_plot <- function(
    current.date = NULL,
    DF.input     = NULL
    ) {

    require(ggplot2);

    DF.temp <- DF.input;
    remove(list = c('DF.input'));

    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = "Sigma0_", replacement = "");
    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = "_db",     replacement = "");

    DF.temp[,'VV.over.VH'] <- DF.temp[,'VV'] / DF.temp[,'VH'];

    for ( temp.colname in c('VV','VH','VV.over.VH') ) {
        DF.temp[,temp.colname] <- rgb.transform(x = DF.temp[,temp.colname]);
        }

    DF.temp[is.nan(DF.temp[,'VV'        ]),'VV'        ] <- 0;
    DF.temp[is.nan(DF.temp[,'VH'        ]),'VH'        ] <- 0;
    DF.temp[is.nan(DF.temp[,'VV.over.VH']),'VV.over.VH'] <- 0;

    my.ggplot <- ggplot2::ggplot(data = NULL) + ggplot2::theme_bw();
    my.ggplot <- my.ggplot + terrainr::geom_spatial_rgb(
        data    = DF.temp,
        mapping = ggplot2::aes(
            x = lon,
            y = lat,
            r = VV,
            g = VH,
            b = VV.over.VH
            )
        );

    range.lat <- sum(range(DF.temp[,'lat']) * c(-1,1));
    range.lon <- sum(range(DF.temp[,'lon']) * c(-1,1));

    file.png <- paste0("plot-",format(current.date,"%Y-%m-%d"),".png");
    ggplot2::ggsave(
        filename = file.png,
        plot     = my.ggplot,
        # scale  = 1,
        width    = 16,
        height   = 16 * (range.lat/range.lon),
        units    = "in",
        dpi      = 300
        );

    remove(list = c('DF.temp','my.ggplot','range.lat','range.lon','file.png'));

    return( NULL );

   }

test.terrainr_get.DF.date <- function(
    list.data.frames = NULL,
    current.date     = NULL,
    parquet.file     = paste0("data-",format(current.date,"%Y-%m-%d"),".parquet")
    ) {
    if ( file.exists(parquet.file) ) {
        DF.output <- arrow::read_parquet(file = parquet.file);
    } else {

        DF.all.dates <- arrow::read_parquet(file = list.data.frames[[1]]);
        is.selected  <- (DF.all.dates[,'date'] == current.date);
        DF.output    <- DF.all.dates[is.selected,];
        remove(list = c('DF.all.dates'));

        for ( temp.file in names(list.data.frames)[seq(2,length(list.data.frames))] ) {

            DF.all.dates <- arrow::read_parquet(file = list.data.frames[[temp.file]]);
            is.selected  <- (DF.all.dates[,'date'] == current.date);
            DF.temp      <- DF.all.dates[is.selected,];
            remove(list = c('DF.all.dates'));
            DF.output <- as.data.frame(dplyr::inner_join(
                x  = DF.output,
                y  = DF.temp,
                by = c("date","lat","lon")
                ));
            remove(list = c("DF.temp"));
            }

        arrow::write_parquet(x = DF.output, sink = parquet.file);

        }
    return( DF.output );
    }
