
getData.labelled <- function(
    study.area     = c("bay-of-quinte","drummondville"),
    data.directory = NULL,
    RData.output   = "data-labelled.RData"
    ) {

    thisFunctionName <- "getData.labelled";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(RData.output) ) {
        list.output <- readRDS(file = RData.output);
        cat(paste0("\n",thisFunctionName,"() exits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( list.output );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( "bay-of-quinte" == study.area ) {

        DF.colour.scheme <- getData.labelled_bay.of.quinte_colour.scheme();

        labelled.data.snapshot  <- "2020-12-30.01";
        labelled.data.directory <- file.path(data.directory,"bay-of-quinte-labelled",labelled.data.snapshot,"micro-mission-1","Sentinel1","IW","4");
        # list.files(labelled.data.directory);

        colname.pattern <- "V";
        DF.labelled <- getData.labelled_bay.of.quinte(
            data.directory  = labelled.data.directory,
            colname.pattern = colname.pattern,
            land.cover      = DF.colour.scheme[,'land_cover'],
            parquet.output  = paste0("data-labelled.parquet")
            );
        colnames(DF.labelled) <- gsub(
            x           = colnames(DF.labelled),
            pattern     = "^X$",
            replacement = "longitude.training"
            );
        colnames(DF.labelled) <- gsub(
            x           = colnames(DF.labelled),
            pattern     = "^Y$",
            replacement = "latitude.training"
            );
        print( str(DF.labelled) );

    } else if ( "drummondville" == study.area ) {

    } else {
        error.message <- paste0("\nunrecognized study area: ",study.area,"\n");
        stop( error.message );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    list.output <- list(
        data          = DF.labelled,
        colour_scheme = DF.colour.scheme
        );

    saveRDS(object = list.output, file = RData.output);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( list.output );

    }

##################################################
