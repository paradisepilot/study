
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
    cat("\nclone.path\n");
    print( clone.path   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( dir.exists(clone.path) ) {
        cat("\nThe conda environment '",clone.path,"' already exists; activating this conda environment ...\n");
        reticulate::use_condaenv(condaenv = clone.path);
        cat("\nThe conda environment '",clone.path,"' has been activated ...\n");
        my.python.path <- reticulate::py_config()[['python']];
    } else {
        cat("\nThe conda environment '",clone.path,"' does not yet exist; cloning the environment '",to.be.cloned,"' ...\n");
        cat("\nConda environment cloning begins: '",to.be.cloned,"' --> '",clone.path,"'\n");
        my.python.path <- reticulate::conda_clone(
            envname = clone.path,
            clone   = to.be.cloned
            );
        cat("\nConda environment cloning complete: '",to.be.cloned,"' --> '",clone.path,"'\n");
        cat("\nInstallation of earthengine-api begin: '",clone.path,"'\n");
        reticulate::conda_install(
            envname  = clone.path,
            packages = c("earthengine-api"),
            forge    = TRUE,
            conda    = "auto"
            );
        cat("\nInstallation of earthengine-api complete: '",clone.path,"'\n");
        }

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
