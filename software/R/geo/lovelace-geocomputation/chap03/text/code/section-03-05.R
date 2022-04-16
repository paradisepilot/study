
section.02.05 <- function(
    ) {

    thisFunctionName <- "section.02.05";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(raster);
    require(rgdal);
    require(spData);
    require(spDataLarge);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    luxembourg <- world[sf::st_drop_geometry(world[,'name_long']) == "Luxembourg",];

    cat("\nsf::st_area(luxembourg)\n");
    print( sf::st_area(luxembourg)   );

    cat("\nsf::st_area(luxembourg) / (1000^2)\n");
    print( sf::st_area(luxembourg) / (1000^2)   );

    cat("\nunits::set_units(x = sf::st_area(luxembourg), value = km^2)\n");
    print( units::set_units(x = sf::st_area(luxembourg), value = km^2)   );

    cat("\nunits::set_units(x = sf::st_area(luxembourg), value = 'km^2')\n");
    print( units::set_units(x = sf::st_area(luxembourg), value = 'km^2')   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
