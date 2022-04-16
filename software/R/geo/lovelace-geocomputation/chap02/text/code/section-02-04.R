
section.02.04 <- function(
    ) {

    thisFunctionName <- "section.02.04";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(raster);
    require(rgdal);
    require(spData);
    require(spDataLarge);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nrgdal::projInfo(type = 'proj')\n");
    print( rgdal::projInfo(type = 'proj')   );

    cat("\nrgdal::projInfo(type = 'ellps')\n");
    print( rgdal::projInfo(type = 'ellps')   );

    cat("\nrgdal::projInfo(type = 'datum')\n");
    print( rgdal::projInfo(type = 'datum')   );

    cat("\nrgdal::projInfo(type = 'units')\n");
    print( rgdal::projInfo(type = 'units')   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
