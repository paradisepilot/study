
test.googledrive <- function(
    pyModule.ee = NULL
    ) {

    thisFunctionName <- "test.googledrive";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    options(
        gargle_oauth_email = Sys.getenv("GARGLE_OAUTH_EMAIL"),
        gargle_oauth_cache = Sys.getenv("GARGLE_OAUTH_CACHE")
        );

    require(googledrive);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.drive <- as.data.frame(googledrive::drive_find());

    cat("\nDF.drive[,c('name','id')]\n");
    print( DF.drive[,c('name','id')]   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.earth.engine <- as.data.frame(googledrive::drive_ls(
        path    = "earthengine",
        pattern = "\\.tif"
        ));

    cat("\nDF.earth.engine\n");
    print( DF.earth.engine   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    for ( temp.id in DF.earth.engine[,'id'] ) {
        cat("\ndownloading:",temp.id,"\n");
        googledrive::drive_download(file = googledrive::as_id(temp.id));
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
