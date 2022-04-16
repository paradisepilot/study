
section.02.02 <- function(
    ) {

    thisFunctionName <- "section.02.02";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(spData);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\ntypeof(spData::world)\n");
    print( typeof(spData::world)   );

    cat("\nclass(spData::world)\n");
    print( class(spData::world)   );

    cat("\nnames(spData::world)\n");
    print( names(spData::world)   );

    cat("\ncolnames(spData::world)\n");
    print( colnames(spData::world)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    png.output <- "figure-02-03.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "transparent");
    plot(world);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nsummary(world[,'lifeExp'])\n");
    print( summary(world[,'lifeExp'])   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    world_mini <- world[1:10,1:3];
    cat("\nworld_mini\n");
    print( world_mini   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    png.output <- "figure-02-04-left.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "transparent");
    plot(world[3:6]);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    png.output <- "figure-02-04-right.png";
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "transparent");
    plot(world[,'pop']);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    png.output <- "figure-02-04-z-not-shown.png";

    cat("\nstr(world[,'continent'])\n");
    print( str(world[,'continent'])   );

    cat("\nst_drop_geometry(world[,'continent'])\n");
    print( st_drop_geometry(world[,'continent'])   );

    cat("\nworld[,'continent']\n");
    print( world[,'continent']   );

    # world_asia <- world[world$continent == "Asia",];
    world_asia <- world[st_drop_geometry(world[,'continent']) == "Asia",];
    asia       <- st_union(world_asia);

    png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "transparent");
    plot(world[,'pop'], reset = FALSE);
    plot(asia, add = TRUE, col = "red");
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    png.output <- "figure-02-05.png";
    world_centroids <- st_centroid(world, of_largest = TRUE);
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300, bg = "transparent");
    plot(world[,'continent'], reset = FALSE);
    plot(
        add = TRUE,
        x   = st_geometry(world_centroids),
        cex = sqrt(as.numeric(as.data.frame(st_drop_geometry(world[,'pop']))[,1])) / 5000
        );
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    png.output <- "figure-02-06.png";
    india <- world[st_drop_geometry(world[,'name_long']) == "India",];
    png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    plot(reset = FALSE, x = st_geometry(india), expandBB = c(0, 0.2, 0.1, 1), col = "gray", lwd = 5);
    plot(add = TRUE, x = world_asia[0]);
    dev.off();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    my.points <- list(
        sf::st_point(x = c(5,2)                 ),
        sf::st_point(x = c(5,2,3)               ),
        sf::st_point(x = c(5,2,1),   dim = 'XYM'),
        sf::st_point(x = c(5,2,3,1)             )
        );

    for ( my.point in my.points ) {
        cat("\n");
        print( class( my.point) );
        print( typeof(my.point) );
        print( str(   my.point) );
        }
    cat("\n");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    multipoint.as.matrix <- rbind(
        c(5,2),
        c(1,3),
        c(3,4),
        c(3,2)
        );

    linestring.as.matrix <- rbind(
        c(1,5),
        c(4,4),
        c(4,1),
        c(2,2),
        c(3,2)
        );

    polygon.as.list.of.matrices <- list(
        outer.boundary = rbind(c(1,5),c(2,2),c(4,1),c(4,4),c(1,5)),
        inner.boundary = rbind(c(2,4),c(3,4),c(3,3),c(2,3),c(2,4))
        );

    multilinestring.as.list.of.matrices <- list(
        rbind(c(1,5),c(4,4),c(4,1),c(2,2),c(3,2)),
        rbind(c(1,2),c(2,4))
        );

    multipolygon.as.list.of.lists.of.matrices <- list(
        polygon.as.list.of.matrices,
        list(rbind(c(0,2),c(1,2),c(1,3),c(0,3),c(0,2)))
        );

    list.geometry.collection <- list(
        multiple.points       = st_multipoint(          multipoint.as.matrix                   ),
        piecewise.linear.path = st_linestring(          linestring.as.matrix                   ),
        polygon.with.hole     = st_polygon(                polygon.as.list.of.matrices         ),
        multi.linestring      = st_multilinestring(multilinestring.as.list.of.matrices         ),
        multi.polygon         = st_multipolygon(      multipolygon.as.list.of.lists.of.matrices)
        );

    sf.geometry.collection <- st_geometrycollection(list.geometry.collection);

    cat("\nclass(sf.geometry.collection)\n");
    print( class(sf.geometry.collection)   );

    cat("\nstr(sf.geometry.collection)\n");
    print( str(sf.geometry.collection)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
