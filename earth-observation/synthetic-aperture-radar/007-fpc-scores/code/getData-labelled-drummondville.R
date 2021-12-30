
getData.labelled_drummondville <- function(
    file.AGRI.AAFC   = NULL,
    file.AGRI.Quebec = NULL,
    file.EESD        = NULL,
    parquet.output   = "data-labelled.parquet"
    ) {

    thisFunctionName <- "getData.labelled_drummondville";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

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
    DF.EESD[,'land_cover'] <- tolower(  DF.EESD[,'land_cover']);
    DF.EESD[,'land_cover'] <- as.factor(DF.EESD[,'land_cover']);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.output <- DF.EESD;

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
    DF.colour.scheme <- data.frame(
        land_cover = c("blue","green",    "grey"),
        colour     = c("blue","darkgreen","red" )
        );
    rownames(DF.colour.scheme) <- DF.colour.scheme[,"land_cover"];
    return(DF.colour.scheme);
    }
