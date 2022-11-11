
test.conda_clone.install_ee <- function(
    clone.path   = "cloneCondaEnv",
    to.be.cloned = "r-reticulate"
    ) {

    thisFunctionName <- "test.conda_clone.install_ee";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(reticulate);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(clone.path) ) {
        reticulate::use_condaenv(condaenv = clone.path);
        my.python.path <- reticulate::py_config()[['python']];
    } else {
        my.python.path <- reticulate::conda_clone(
            envname = clone.path,
            clone   = to.be.cloned
            );
        reticulate::conda_install(
            envname  = clone.path,
            packages = c("earthengine-api"),
            forge    = TRUE,
            conda    = "auto"
            );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nmy.python.path\n");
    print( my.python.path   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat("\nreticulate::py_list_packages(envname = clone.path, type = 'conda')\n");
    print(
        reticulate::py_list_packages(
            envname = clone.path,
            type    = 'conda'
            )
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( my.python.path );

    }

##################################################
