
plot.RGB.fpc.scores <- function(
    CSV.partitions       = NULL,
    directory.fpc.scores = NULL,
    parquet.tidy.scores  = "DF-tidy-scores.parquet",
    PNG.output           = "plot-RGB-fpc-scores.png"
    ) {

    thisFunctionName <- "plot.RGB.fpc.scores";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n"));

    require(arrow);
    require(terrainr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !file.exists(PNG.output) ) {

        if ( file.exists(parquet.tidy.scores) ) {
            DF.tidy.scores <- arrow::read_parquet(file = parquet.tidy.scores);
        } else {
            DF.partitions  <- read.csv(file = CSV.partitions, row.names = NULL);
            DF.tidy.scores <- data.frame();
            for ( row.index in seq(1,nrow(DF.partitions)) ) {
                cat("\nprocessing DF.partitions: ",row.index," of ",nrow(DF.partitions)," rows", sep = "");
                DF.temp <- arrow::read_parquet(
                    file = file.path(directory.fpc.scores,DF.partitions[row.index,'fpc.scores.parquet'])
                    );
                DF.tidy.scores <- rbind(DF.tidy.scores,DF.temp);
                remove(list = c('DF.temp'));
                }
            cat("\n");
            remove(list = c('DF.partitions'));
            arrow::write_parquet(
                x    = DF.tidy.scores,
                sink = parquet.tidy.scores
                );
            }
        cat("\nstr(DF.tidy.scores)\n");
        print( str(DF.tidy.scores)   );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        plot.RGB.fpc.scores_terrainr(
            DF.tidy.scores = DF.tidy.scores,
            PNG.output     = PNG.output
            );

        ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
        remove(list = c('DF.tidy.scores'));

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
plot.RGB.fpc.scores_terrainr <- function(
    DF.tidy.scores = NULL,
    x              = 'lon',
    y              = 'lat',
    channel.red    = 'fpc_1',
    channel.green  = 'fpc_2',
    channel.blue   = 'fpc_3',
    PNG.output     = "plot-RGB-fpc-scores.png"
    ) {

    require(ggplot2);
    require(terrainr);

    DF.temp <- DF.tidy.scores[,c(x,y,channel.red,channel.green,channel.blue)];
    remove(list = c('DF.tidy.scores'));

    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = x, replacement = "x");
    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = y, replacement = "y");

    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = channel.red,   replacement = "red"  );
    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = channel.green, replacement = "green");
    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = channel.blue,  replacement = "blue" );

    # for ( temp.colname in c('red','green','blue') ) {
    #     DF.temp[,temp.colname] <- rgb.transform(x = DF.temp[,temp.colname]);
    #     }
    DF.temp[,'red'  ] <- rgb.transform(x = DF.temp[,'red'  ], xmin = -200, xmax = 120);
    DF.temp[,'green'] <- rgb.transform(x = DF.temp[,'green'], xmin =  -50, xmax =  50);
    DF.temp[,'blue' ] <- rgb.transform(x = DF.temp[,'blue' ], xmin =  -30, xmax =  50);

    my.ggplot <- ggplot2::ggplot(data = NULL) + ggplot2::theme_bw();
    my.ggplot <- my.ggplot + terrainr::geom_spatial_rgb(
        data    = DF.temp,
        mapping = ggplot2::aes(
            x = x,
            y = y,
            r = red,
            g = green,
            b = blue
            )
        );

    range.y <- sum(range(DF.temp[,'y']) * c(-1,1));
    range.x <- sum(range(DF.temp[,'x']) * c(-1,1));

    ggplot2::ggsave(
        filename = PNG.output,
        plot     = my.ggplot,
        # scale  = 1,
        width    = 16,
        height   = 16 * (range.y/range.x),
        units    = "in",
        dpi      = 1000
        );

    remove(list = c('DF.temp','my.ggplot','range.lat','range.lon'));

    return( NULL );

    }
