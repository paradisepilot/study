
RepeatedSquaring <- function(
	base     = NULL,
	exponent = NULL,
	modulus  = NULL
	) {

	remainder <- base;
	temp.exponent <- 2*floor(exponent/2);

	print("temp.exponent");
	print( temp.exponent );

	while (temp.exponent > 1) {
		remainder <- (remainder ^ 2) %% modulus;
		temp.exponent <- temp.exponent / 2;
		print(paste0("remainder = ",remainder,"  exponent = ",temp.exponent));
		}

	if (1 == exponent %% 2) {
		remainder <- (remainder*base) %% modulus;
		}
	
	return(remainder);

	}

