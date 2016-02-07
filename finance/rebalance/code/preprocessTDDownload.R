
precprocessTDDownload <- function(
	inputfile = NULL,
	sep       = "\t"
	) {

	### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
	DF.output <- read.table(
		file   = inputfile,
		sep    = sep,
		header = TRUE,
		quote  = "",
		stringsAsFactors = FALSE
		);

	### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
	DF.output <- DF.output[,setdiff(colnames(DF.output),c("Select","X"))];

	DF.output[['Investments']]    <- DF.output[['X.1']];
	DF.output[['Units.Held']]     <- DF.output[['X.2']];
	DF.output[['Price.Per.Unit']] <- DF.output[['X.3']];
	DF.output[['Market.Value']]   <- DF.output[['X.4']];
	DF.output[['X..Holdings']]    <- DF.output[['X.5']];
	DF.output[['Book.Value']]     <- DF.output[['X.6']];

	DF.output <- DF.output[,setdiff(colnames(DF.output),c("X.1","X.2","X.3","X.4","X.5","X.6"))];

	### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
	colnames(DF.output) <- gsub(
		x           = colnames(DF.output),
		pattern     = "Investments",
		replacement = "investment"
		);

	colnames(DF.output) <- gsub(
		x           = colnames(DF.output),
		pattern     = "Units.Held",
		replacement = "unitsHeld"
		);

	colnames(DF.output) <- gsub(
		x           = colnames(DF.output),
		pattern     = "Price.Per.Unit",
		replacement = "pricePerUnit"
		);

	colnames(DF.output) <- gsub(
		x           = colnames(DF.output),
		pattern     = "Market.Value",
		replacement = "marketValue"
		);

	colnames(DF.output) <- gsub(
		x           = colnames(DF.output),
		pattern     = "X..Holdings",
		replacement = "holdings"
		);

	colnames(DF.output) <- gsub(
		x           = colnames(DF.output),
		pattern     = "Book.Value",
		replacement = "bookValue"
		);

	### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
	DF.output[['investment']] <- gsub(
		x           = DF.output[['investment']],
		pattern     = "\\*\\*$",
		replacement = ""
		);

	DF.output[['investment']] <- gsub(
		x           = DF.output[['investment']],
		pattern     = "Int\'l",
		replacement = "Intl"
		);

	DF.output[['investment']] <- gsub(
		x           = DF.output[['investment']],
		pattern     = " & ",
		replacement = " and "
		);

	### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
	return(DF.output);

	}

