
getPortfolio <- function(
	raw.RRSP = NULL,
	raw.TFSA = NULL
	) {

	DF.RRSP   <- precprocessTDDownload(inputfile = raw.RRSP, account = "RRSP");
	DF.TFSA   <- precprocessTDDownload(inputfile = raw.TFSA, account = "TFSA");

	DF.portfolio <- rbind(DF.RRSP,DF.TFSA);
	DF.portfolio <- cbind(
		DF.portfolio,
		proportion = DF.portfolio[['marketValue']] / sum(DF.portfolio[['marketValue']]),
		growth     = DF.portfolio[['marketValue']] / DF.portfolio[['bookValue']]
		);

	return(DF.portfolio);

	}

