
test.googledrive <- function(
    pyModule.ee = NULL
    ) {

    thisFunctionName <- "test.googledrive";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(googledrive);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # googledrive::drive_auth(
    #     email = Sys.getenv("GOOGLE_ACCOUNT_EMAIL"),
    #     token = Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS"),
    #     cache = Sys.getenv("GOOGLE_DRIVE_CREDENTIALS")
    #     );

    googledrive::drive_auth(
        email = Sys.getenv("GOOGLE_ACCOUNT_EMAIL"),
        token = Sys.getenv("GOOGLE_APPLICATION_CREDENTIALS")
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.drive <- as.data.frame(googledrive::drive_find());

    # cat("\nstr(DF.drive)\n");
    # print( str(DF.drive)   );

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
