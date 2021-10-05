
test.raster <- function(
    ncdf4.spatiotemporal = NULL
    ) {

    thisFunctionName <- "test.raster";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n"));

    require(raster);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.object.spatiotemppral <- ncdf4::nc_open(ncdf4.spatiotemporal);

    n.rows <- ncdf4.object.spatiotemppral[['dim']][['lat']][['len']];
    n.cols <- ncdf4.object.spatiotemppral[['dim']][['lon']][['len']];

    x.min <- min(ncdf4.object.spatiotemppral[['dim']][['lat']][['vals']]);
    x.max <- max(ncdf4.object.spatiotemppral[['dim']][['lat']][['vals']]);

    y.min <- min(ncdf4.object.spatiotemppral[['dim']][['lon']][['vals']]);
    y.max <- max(ncdf4.object.spatiotemppral[['dim']][['lon']][['vals']]);

    vv.values <- ncvar_get(
        nc    = ncdf4.object.spatiotemppral,
        varid = "Sigma0_VV_db"
        );
    vv.min <- min(vv.values);
    vv.max <- max(vv.values);

    vh.values <- ncvar_get(
        nc    = ncdf4.object.spatiotemppral,
        varid = "Sigma0_VH_db"
        );
    vh.min <- min(vh.values);
    vh.max <- max(vh.values);

    ncdf4::nc_close(ncdf4.object.spatiotemppral);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    time.index <- 15;

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\n# (n.rows,n.cols) = c(",n.rows,",",n.cols,")");
    cat("\n# (xmin,xmax) = c(",x.min,",",x.max,")");
    cat("\n# (ymin,ymax) = c(",y.min,",",y.max,")");
    cat("\n");
    cat("\n# (vv.min,vv.max) = c(",vv.min,",",vv.max,")");
    cat("\n# (vh.min,vh.max) = c(",vh.min,",",vh.max,")");
    cat("\n");
    cat("\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    vv.layer <- raster::raster(
        nrows = n.rows,
        ncols = n.cols
        #,xmn   = x.min,
        # xmx   = x.max,
        # ymn   = y.min,
        # ymx   = y.max
        );
    vv.matrix <- vv.values[time.index,,];
    raster::values(vv.layer) <- vv.matrix;
    # raster::values(vv.layer) <- rgb.transform(
    #     x    = vv.matrix,
    #     xmin = vv.min,
    #     xmax = vv.max
    #     );

    cat("\nsummary(as.vector(vv.matrix))\n");
    print( summary(as.vector(vv.matrix))   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    vh.layer <- raster::raster(
        nrows = n.rows,
        ncols = n.cols
        #,xmn   = x.min,
        # xmx   = x.max,
        # ymn   = y.min,
        # ymx   = y.max
        );
    vh.matrix <- vh.values[time.index,,];
    raster::values(vh.layer) <- vh.matrix;
    # raster::values(vh.layer) <- rgb.transform(
    #     x    = vh.matrix,
    #     xmin = vh.min,
    #     xmax = vh.max
    #     );

    cat("\nsummary(as.vector(vh.matrix))\n");
    print( summary(as.vector(vh.matrix))   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    vv.vh.layer <- raster::raster(
        nrows = n.rows,
        ncols = n.cols
        #,xmn   = x.min,
        # xmx   = x.max,
        # ymn   = y.min,
        # ymx   = y.max
        );
    vv.vh.matrix <- vv.matrix / vh.matrix;
    raster::values(vv.vh.layer) <- rgb.transform(
        x    = vv.vh.matrix,
        xmin = 0.5, # min(vv.vh.matrix),
        xmax = 1.0  # max(vv.vh.matrix)
        );

    cat("\nsummary(as.vector(vv.vh.matrix))\n");
    print( summary(as.vector(vv.vh.matrix))   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my.stack <- raster::stack(
        vv.layer,
        vh.layer,
        vv.vh.layer
        );

    cat("\nstr(my.stack)\n");
    print( str(my.stack)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    writeRaster(x = vv.layer, filename = "plot-vv.tif");
    writeRaster(x = vh.layer, filename = "plot-vh.tif");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # png("plot-vv.png");    raster::plot(vv.layer);    dev.off();
    # png("plot-vh.png");    raster::plot(vh.layer);    dev.off();
    # png("plot-stack.png"); raster::plotRGB(my.stack); dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
rgb.transform <- function(x,xmin,xmax) {
    temp <- 255 * (x - xmin) / (xmax - xmin) ;
    temp <- sapply(temp, FUN = function(z) {max(0,min(255,z))} );
    return(temp)
    }
