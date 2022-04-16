
section.02.03 <- function(
    ) {

    thisFunctionName <- "section.02.03";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(raster);
    require(rgdal);
    require(spData);
    require(spDataLarge);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    raster.filepath <- system.file(file.path("raster","srtm.tif"), package = "spDataLarge");
    raster.object   <- raster::raster(raster.filepath);

    cat("\nraster.object\n");
    print( raster.object   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    png.output <- "figure-02-12.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "white");
    plot(raster.object);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nraster::writeFormats()\n");
    print( raster::writeFormats()   );

    cat("\nrgdal::gdalDrivers()\n");
    print( rgdal::gdalDrivers()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    raster.object.2 <- raster::raster(
        nrow =  6,
        ncol =  6,
        res  =  0.5,
        xmn  = -1.5,
        xmx  =  1.5,
        ymn  = -1.5,
        ymx  =  1.5,
        vals = 1:36
        );

    cat("\nraster.object.2\n");
    print( raster.object.2   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    brick.landsat <- raster::brick(
        x = system.file(file.path("raster","landsat.tif"), package = "spDataLarge")
        );

    cat("\nbrick.landsat\n");
    print( brick.landsat   );

    cat("\nnlayers(brick.landsat)\n");
    print( nlayers(brick.landsat)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    raster.layer.1 <- raster::raster(x = brick.landsat, layer = 1);
    raster.layer.2 <- raster::raster(
        xmn        = raster.layer.1@extent@xmin,
        xmx        = raster.layer.1@extent@xmax,
        ymn        = raster.layer.1@extent@ymin,
        ymx        = raster.layer.1@extent@ymax,
        resolution = raster::res(raster.layer.1)
        );
    crs(raster.layer.2) <- crs(raster.layer.1);
    values(raster.layer.2) <- sample(
        base::seq_len(raster::ncell(raster.layer.2))
        );

    my.sf.stack <- raster::stack(
        raster.layer.1,
        raster.layer.2
        );

    cat("\nmy.sf.stack\n");
    print( my.sf.stack   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
