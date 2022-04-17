
section.04.02 <- function(
    ) {

    thisFunctionName <- "section.04.02";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(dplyr);
    require(sf);
    require(spData);
    require(tidyr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nstr(nz)\n");
    print( str(nz)   );

    cat("\nstr(nz_height)\n");
    print( str(nz_height)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    png.output <- "figure-nz-height.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    par(bg = 'cadetblue2');
    plot(reset = FALSE, x = nz[,'Name'], col = "white");
    plot(add   = TRUE,  x = nz_height[,'elevation'], pch = 4, col = "red", cex = 0.5, width = 0.5);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    canterbury        <- nz %>% dplyr::filter(Name == "Canterbury");
    canterbury_height <- nz_height[canterbury,];

    cat("\nstr(canterbury)\n");
    print( str(canterbury)   );

    cat("\nstr(canterbury_height)\n");
    print( str(canterbury_height)   );

    png.output <- "figure-height-canterbury.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    par(bg = 'cadetblue2');
    plot(reset = FALSE, x = nz[,'Name'], col = "white");
    plot(add   = TRUE,  x = canterbury_height[,'elevation'], pch = 19, col = "red", cex = 0.5);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # SGBP = Sparse Geometry Binary Predicate
    sel_sgbp <- st_intersects(x = nz_height, y = canterbury);

    cat("\nclass(sel_sgbp)\n");
    print( class(sel_sgbp)   );

    cat("\nstr(sel_sgbp)\n");
    print( str(sel_sgbp)   );

    cat("\ntable(unlist(sel_sgbp))\n");
    print( table(unlist(sel_sgbp))   );

    is.in.canterbury    <- base::lengths(sel_sgbp) > 0;
    canterbury.height.2 <- nz_height[is.in.canterbury,];

    cat("\nstr(canterbury.height.2)\n");
    print( str(canterbury.height.2)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    canterbury.height.3 <- nz_height %>%
        dplyr::filter(sf::st_intersects(x = ., y = canterbury, sparse = FALSE));

    cat("\nstr(canterbury.height.3)\n");
    print( str(canterbury.height.3)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    canterbury.height.4 <- nz_height %>%
        dplyr::mutate(intersects.canterbury = sf::st_intersects(x = ., y = canterbury, sparse = FALSE)) %>%
        dplyr::filter(intersects.canterbury);

    cat("\nstr(canterbury.height.4)\n");
    print( str(canterbury.height.4)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
     my.polygon <- sf::st_polygon(x = list(rbind(c(-1,-1),c(1,-1),c(1,1),c(-1,-1))));
    sfc.polygon <- sf::st_sfc(my.polygon);

    cat("\nstr(sfc.polygon)\n");
    print( str(sfc.polygon)   );

     my.line <- sf::st_linestring(x = matrix(c(-1,-1,-0.5,1),ncol = 2));
    sfc.line <- sf::st_sfc(my.line);

    cat("\nstr(sfc.line)\n");
    print( str(sfc.line)   );

     my.points <- sf::st_multipoint(x = matrix(c(0.5,1,-1,0,0,1,0.5,1),ncol = 2));
    sfc.points <- sf::st_cast(x = sf::st_sfc(my.points), to = "POINT");

    cat("\nstr(sfc.points)\n");
    print( str(sfc.points)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nsf::st_intersects(x = sfc.points, y = sfc.polygon)\n");
    print( sf::st_intersects(x = sfc.points, y = sfc.polygon)   );

    cat("\nsf::st_intersects(x = sfc.points, y = sfc.polygon, sparse = FALSE)\n");
    print( sf::st_intersects(x = sfc.points, y = sfc.polygon, sparse = FALSE)   );

    cat("\nsf::st_disjoint(x = sfc.points, y = sfc.polygon, sparse = FALSE)[,1]\n");
    print( sf::st_disjoint(x = sfc.points, y = sfc.polygon, sparse = FALSE)[,1]   );

    cat("\nsf::st_within(x = sfc.points, y = sfc.polygon, sparse = FALSE)[,1]\n");
    print( sf::st_within(x = sfc.points, y = sfc.polygon, sparse = FALSE)[,1]   );

    cat("\nsf::st_touches(x = sfc.points, y = sfc.polygon, sparse = FALSE)[,1]\n");
    print( sf::st_touches(x = sfc.points, y = sfc.polygon, sparse = FALSE)[,1]   );

    cat("\nlengths(sf::st_is_within_distance(x = sfc.points, y = sfc.polygon, dist = 0.9)) > 0\n");
    print( lengths(sf::st_is_within_distance(x = sfc.points, y = sfc.polygon, dist = 0.9)) > 0   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    set.seed(2018);
    bb.world <- sf::st_bbox(world);

    cat("\nbb.world\n");
    print( bb.world   );

    DF.random <- tibble(
        x = runif(n = 10, min = bb.world['xmin'], max = bb.world['xmax']),
        y = runif(n = 10, min = bb.world['ymin'], max = bb.world['ymax'])
        );

    random.points <- DF.random %>%
        st_as_sf(coords = c("x","y")) %>%
        st_set_crs(4326);

    cat("\nstr(random.points)\n");
    print( str(random.points)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    world.random <- world[random.points,];

    cat("\nstr(world.random)\n");
    print( str(world.random)   );

    selected.countries <- sf::st_join(x = random.points, y = world["name_long"]);

    cat("\nstr(selected.countries)\n");
    print( str(selected.countries)   );

    png.output <- "figure-04-03a.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    par(bg = 'cadetblue2');
    plot(reset = FALSE, x = world[,'name_long'], col = "white");
    plot(add   = TRUE,  x = random.points, pch = 4, col = "black", cex = 3.0, lwd = 5);
    dev.off();

    png.output <- "figure-04-03b.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    par(bg = 'cadetblue2');
    plot(reset = FALSE, x = world[,'name_long'], col = "white");
    plot(add   = TRUE,  x = world.random[,'name_long']);
    dev.off();

    png.output <- "figure-04-03c.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    par(bg = 'cadetblue2');
    plot(reset = FALSE, x = world[,'name_long'], col = "white");
    plot(add   = TRUE,  x = selected.countries[,'name_long'], pch = 4, cex = 3.0, lwd = 5);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nstr(cycle_hire)\n");
    print( str(cycle_hire)   );

    cat("\nstr(cycle_hire_osm)\n");
    print( str(cycle_hire_osm)   );

    cat("\nst_crs(cycle_hire)\n");
    print( st_crs(cycle_hire)   );

    cat("\nst_crs(cycle_hire_osm)\n");
    print( st_crs(cycle_hire_osm)   );

    png.output <- "figure-04-04.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    # par(bg = 'cadetblue2');
    plot(reset = FALSE, x = st_geometry(cycle_hire),     col = "blue");
    plot(add   = TRUE,  x = st_geometry(cycle_hire_osm), col = "red", pch = 4);
    dev.off();

    cat("\nany(st_touches(x = cycle_hire, y = cycle_hire_osm, sparse = FALSE))\n");
    print( any(st_touches(x = cycle_hire, y = cycle_hire_osm, sparse = FALSE))   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    reprojected.cycle_hire     <- sf::st_transform(x = cycle_hire,     crs = 27700);
    reprojected.cycle_hire_osm <- sf::st_transform(x = cycle_hire_osm, crs = 27700);

    cat("\nsummary(base::lengths(sf::st_is_within_distance(x = reprojected.cycle_hire, y = reprojected.cycle_hire_osm, dist = 20)) > 0)\n");
    print( summary(base::lengths(sf::st_is_within_distance(x = reprojected.cycle_hire, y = reprojected.cycle_hire_osm, dist = 20)) > 0)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.join <- sf::st_join(x = reprojected.cycle_hire, y = reprojected.cycle_hire_osm, join = sf::st_is_within_distance, dist = 20);

    cat("\nnrow(reprojected.cycle_hire)\n");
    print( nrow(reprojected.cycle_hire)   );

    cat("\nnrow(temp.join)\n");
    print( nrow(temp.join)   );

    temp.join <- temp.join %>%
        dplyr::group_by( id ) %>%
        dplyr::summarize( capacity = mean(capacity) );

    cat("\nnrow(temp.join) == nrow(reprojected.cycle_hire)\n");
    print( nrow(temp.join) == nrow(reprojected.cycle_hire)   );

    png.output <- "figure-capacity-cycle-hire-osm.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    # par(bg = 'cadetblue2');
    plot(cycle_hire_osm["capacity"], pch = 19);
    dev.off();

    png.output <- "figure-capacity-temp-join.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    # par(bg = 'cadetblue2');
    plot(temp.join["capacity"], pch = 19);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    nz_avghgt <- nz %>%
        sf::st_join( nz_height ) %>%
        dplyr::group_by( Name ) %>%
        dplyr::summarize( mean.elevation = mean(elevation, na.rm = TRUE) );

    png.output <- "figure-04-05.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    par(bg = 'cadetblue2');
    plot(x = nz_avghgt[,'mean.elevation']);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nstr(incongruent)\n");
    print( str(incongruent)   );

    cat("\nstr(aggregating_zones)\n");
    print( str(aggregating_zones)   );

    png.output <- "figure-04-06.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    # par(bg = 'cadetblue2');
    plot(reset = FALSE, x = incongruent[,"value"]);
    # plot(add   = TRUE,  x = sf::st_geometry(aggregating_zones), lwd = 5, col = scales::alpha("black",0.5));
    plot(add   = TRUE,  x = sf::st_geometry(aggregating_zones), col = "transparent", lty = 3, lwd = 6, border = "black");
    dev.off();

    agg.aw <- sf::st_interpolate_aw(
        x         = incongruent[,"value"],
        to        = aggregating_zones,
        extensive = TRUE
        );

    cat("\nstr(agg.aw)\n");
    print( str(agg.aw)   );

    cat("\nagg.aw$value\n");
    print( agg.aw$value   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    nz.highest <- nz_height %>%
        dplyr::top_n(n = 1, wt = elevation);

    cat("\nstr(nz.highest)\n");
    print( str(nz.highest)   );

    canterbury.centroid <- sf::st_centroid(canterbury);

    cat("\nstr(canterbury.centroid)\n");
    print( str(canterbury.centroid)   );

    cat("\nsf::st_distance(nz.highest,canterbury.centroid)\n");
    print( sf::st_distance(nz.highest,canterbury.centroid)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    canter.otag <- nz %>% dplyr::filter( grepl("(Canter|Otag)",Name) );

    cat("\nstr(canter.otag)\n");
    print( str(canter.otag)   );

    cat("\nsf::st_distance( nz_height[1:3,] , canter.otag )\n");
    print( sf::st_distance( nz_height[1:3,] , canter.otag )   );

    png.output <- "figure-canter-otag.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    # par(bg = 'cadetblue2');
    plot(reset = FALSE, x = sf::st_geometry(canter.otag)[2]);
    plot(add   = TRUE,  x = sf::st_geometry(nz_height)[2:3]);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
