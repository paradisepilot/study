
test.conda_create <- function(
    env.path = "condaEnvGEE"
    ) {

    thisFunctionName <- "test.conda_create";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(reticulate);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nenv.path\n");
    print( env.path   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(env.path) ) {
        cat("\nThe conda environment '",env.path,"' already exists; activating this conda environment ...\n");
        # got the following error when trying to use the conda environment created with conda_create
        # use_condaenv(condaenv = "condaEnvGEE")
        # Error: 'condaEnvGEE/bin/python' was not built with a shared library.
        # reticulate can only bind to copies of Python built with '--enable-shared'.
        reticulate::use_condaenv(condaenv = env.path);
        cat("\nThe conda environment '",env.path,"' has been activated ...\n");
        my.python.path <- reticulate::py_config()[['python']];
    } else {
        cat("\nConda environment creation begins: '",env.path,"'\n");
        my.python.path <- reticulate::conda_create(
            envname  = env.path,
            packages = c("earthengine-api"),
            forge    = TRUE,
            conda    = "auto"
            );
        cat("\nConda environment creation complete: '",env.path,"'\n");
        }

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
