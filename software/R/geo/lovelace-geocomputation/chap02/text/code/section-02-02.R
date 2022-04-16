
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
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
