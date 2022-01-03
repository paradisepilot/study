
getData.labelled_drummondville <- function(
    file.AGRI.AAFC   = NULL,
    file.AGRI.Quebec = NULL,
    file.EESD        = NULL,
    parquet.output   = "data-labelled.parquet"
    ) {

    thisFunctionName <- "getData.labelled_drummondville";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    require(readxl);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(parquet.output) ) {
        DF.output <- arrow::read_parquet(file = parquet.output);
        cat(paste0("\n",thisFunctionName,"() exits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( DF.output );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.EESD <- read.csv(file = file.EESD);
    colnames(DF.EESD) <- tolower(colnames(DF.EESD));

    cat("\nstr(DF.EESD)\n");
    print( str(DF.EESD)   );

    DF.EESD <- DF.EESD[,c('latitude','longitude','assetl1')];
    colnames(DF.EESD) <- gsub(
        x           = colnames(DF.EESD),
        pattern     = "^latitude$",
        replacement = "latitude.training"
        );
    colnames(DF.EESD) <- gsub(
        x           = colnames(DF.EESD),
        pattern     = "^longitude$",
        replacement = "longitude.training"
        );

    colnames(DF.EESD) <- gsub(
        x           = colnames(DF.EESD),
        pattern     = "^assetl1$",
        replacement = "land_cover"
        );
    DF.EESD[,'land_cover'] <- tolower(DF.EESD[,'land_cover']);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.AAFC <- readxl::read_xlsx(path = file.AGRI.AAFC);
    DF.AAFC <- as.data.frame(DF.AAFC);
    colnames(DF.AAFC) <- tolower(colnames(DF.AAFC));

    cat("\nstr(DF.AAFC)\n");
    print( str(DF.AAFC)   );

    DF.AAFC <- DF.AAFC[,c('lat','long','classagl2')];

    colnames(DF.AAFC) <- gsub(
        x           = colnames(DF.AAFC),
        pattern     = "^lat$",
        replacement = "latitude.training"
        );

    colnames(DF.AAFC) <- gsub(
        x           = colnames(DF.AAFC),
        pattern     = "^long$",
        replacement = "longitude.training"
        );

    colnames(DF.AAFC) <- gsub(
        x           = colnames(DF.AAFC),
        pattern     = "^classagl2$",
        replacement = "land_cover"
        );
    DF.AAFC[,'land_cover'] <- tolower(DF.AAFC[,'land_cover']);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.Quebec <- readxl::read_xlsx(path = file.AGRI.Quebec);
    DF.Quebec <- as.data.frame(DF.Quebec);
    colnames(DF.Quebec) <- tolower(colnames(DF.Quebec));

    cat("\nstr(DF.Quebec)\n");
    print( str(DF.Quebec)   );

    DF.Quebec <- DF.Quebec[,c('lat','long','classagl3')];

    colnames(DF.Quebec) <- gsub(
        x           = colnames(DF.Quebec),
        pattern     = "^lat$",
        replacement = "latitude.training"
        );

    colnames(DF.Quebec) <- gsub(
        x           = colnames(DF.Quebec),
        pattern     = "^long$",
        replacement = "longitude.training"
        );

    colnames(DF.Quebec) <- gsub(
        x           = colnames(DF.Quebec),
        pattern     = "^classagl3$",
        replacement = "land_cover"
        );
    DF.Quebec[,'land_cover'] <- tolower(DF.Quebec[,'land_cover']);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nunique(DF.AAFC[,'land_cover'])\n");
    print( unique(DF.AAFC[,'land_cover'])   );

    cat("\nunique(DF.Quebec[,'land_cover'])\n");
    print( unique(DF.Quebec[,'land_cover'])   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nstr(DF.EESD)\n");
    print( str(DF.EESD)   );

    cat("\nstr(DF.AAFC)\n");
    print( str(DF.AAFC)   );

    cat("\nstr(DF.Quebec)\n");
    print( str(DF.Quebec)   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- rbind(DF.EESD,DF.AAFC,DF.Quebec);
    DF.output[,'land_cover'] <- as.factor(DF.output[,'land_cover']);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nlevels(DF.output[,'land_cover'])\n");
    print( levels(DF.output[,'land_cover'])   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if (!is.null(parquet.output)) {
        arrow::write_parquet(x = DF.output, sink = parquet.output);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
getData.labelled_drummondville_colour.scheme <- function() {

    # DF.colour.scheme <- data.frame(
    #     land_cover = c("blue","green",    "grey"),
    #     colour     = c("blue","darkgreen","red" )
    #     );

    vector.colour.scheme <- c(
        "blue",        "blue",
        "green",       "darkgreen",
        "grey",        "red",
        "barebuiltup", "black",
        "canola",      "black",
        "corn",        "black",
        "drybeans",    "black",
        "forestshrub", "black",
        "fruits",      "black",
        "greenfeed",   "black",
        "potatoes",    "black",
        "smallgrains", "black",
        "soybeans",    "black",
        "vegetables",  "black",
        "water",       "black",
        "wetland",     "black"
        );

    DF.colour.scheme <- as.data.frame(
        x = matrix(
            data     = vector.colour.scheme,
            ncol     = 2,
            byrow    = TRUE,
            dimnames = list(c(),c('land_cover','colour'))
            )
        );
    rownames(DF.colour.scheme) <- DF.colour.scheme[,"land_cover"];

    return(DF.colour.scheme);
    }
