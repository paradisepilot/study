
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
    # cat("\nclass(spData::world)\n");
    # print( class(spData::world)   );
    #
    # cat("\nstr(spData::world)\n");
    # print( str(spData::world)   );
    #
    # cat("\ndim(spData::world)\n");
    # print( dim(spData::world)   );
    #
    # cat("\nnrow(spData::world)\n");
    # print( nrow(spData::world)   );
    #
    # cat("\nncol(spData::world)\n");
    # print( ncol(spData::world)   );
    #
    # cat("\ncolnames(spData::world)\n");
    # print( colnames(spData::world)   );
    #
    # cat("\nclass(sf::st_drop_geometry(spData::world))\n");
    # print( class(sf::st_drop_geometry(spData::world))   );
    #
    # cat("\nstr(sf::st_drop_geometry(spData::world))\n");
    # print( str(sf::st_drop_geometry(spData::world))   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # world.1 <- world %>% dplyr::select(name_long, pop);
    # cat("\ncolnames(world.1)\n");
    # print( colnames(world.1)   );
    #
    # world.2 <- world %>% dplyr::select(name_long:pop);
    # cat("\ncolnames(world.2)\n");
    # print( colnames(world.2)   );
    #
    # world.3 <- world %>% dplyr::select(-subregion, -area_km2);
    # cat("\ncolnames(world.3)\n");
    # print( colnames(world.3)   );
    #
    # world.4 <- world %>% dplyr::select(country = name_long, population.size = pop);
    # cat("\ncolnames(world.4)\n");
    # print( colnames(world.4)   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # vector.pop <- world %>% dplyr::pull(pop);
    # cat("\nstr(vector.pop)\n");
    # print( str(vector.pop)   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # countries.3.to.5 <- world %>% dplyr::slice(3:5);
    # cat("\nstr(countries.3.to.5)\n");
    # print( str(countries.3.to.5)   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # world.6 <- world %>% dplyr::filter(lifeExp > 82);
    # cat("\nstr(world.6)\n");
    # print( str(world.6)   );
    #
    # world.7 <- world %>%
    #     dplyr::filter(continent == "Asia") %>%
    #     dplyr::select(name_long, continent) %>%
    #     dplyr::slice(1:5);
    # cat("\nstr(world.7)\n");
    # print( str(world.7)   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # continents <- world %>%
    #     dplyr::select(continent,pop) %>%
    #     dplyr::group_by(continent) %>%
    #     dplyr::summarize(population.size = sum(pop, na.rm = TRUE), n.countries = n());
    # cat("\nstr(continents)\n");
    # print( str(continents)   );
    #
    # cat("\nsf::st_drop_geometry(continents)\n");
    # print( sf::st_drop_geometry(continents)   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # cat("\nstr(world)\n");
    # print( str(world)   );
    #
    # cat("\nstr(coffee_data)\n");
    # print( str(coffee_data)   );
    #
    # world.coffee <- dplyr::left_join(
    #     x  = world,
    #     y  = coffee_data,
    #     by = "name_long"
    #     );
    #
    # cat("\nstr(world.coffee)\n");
    # print( str(world.coffee)   );
    #
    # png.output <- "figure-03-01.png";
    # png(filename = png.output, width = 16, height = 8, units = "in", res = 300 ); #, bg = "transparent");
    # plot(x = world.coffee["coffee_production_2017"]);
    # dev.off();
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # world.coffee.inner <- dplyr::inner_join(
    #     x  = world,
    #     y  = coffee_data,
    #     by = "name_long"
    #     );
    #
    # cat("\nstr(world.coffee.inner)\n");
    # print( str(world.coffee.inner)   );
    #
    # cat("\nsetdiff(world$name_long,coffee_data$name_long)\n");
    # print( setdiff(world$name_long,coffee_data$name_long)   );
    #
    # cat("\nsetdiff(coffee_data$name_long,world$name_long)\n");
    # print( setdiff(coffee_data$name_long,world$name_long)   );
    #
    # coffee_data$name_long <- gsub(
    #     x           = coffee_data$name_long,
    #     pattern     = "^Congo, Dem\\. Rep\\. of$",
    #     replacement = "Democratic Republic of the Congo"
    #     );
    #
    # world.coffee.inner <- dplyr::inner_join(
    #     x  = world,
    #     y  = coffee_data,
    #     by = "name_long"
    #     );
    #
    # cat("\nstr(world.coffee.inner)\n");
    # print( str(world.coffee.inner)   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # world.pop.density <- world %>%
    #     dplyr::mutate(
    #         pop.densituy = pop / area_km2
    #         );
    #
    # cat("\nstr(world.pop.density) -- mutate\n");
    # print( str(world.pop.density)   );
    #
    # world.pop.density <- world %>%
    #     dplyr::transmute(
    #         pop.densituy = pop / area_km2
    #         );
    #
    # cat("\nstr(world.pop.density) -- transmute\n");
    # print( str(world.pop.density)   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # world.unite <- world %>%
    #     tidyr::unite(
    #         col = "continent:region_un",
    #         continent:region_un,
    #         sep = ":",
    #         remove = TRUE # remove original columns
    #         );
    #
    # cat("\nstr(world.unite)\n");
    # print( str(world.unite)   );
    #
    # world.separate <- world.unite %>%
    #     tidyr::separate(
    #         col    = "continent:region_un",
    #         into   = c("continent","region_un"),
    #         sep    = ":",
    #         remove = TRUE # remove original columns
    #         );
    #
    # cat("\nstr(world.separate)\n");
    # print( str(world.separate)   );
    #
    # ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # world.country <- world %>%
    #     dplyr::rename(
    #         country = name_long
    #         );
    #
    # cat("\nstr(world.country)\n");
    # print( str(world.country)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
