
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
            parquet.output  = "data-labelled.parquet"
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

        DF.colour.scheme <- getData.labelled_drummondville_colour.scheme();

        labelled.data.snapshot  <- "2021-12-26.01";
        labelled.data.directory <- file.path(data.directory,"drummondville-labelled",labelled.data.snapshot);

        file.AGRI.AAFC <- file.path(
            labelled.data.directory,
            "001-metadata-AGRI","2021-08-28.01",
            "AAFCLandCovTrnSites2020_pts_Drummondville25km.xlsx"
            );

        file.AGRI.Quebec <- file.path(
            labelled.data.directory,
            "001-metadata-AGRI","2021-08-28.01",
            "CropInsQc2020pts_90pcPure_Drum25km.xlsx"
            );

        file.EESD <- file.path(
            labelled.data.directory,
            "002-metadata-EESD","2021-10-15.01",
            "EESD_TrainingSites_Pts_AssetL1.csv"
            );

        getData.labelled_drummondville(
            file.AGRI.AAFC   = file.AGRI.AAFC,
            file.AGRI.Quebec = file.AGRI.Quebec,
            file.EESD        = file.EESD,
            parquet.output   = "data-labelled.parquet"
            );

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
