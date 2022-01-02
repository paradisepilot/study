
plot.RGB.fpc.scores <- function(
    directory.fpc.scores = NULL,
    latitude             = 'lat',
    longitude            = 'lon',
    channel.red          = 'fpc_1',
    channel.green        = 'fpc_2',
    channel.blue         = 'fpc_3',
    parquet.file.stem    = "DF-tidy-scores",
    PNG.output.file.stem = "plot-RGB-fpc-scores",
    dots.per.inch        = 300
    ) {

    thisFunctionName <- "plot.RGB.fpc.scores";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n"));

    require(arrow);
    require(terrainr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    years <- list.files(pattern = parquet.file.stem);
    years <- gsub(x = years, pattern = paste0(parquet.file.stem,"-"), replacement = "");
    years <- gsub(x = years, pattern = "\\.parquet",                  replacement = "");
    years <- sort(as.integer(years));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    array.q01.q99 <- array(
        dim      = c(length(years),3,2),
        dimnames = list(
            year     = as.character(years),
            channel  = c('channel.red','channel.green','channel.blue'),
            quantile = c('q01','q99')
            )
        );

    for ( temp.year in years ) {

        parquet.tidy.scores <- paste0(parquet.file.stem,"-",temp.year,".parquet");
        cat("\nreading: ",parquet.tidy.scores,"\n");

        DF.tidy.scores <- arrow::read_parquet(file = parquet.tidy.scores);

        temp.quantiles <- quantile(x = DF.tidy.scores[,channel.red], probs = c(0.01,0.99), na.rm = TRUE);
        array.q01.q99[as.character(temp.year),'channel.red','q01'] <- min(temp.quantiles);
        array.q01.q99[as.character(temp.year),'channel.red','q99'] <- max(temp.quantiles);

        temp.quantiles <- quantile(x = DF.tidy.scores[,channel.green], probs = c(0.01,0.99), na.rm = TRUE);
        array.q01.q99[as.character(temp.year),'channel.green','q01'] <- min(temp.quantiles);
        array.q01.q99[as.character(temp.year),'channel.green','q99'] <- max(temp.quantiles);

        temp.quantiles <- quantile(x = DF.tidy.scores[,channel.blue], probs = c(0.01,0.99), na.rm = TRUE);
        array.q01.q99[as.character(temp.year),'channel.blue','q01'] <- min(temp.quantiles);
        array.q01.q99[as.character(temp.year),'channel.blue','q99'] <- max(temp.quantiles);

        base::Sys.sleep(time = 5);
        base::remove(list = c('DF.tidy.scores'));
        base::gc();

        }

    channel.min.red   <- min(array.q01.q99[,'channel.red',  'q01']);
    channel.max.red   <- max(array.q01.q99[,'channel.red',  'q99']);

    channel.min.green <- min(array.q01.q99[,'channel.green','q01']);
    channel.max.green <- max(array.q01.q99[,'channel.green','q99']);

    channel.min.blue  <- min(array.q01.q99[,'channel.blue', 'q01']);
    channel.max.blue  <- max(array.q01.q99[,'channel.blue', 'q99']);

    cat("\nchannel.min.red = ",  channel.min.red,  ", channel.max.red = ",  channel.max.red,  "\n");
    cat("\nchannel.min.green = ",channel.min.green,", channel.max.green = ",channel.max.green,"\n");
    cat("\nchannel.min.blue = ", channel.min.blue, ", channel.max.blue = ", channel.max.blue, "\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.year in years ) {

        PNG.output <- paste0(PNG.output.file.stem,"-",temp.year,".png");
        cat("\nprocessing: ",PNG.output,"\n");
        if ( file.exists(PNG.output) ) {
            cat("\nThe file ",PNG.output," already exists; will not regenerate this graphic file.\n");
        } else {
            parquet.tidy.scores <- paste0(parquet.file.stem,"-",temp.year,".parquet");
            cat("\nreading: ",parquet.tidy.scores,"\n");
            DF.tidy.scores <- arrow::read_parquet(file = parquet.tidy.scores);
            cat("\nplotting: ",parquet.tidy.scores,"\n");
            plot.RGB.fpc.scores_terrainr(
                DF.tidy.scores    = DF.tidy.scores,
                year              = temp.year,
                PNG.output        = PNG.output,
                channel.min.red   = channel.min.red,
                channel.max.red   = channel.max.red,
                channel.min.green = channel.min.green,
                channel.max.green = channel.max.green,
                channel.min.blue  = channel.min.blue,
                channel.max.blue  = channel.max.blue,
                dots.per.inch     = dots.per.inch
                );
            base::Sys.sleep(time = 5);
            base::remove(list = c('DF.tidy.scores'));
            base::gc();
            }

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
plot.RGB.fpc.scores_terrainr <- function(
    DF.tidy.scores    = NULL,
    year              = NULL,
    latitude          = 'lat',
    longitude         = 'lon',
    channel.red       = 'fpc_1',
    channel.green     = 'fpc_2',
    channel.blue      = 'fpc_3',
    channel.min.red   = -200,
    channel.max.red   =  120,
    channel.min.green =  -50,
    channel.max.green =   50,
    channel.min.blue  =  -30,
    channel.max.blue  =   50,
    textsize.title    =   50,
    textsize.subtitle =   35,
    textsize.axis     =   35,
    PNG.output        = "plot-RGB-fpc-scores.png",
    dots.per.inch     = 300
    ) {

    require(ggplot2);
    require(terrainr);

    DF.temp <- DF.tidy.scores[,c(longitude,latitude,channel.red,channel.green,channel.blue)];
    remove(list = c('DF.tidy.scores'));

    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = latitude,  replacement = "latitude" );
    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = longitude, replacement = "longitude");

    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = channel.red,   replacement = "red"  );
    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = channel.green, replacement = "green");
    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = channel.blue,  replacement = "blue" );

    # for ( temp.colname in c('red','green','blue') ) {
    #     DF.temp[,temp.colname] <- rgb.transform(x = DF.temp[,temp.colname]);
    #     }
    DF.temp[,'red'  ] <- rgb.transform(x = DF.temp[,'red'  ], xmin = channel.min.red,   xmax = channel.max.red  );
    DF.temp[,'green'] <- rgb.transform(x = DF.temp[,'green'], xmin = channel.min.green, xmax = channel.max.green);
    DF.temp[,'blue' ] <- rgb.transform(x = DF.temp[,'blue' ], xmin = channel.min.blue,  xmax = channel.max.blue );

    my.ggplot <- ggplot2::ggplot(data = NULL) + ggplot2::theme_bw();

    # my.ggplot <- my.ggplot + ggplot2::theme(
    #     plot.subtitle = ggplot2::element_text(size = textsize.title, face = "bold")
    #     );
    # my.ggplot <- my.ggplot + ggplot2::labs(title = NULL, subtitle = year);

    my.ggplot <- my.ggplot + terrainr::geom_spatial_rgb(
        data    = DF.temp,
        mapping = ggplot2::aes(
            x = longitude,
            y = latitude,
            r = red,
            g = green,
            b = blue
            )
        );

    range.y <- sum(range(DF.temp[,'latitude' ]) * c(-1,1));
    range.x <- sum(range(DF.temp[,'longitude']) * c(-1,1));

    ggplot2::ggsave(
        filename = PNG.output,
        plot     = my.ggplot,
        # scale  = 1,
        width    = 16,
        height   = 16 * (range.y/range.x),
        units    = "in",
        dpi      = dots.per.inch
        );

    remove(list = c('DF.temp','my.ggplot','range.lat','range.lon'));

    return( NULL );

    }
