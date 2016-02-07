
readConfig <- function(config = NULL) {
	require(yaml);
	LIST.config <- yaml.load_file(input = config);
	return(LIST.config);
	}

