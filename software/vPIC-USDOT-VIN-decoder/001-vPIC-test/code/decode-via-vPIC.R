
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

        cat(paste0("\n### temp.vin = ",temp.vin,"\n"));

        vPIC.results <- odbc::dbGetQuery(
            conn      = vPIC.connection,
            statement = paste0("USE vPICList; EXEC [dbo].[spVinDecode] @v = N'",temp.vin,"'")
            );

        temp.value      <- as.data.frame(matrix(data = c(temp.vin,vPIC.results[,'Value'    ]), nrow = 1));

        cat("\nstr(temp.value)\n");
        print( str(temp.value)   );

        temp.created.on <- as.data.frame(matrix(data = c(temp.vin,vPIC.results[,'CreatedOn']), nrow = 1));

        cat("\nstr(temp.created.on)\n");
        print( str(temp.created.on)   );

        DF.value <- plyr::rbind.fill(DF.value, temp.value);

        cat("\nstr(DF.value)\n");
        print( str(DF.value)   );

        DF.created.on <- plyr::rbind.fill(DF.created.on,temp.created.on);

        cat("\nstr(DF.created.on)\n");
        print( str(DF.created.on)   );

        }

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    arrow::write_parquet(
        sink = output.value,
        x    = DF.value
        );

    arrow::write_parquet(
        sink = output.created.on,
        x    = DF.created.on
        );

    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
    cat(paste0("\n",thisFunctionName,"() quits."));
    cat("\n### ~~~~~~~~~~~~~~~~~~~~ ###\n");
    base::return( NULL );

    }
