
RepeatedSquaring <- function(
	base     = NULL,
	exponent = NULL,
	modulus  = NULL
	) {

	current.base <- base;
	remainder <- 1;
	remaining.exponent <- exponent;

	while (remaining.exponent > 0) {
		if (1 == (remaining.exponent %% 2)) {
			remainder <- (remainder * current.base) %% modulus;
			}
		remaining.exponent <- floor(remaining.exponent / 2);
		current.base <- current.base ^ 2;
		#print(paste0("remainder = ",remainder,"  exponent = ",remaining.exponent));
		}

	return(remainder);

	}

