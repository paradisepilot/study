
test.terrainr <- function(
    list.data.frames = NULL
    ) {

    thisFunctionName <- "test.terrainr";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n"));

    require(terrainr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    var.names <- names(list.data.frames);
    dates     <- unique(list.data.frames[[1]][,'date']);

    cat("\n# var.names\n");
    print(   var.names   );

    cat("\n# dates\n");
    print(   dates   );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # for ( date.index in seq(1,length(dates)) ) {
    for ( date.index in seq(15,15) ) {

        temp.date <- dates[date.index];
        cat("\n# temp.date: ",format(temp.date,"%Y-%m-%d"),"\n",sep="");

        DF.date <- test.terrainr_get.DF.date(
            list.data.frames = list.data.frames,
            current.date     = temp.date
            );
        cat("\nstr(DF.date)\n");
        print( str(DF.date)   );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( NULL );

    }

##################################################
test.terrainr_get.DF.date <- function(
    list.data.frames = NULL,
    current.date     = NULL,
    parquet.file     = paste0("data-",format(current.date,"%Y-%m-%d"),".parquet")
    ) {
    if ( file.exists(parquet.file) ) {
        DF.output <- arrow::read_parquet(file = parquet.file);
    } else {
        is.selected <- (list.data.frames[[1]][,'date'] == current.date);
        DF.output <- list.data.frames[[1]][is.selected,];
        for ( temp.var in names(list.data.frames)[seq(2,length(list.data.frames))] ) {
            is.selected <- (list.data.frames[[temp.var]][,'date'] == current.date);
            DF.temp <- list.data.frames[[temp.var]][is.selected,];
            DF.output <- merge(
                x  = DF.output,
                y  = DF.temp,
                by = setdiff(colnames(DF.output),names(list.data.frames))
                );
            }
        arrow::write_parquet(x = DF.output, sink = parquet.file);
        }
    return( DF.output );
    }
