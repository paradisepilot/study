
train.fpc.FeatureEngine <- function(
    DF.training         = NULL,
    x                   = 'lon',
    y                   = 'lat',
    date                = 'date',
    variable            = 'VV',
    min.date            = NULL,
    max.date            = NULL,
    n.partition         = 100,
    n.order             =   3,
    n.basis             =   9,
    smoothing.parameter =   0.1,
    n.harmonics         =   7,
    RData.output        = 'trained-fpc-FeatureEngine.RData'
    ) {

    thisFunctionName <- "train.fpc.FeatureEngine";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(fpcFeatures);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( (!is.null(RData.output)) & file.exists(RData.output) ) {
        trained.fpc.FeatureEngine <- readRDS(file = RData.output);
        cat(paste0("\n",thisFunctionName,"() quits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( trained.fpc.FeatureEngine );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    y_x <- paste(x = c(y, x), collapse = "_");

    DF.training <- DF.training[,c(y,x,date,variable)];
    DF.training[,y_x] <- apply(
        X      = DF.training[,c(y,x)],
        MARGIN = 1,
        FUN    = function(x) { return(paste(x,collapse="_")) }
        );

    trained.fpc.FeatureEngine <- fpcFeatureEngine$new(
        training.data       = DF.training,
        location            = y_x,
        date                = date,
        variable            = variable,
        min.date            = min.date,
        max.date            = max.date,
        n.partition         = n.partition,
        n.order             = n.order,
        n.basis             = n.basis,
        smoothing.parameter = smoothing.parameter,
        n.harmonics         = n.harmonics
        );

    trained.fpc.FeatureEngine$fit();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( !is.null(RData.output) ) {
        saveRDS(file = RData.output, object = trained.fpc.FeatureEngine);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    remove(list = c("DF.training"))
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( trained.fpc.FeatureEngine );

    }

##################################################
