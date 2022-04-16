
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
    DF.epsg <- rgdal::make_EPSG();

    cat("\nstr(DF.epsg)\n");
    print( str(DF.epsg)   );

    cat("\nDF.epsg[1:10,]\n");
    print( DF.epsg[1:10,]   );

    cat("\nDF.epsg[DF.epsg[,'code'] == 4326,]\n");
    print( DF.epsg[DF.epsg[,'code'] == 4326,]   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    vector.object <- sf::st_read(
        dsn = system.file("vector/zion.gpkg", package = "spDataLarge")
        );

    cat("\nst_crs(vector.object)\n");
    print( st_crs(vector.object)   );

    vector.object <- sf::st_set_crs(x = vector.object, value = 4326); # WARNING: replacing CRS does not reproject data; use st_transform instead.

    cat("\nst_crs(vector.object)\n");
    print( st_crs(vector.object)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    raster.filepath <- system.file(file.path("raster","srtm.tif"), package = "spDataLarge");
    raster.object   <- raster::raster(raster.filepath);

    cat("\nraster::projection(raster.object)\n");
    print( raster::projection(raster.object)   );

    cat("\ngrep(x = DF.epsg[,'prj4'], pattern = 'utm.+zone=12.+GRS80.+no_defs', value = TRUE)\n");
    print( grep(x = DF.epsg[,'prj4'], pattern = 'utm.+zone=12.+GRS80.+no_defs', value = TRUE)   );

    raster::projection(raster.object) <- "+proj=utm +zone=12 +ellps=GRS80 +units=m +no_defs +type=crs"

    cat("\nraster::projection(raster.object)\n");
    print( raster::projection(raster.object)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
