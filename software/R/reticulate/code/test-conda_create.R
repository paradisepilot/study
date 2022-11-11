
test.conda_create <- function(
    env.path = "condaEnvGEE"
    ) {

    thisFunctionName <- "test.conda_create";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(reticulate);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(env.path) ) {
        # got the following error when trying to use the conda environment created with conda_create
        # use_condaenv(condaenv = "condaEnvGEE")
        # Error: 'condaEnvGEE/bin/python' was not built with a shared library.
        # reticulate can only bind to copies of Python built with '--enable-shared'.
        reticulate::use_condaenv(condaenv = env.path);
        my.python.path <- reticulate::py_config()[['python']];
    } else {
        my.python.path <- reticulate::conda_create(
            envname  = env.path,
            packages = c("earthengine-api"),
            forge    = TRUE,
            conda    = "auto"
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nmy.python.path\n");
    print( my.python.path   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nreticulate::py_list_packages(envname = env.path, type = 'conda')\n");
    print(
        reticulate::py_list_packages(
            envname = env.path,
            type    = "conda"
            )
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( my.python.path );

    }

##################################################
