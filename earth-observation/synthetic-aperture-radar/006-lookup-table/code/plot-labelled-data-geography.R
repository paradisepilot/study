
plot.labelled.data.geography <- function(
    DF.nearest.lat.lon   = NULL,
    ncdf4.spatiotemporal = NULL,
    plot.date            = as.Date("2019-07-23"),
    DF.colour.scheme     = NULL
    ) {

    thisFunctionName <- "plot.labelled.data.geography";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n"));

    require(terrainr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.spatiotemporal <- ncdf4::nc_open(ncdf4.spatiotemporal);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.date <- nc_getTidyData.byDate(
        ncdf4.object   = ncdf4.object.spatiotemporal,
        date.requested = plot.date
        );

    cat("\nstr(DF.date)\n");
    print( str(DF.date)   );
    cat("\nsummary(DF.date)\n");
    print( summary(DF.date)   );

    plot.labelled.data.geography_ggplot(
       current.date     = plot.date,
       DF.input         = DF.date,
       DF.lat.lon       = DF.nearest.lat.lon,
       DF.colour.scheme = DF.colour.scheme
       );

    remove(list = c('DF.date','temp.date'));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4::nc_close(ncdf4.object.spatiotemporal);
    remove(list = c('ncdf4.object.spatiotemporal'));
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
plot.labelled.data.geography_ggplot <- function(
    current.date     = NULL,
    DF.input         = NULL,
    DF.lat.lon       = NULL,
    DF.colour.scheme = NULL
    ) {

    require(ggplot2);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.temp <- DF.input;
    remove(list = c('DF.input'));

    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = "Sigma0_", replacement = "");
    colnames(DF.temp) <- gsub(x = colnames(DF.temp), pattern = "_db",     replacement = "");

    DF.temp[,'VV.over.VH'] <- DF.temp[,'VV'] / DF.temp[,'VH'];

    for ( temp.colname in c('VV','VH','VV.over.VH') ) {
        DF.temp[,temp.colname] <- rgb.transform(x = DF.temp[,temp.colname]);
        }

    DF.temp[is.nan(DF.temp[,'VV'        ]),'VV'        ] <- 255;
    DF.temp[is.nan(DF.temp[,'VH'        ]),'VH'        ] <- 255;
    DF.temp[is.nan(DF.temp[,'VV.over.VH']),'VV.over.VH'] <- 255;

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    SF.lat.lon <- sf::st_as_sf(
        x      = DF.lat.lon,
      # coords = c("lon", "lat")
        coords = c('nearest.lon','nearest.lat')
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my.ggplot <- ggplot2::ggplot(data = NULL) + ggplot2::theme_bw();

    # if ( !is.null(DF.colour.scheme) ) {
    #     my.ggplot <- my.ggplot + ggplot2::scale_colour_manual(values = DF.colour.scheme[,"colour"]);
    #     my.ggplot <- my.ggplot + ggplot2::scale_fill_manual(  values = DF.colour.scheme[,"colour"]);
    #     }

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

    my.ggplot <- my.ggplot + ggplot2::geom_sf(
        data  = SF.lat.lon,
        color = "white",
        size  = 0.5
        );

    for ( temp.land.cover in levels(DF.lat.lon[,'land_cover']) ) {
        temp.SF <- sf::st_as_sf(
            x      = DF.lat.lon[temp.land.cover == DF.lat.lon[,'land_cover'],],
            coords = c('nearest.lon','nearest.lat')
            );
        temp.colour <- DF.colour.scheme[temp.land.cover == DF.colour.scheme[,'land_cover'],'colour'];
        my.ggplot <- my.ggplot + ggplot2::geom_sf(
            data    = temp.SF,
            color   = temp.colour,
            size    = 0.1
            );
        }

    range.lat <- sum(range(DF.temp[,'lat']) * c(-1,1));
    range.lon <- sum(range(DF.temp[,'lon']) * c(-1,1));

    file.png <- paste0("plot-labelled-data-geography-",format(current.date,"%Y-%m-%d"),".png");
    ggplot2::ggsave(
        filename = file.png,
        plot     = my.ggplot,
        # scale  = 1,
        width    = 16,
        height   = 16 * (range.lat/range.lon),
        units    = "in",
        dpi      = 600
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    remove(list = c('DF.temp','my.ggplot','range.lat','range.lon','file.png'));
    return( NULL );

   }
