
decode.via.vPIC <- function(
    vPIC.connection   = NULL,
    input.vins        = NULL,
    output.value      = NULL,
    output.created.on = NULL
    ) {

    require(odbc);
    require(arrow);
    require(plyr);


    thisFunctionName <- "decode.via.vPICs";
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###");
    cat(paste0("\n",thisFunctionName,"() starts.\n\n"));

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    DF.value      <- data.frame();
    DF.created.on <- data.frame();

    for (temp.vin in input.vins) {

        vPIC.results <- odbc::dbGetQuery(
            conn      = vPIC.connection,
            statement = paste0("USE vPICList; EXEC [dbo].[spVinDecode] @v = N'",temp.vin,"'")
            );

        temp.value      <- as.data.frame(matrix(data = c(temp.vin,as.character(vPIC.results[,'Value'    ])), nrow = 1));
        temp.created.on <- as.data.frame(matrix(data = c(temp.vin,as.character(vPIC.results[,'CreatedOn'])), nrow = 1));

        colnames(temp.value)      <- c("VIN",vPIC.results[,'Code']);
        colnames(temp.created.on) <- c("VIN",vPIC.results[,'Code']);

        # NOTE: The data frame vPIC.results corresponding to different VIN's
        # may have different number of rows. Hence, the single-row data frame
        # temp.value may have different number of columns for different VIN's.
        # plyr::rbind.fill(...) is used here to stack up row vectors potentially
        # having different columns.
        DF.value      <- plyr::rbind.fill(DF.value,     temp.value     );
        DF.created.on <- plyr::rbind.fill(DF.created.on,temp.created.on);

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    arrow::write_parquet(sink = output.value,      x = DF.value     );
    arrow::write_parquet(sink = output.created.on, x = DF.created.on);

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    base::return( NULL );

    }
