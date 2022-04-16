
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
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
