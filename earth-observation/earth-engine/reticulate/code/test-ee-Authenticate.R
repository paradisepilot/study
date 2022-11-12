
test.ee_Authenticate <- function(
    condaenv.gee = "condaEnvGEE"
    ) {

    thisFunctionName <- "test.ee_Authenticate";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(reticulate);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\ncondaenv.gee\n");
    print( condaenv.gee   );

    cat("\nSys.getenv('GOOGLE_APPLICATION_CREDENTIALS')\n");
    print( Sys.getenv('GOOGLE_APPLICATION_CREDENTIALS')   );

    cat("\nconda_list()\n");
    print( conda_list()   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    use_condaenv( condaenv = condaenv.gee );
    ee <- reticulate::import(module = "ee");
    ee$Authenticate(auth_mode = "appdefault");

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
