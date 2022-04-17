
section.03.03 <- function(
    ) {

    thisFunctionName <- "section.03.03";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(raster);
    require(rgdal);
    require(spData);
    require(spDataLarge);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    elevation.raster <- raster::raster(
        nrows =  6,
        ncols =  6,
        res   =  0.5,
        xmn   = -1.5,
        xmx   =  1.5,
        ymn   = -1.5,
        ymx   =  1.5,
        vals  = 1:36
        );

    cat("\nstr(elevation.raster)\n");
    print( str(elevation.raster)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    soil.types <- c('clay','silt','sand');
    grain.factor <- factor(
        x      = sample(x = soil.types, size = 36, replace = TRUE),
        levels = soil.types
        );

    grain.raster <- raster::raster(
        nrows =  6,
        ncols =  6,
        res   =  0.5,
        xmn   = -1.5,
        xmx   =  1.5,
        ymn   = -1.5,
        ymx   =  1.5,
        vals  = grain.factor
        );

    cat("\nstr(grain.raster)\n");
    print( str(grain.raster)   );

    cat("\nraster::ratify(grain.raster)\n");
    print( raster::ratify(grain.raster)   );

    cat("\ngrain.raster@data@attributes[[1]]\n");
    print( grain.raster@data@attributes[[1]]   );

    cat("\nlevels(grain.raster)\n");
    print( levels(grain.raster)   );

    cat("\nraster::factorValues(x = grain.raster, v = raster::getValues(grain.raster))\n");
    print( raster::factorValues(x = grain.raster, v = raster::getValues(grain.raster))   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my.raster.stack <- raster::stack(elevation.raster,grain.raster);

    cat("\nnames(my.raster.stack)\n");
    print( names(my.raster.stack)   );

    names(my.raster.stack) <- c('elevation','grain');

    cat("\nnames(my.raster.stack)\n");
    print( names(my.raster.stack)   );

    cat("\nstr(my.raster.stack)\n");
    print( str(my.raster.stack)   );

    cat("\nstr(my.raster.stack[['elevation']])\n");
    print( str(my.raster.stack[['elevation']])   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nmy.raster.stack\n");
    print( my.raster.stack   );

    cat("\nsummary(elevation.raster)\n");
    print( summary(elevation.raster)   );

    cat("\nsummary(grain.raster)\n");
    print( summary(grain.raster)   );

    cat("\nraster::cellStats(x = my.raster.stack, stat = sd)\n");
    print( raster::cellStats(x = my.raster.stack, stat = sd)   );

    cat("\nraster::cellStats(x = my.raster.stack, stat = summary)\n");
    print( raster::cellStats(x = my.raster.stack, stat = summary)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # raster.filepath <- system.file(file.path("raster","srtm.tif"), package = "spDataLarge");
    # raster.object   <- raster::raster(raster.filepath);
    #
    # cat("\nraster.object\n");
    # print( raster.object   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # png.output <- "figure-02-12.png";
    # png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "white");
    # plot(raster.object);
    # dev.off();
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # cat("\nraster::writeFormats()\n");
    # print( raster::writeFormats()   );
    #
    # cat("\nrgdal::gdalDrivers()\n");
    # print( rgdal::gdalDrivers()   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # raster.object.2 <- raster::raster(
    #     nrow =  6,
    #     ncol =  6,
    #     res  =  0.5,
    #     xmn  = -1.5,
    #     xmx  =  1.5,
    #     ymn  = -1.5,
    #     ymx  =  1.5,
    #     vals = 1:36
    #     );
    #
    # cat("\nraster.object.2\n");
    # print( raster.object.2   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # brick.landsat <- raster::brick(
    #     x = system.file(file.path("raster","landsat.tif"), package = "spDataLarge")
    #     );
    #
    # cat("\nbrick.landsat\n");
    # print( brick.landsat   );
    #
    # cat("\nnlayers(brick.landsat)\n");
    # print( nlayers(brick.landsat)   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # raster.layer.1 <- raster::raster(x = brick.landsat, layer = 1);
    # raster.layer.2 <- raster::raster(
    #     xmn        = raster.layer.1@extent@xmin,
    #     xmx        = raster.layer.1@extent@xmax,
    #     ymn        = raster.layer.1@extent@ymin,
    #     ymx        = raster.layer.1@extent@ymax,
    #     resolution = raster::res(raster.layer.1)
    #     );
    # crs(raster.layer.2) <- crs(raster.layer.1);
    # values(raster.layer.2) <- sample(
    #     base::seq_len(raster::ncell(raster.layer.2))
    #     );
    #
    # my.sf.stack <- raster::stack(
    #     raster.layer.1,
    #     raster.layer.2
    #     );
    #
    # cat("\nmy.sf.stack\n");
    # print( my.sf.stack   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
