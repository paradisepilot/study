
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
        vals  = rnorm(n = 36)
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
    png.output <- "figure-elevation-histogram.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "white");
    hist(my.raster.stack[['elevation']]);
    dev.off();

    png.output <- "figure-elevation-density.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "white");
    density(my.raster.stack[['elevation']]);
    dev.off();

    png.output <- "figure-elevation-boxplot.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "white");
    boxplot(my.raster.stack[['elevation']]);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
