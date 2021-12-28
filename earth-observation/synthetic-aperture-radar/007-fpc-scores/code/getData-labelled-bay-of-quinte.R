
getData.labelled_bay.of.quinte <- function(
    data.directory     = NULL,
    colname.pattern    = NULL,
    exclude.years      = NULL,
    exclude.land.types = NULL,
    land.cover         = NULL,
    parquet.output     = "data-labelled.parquet"
    ) {

    thisFunctionName <- "getData.labelled_bay.of.quinte";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(parquet.output) ) {
        DF.output <- arrow::read_parquet(file = parquet.output);
        cat(paste0("\n",thisFunctionName,"() exits."));
        cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
        return( DF.output );
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    initial.directory <- getwd();

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    temp.directory <- file.path(initial.directory,"data");
    if ( !dir.exists(temp.directory) ) {
        dir.create(path = temp.directory, recursive = TRUE);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    years <- getData.labelled_bay.of.quinte_getYears(
        data.directory = data.directory,
        exclude.years  = exclude.years
        );

    cat(paste0("\n# ",thisFunctionName,"(): years:","\n"));
    print( years );

    DF.output <- data.frame();
    for ( temp.year in years ) {

        list.data <- getData.labelled_bay.of.quinte_helper(
            data.directory     = data.directory,
            year               = temp.year,
            exclude.land.types = exclude.land.types,
            output.file        = file.path(temp.directory,paste0("data-",temp.year,"-raw.RData"))
            );

        cat(paste0("\nstr(list.data) -- ",temp.year,"\n"));
        print(        str(list.data) );

        DF.data.reshaped <- reshapeData(
            list.input      = list.data,
            colname.pattern = colname.pattern,
            land.cover      = land.cover,
            output.file     = file.path(temp.directory,paste0("data-",temp.year,"-reshaped.RData"))
            );

        cat(paste0("\nstr(DF.data.reshaped) -- ",temp.year,"\n"));
        print(        str(DF.data.reshaped) );

        DF.output <- rbind(DF.output,DF.data.reshaped);

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if (!is.null(parquet.output)) {
        arrow::write_parquet(x = DF.output, sink = parquet.output);
        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    remove(list = c("list.data"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() exits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( DF.output );

    }

##################################################
getData.labelled_bay.of.quinte_getYears <- function(data.directory = NULL, exclude.years = NULL) {
    require(stringr);
    temp.files <- list.files(path = data.directory);
    if ( !is.null(exclude.years) ) {
        temp.files <- grep(x = temp.files, pattern = exclude.years, value = TRUE, invert = TRUE)
        }
    years <- sort(unique(as.character(
        stringr::str_match(string = temp.files, pattern = "[0-9]{4}")
        )));
    return( years );
    }

getData.labelled_bay.of.quinte_helper <- function(
    data.directory     = NULL,
    year               = NULL,
    exclude.land.types = NULL,
    output.file        = NULL
    ) {

    thisFunctionName <- "getData.labelled_bay.of.quinte_helper";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n# ",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    require(readr);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    if ( file.exists(output.file) ) {

        cat(paste0("\n### ",output.file," already exists; loading this file ...\n"));

        list.data.raw <- readRDS(file = output.file);

        cat(paste0("\n### Finished loading raw data.\n"));

    } else {

        temp.files.given.year <- list.files(path = data.directory, pattern = year);

        cat(paste0("\n# ",thisFunctionName,"(): temp.files.given.year:\n"));
        print( temp.files.given.year );

        land.types <- unique(gsub(
            x           = temp.files.given.year,
            pattern     = "_IW_20[0-9]{2}_.+",
            replacement = ""
            ));

        cat(paste0("\n# ",thisFunctionName,"(): land.types:\n"));
        print( land.types );

        if ( !is.null(exclude.land.types) ) {
            land.types <- setdiff( land.types, exclude.land.types );
            }

        list.data.raw <- list();
        for ( land.type in land.types ) {

            temp.file <- grep(x = temp.files.given.year, pattern = land.type, value = TRUE);
            DF.temp <- as.data.frame(readr::read_csv(
                file = file.path(data.directory,temp.file)
                ));

            cat("\nfile.path(data.directory,temp.file)\n");
            print( file.path(data.directory,temp.file)   );

            cat("\nstr(DF.temp)\n");
            print( str(DF.temp)   );

            colnames(DF.temp) <- getData.labelled_bay.of.quinte_fix.colnames( input.colnames = colnames(DF.temp) );

            cat("\nstr(DF.temp)\n");
            print( str(DF.temp)   );

            retained.colnames <- grep(x = colnames(DF.temp), pattern = "Unnamed", ignore.case = TRUE, value = TRUE, invert = TRUE);
            DF.temp <- DF.temp[,retained.colnames];

            # The following is a special patch for the 2020-02-24.02 data snapshot.
            # It turns out that the agriculture data in this snapshot does NOT have
            # the timepoint 2017-09-02, while data for the other wetland types do
            # have that timepoint. If unmitigated, this would in all agricultural
            # lands in 2017 being dropped from the analysis.
            # The following patch is to add this timepoint for the 2017 agricultural
            # lands, and the value of the tree variables at the added timepoint is simply
            # the mean of the preceding and following timepoints.
            # if ( beam.mode == "IW106" & land.type == "ag" & year == "2017" ) {
            #     DF.temp[,"S1_IW106_20170902_VH"   ] <- (DF.temp[,"S1_IW106_20170821_VH"   ] + DF.temp[,"S1_IW106_20170914_VH"   ])/2;
            #     DF.temp[,"S1_IW106_20170902_VV"   ] <- (DF.temp[,"S1_IW106_20170821_VV"   ] + DF.temp[,"S1_IW106_20170914_VV"   ])/2;
            #     DF.temp[,"S1_IW106_20170902_angle"] <- (DF.temp[,"S1_IW106_20170821_angle"] + DF.temp[,"S1_IW106_20170914_angle"])/2;
            #     }

            list.data.raw[[ land.type ]] <- DF.temp;

            }

        if (!is.null(output.file)) {
            saveRDS(object = list.data.raw, file = output.file);
            }

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n# ",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( list.data.raw );

    }

getData.labelled_bay.of.quinte_fix.colnames <- function(input.colnames = NULL) {

    thisFunctionName <- "getData.labelled_bay.of.quinte_fix.colnames";

    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    output.colnames <- input.colnames;

    output.colnames <- gsub(
        x           = output.colnames,
        pattern     = "POINT_X",
        replacement = "X"
        );

    output.colnames <- gsub(
        x           = output.colnames,
        pattern     = "POINT_Y",
        replacement = "Y"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    # standardize order of components in column names
    output.colnames <- as.character(sapply(
        X   = output.colnames,
        FUN = function(x) {
            y <- unlist(strsplit(x = x, split = "_"));
            if ( length(y) > 1 ) {
                y <- c(y[1],paste0(y[2],y[5]),paste0(y[3],y[4]),y[6]);
                y <- paste(y,collapse = "_");
                }
            return(y);
            }
        ));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    output.colnames <- gsub(
        x           = output.colnames,
        pattern     = "X1",
        replacement = "row_index"
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    return( output.colnames );

    }

getData.labelled_bay.of.quinte_colour.scheme <- function() {
    DF.colour.scheme <- data.frame(
        land_cover = c("marsh",  "swamp",  "water",  "forest", "ag",     "shallow"),
        colour     = c("#000000","#E69F00","#56B4E9","#009E73","#F0E442","red"    )
        );
    rownames(DF.colour.scheme) <- DF.colour.scheme[,"land_cover"];
    return(DF.colour.scheme);
    }

# getData_add.dBZ.variables <- function(DF.input = NULL) {
#     DF.output <- DF.input;
#     temp.colnames <- grep(x = colnames(DF.output), pattern = "cov_matrix_real_comp", value = TRUE);
#     for ( temp.colname in temp.colnames ) {
#         new.colname <- paste0(temp.colname,"_dBZ");
#         DF.output[,new.colname] <- 10 * log10(DF.output[,temp.colname]);
#         }
#     colnames(DF.output) <- gsub(
#         x           = colnames(DF.output),
#         pattern     = "cov_matrix_real_comp_1_dBZ",
#         replacement = "dBZ_cov_comp_1"
#         );
#     colnames(DF.output) <- gsub(
#         x           = colnames(DF.output),
#         pattern     = "cov_matrix_real_comp_2_dBZ",
#         replacement = "dBZ_cov_comp_2"
#         );
#     colnames(DF.output) <- gsub(
#         x           = colnames(DF.output),
#         pattern     = "cov_matrix_real_comp_3_dBZ",
#         replacement = "dBZ_cov_comp_3"
#         );
#     colnames(DF.output) <- gsub(
#         x           = colnames(DF.output),
#         pattern     = "cov_matrix_real_comp_4_dBZ",
#         replacement = "dBZ_cov_comp_4"
#         );
#     return(DF.output);
#     }
