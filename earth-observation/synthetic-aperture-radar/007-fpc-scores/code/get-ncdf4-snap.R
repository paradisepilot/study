
get.ncdf4.snap <- function(
    study.area       = c("bay-of-quinte","drummondville"),
    output.directory = NULL
    ) {

    thisFunctionName <- "get.ncdf4.snap";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( "bay-of-quinte" == study.area ) {
        temp.dir   <- gsub(x = output.directory, pattern = "007-fpc-scores.+", replacement = "");
        # temp.dir <- file.path(temp.dir,"004-preprocess","02-bay-of-quinte","01-AAW","output.AAW.kc-512.2021-10-04.01");
        temp.dir   <- file.path(temp.dir,"004-preprocess","02-bay-of-quinte","01-AAW","output.AAW.kc-512.2021-10-07.01.coreg.only");
    } else if ( "drummondville" == study.area ) {
        temp.dir   <- gsub(x = output.directory, pattern = "007-fpc-scores.+", replacement = "");
        # temp.dir <- file.path(temp.dir,"004-preprocess","04-drummondville","01-AAW","output.AAW.kc-512.2021-12-25.01");
        temp.dir   <- file.path(temp.dir,"004-preprocess","04-drummondville","01-AAW","output.AAW.kc-512.2021-12-28.01");
    } else {
        error.message <- paste0("\nunrecognized study area: ",study.area,"\n");
        stop( error.message );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    ncdf4.snap <- file.path(temp.dir,"coregistered_stack.nc");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( ncdf4.snap );

    }

##################################################
