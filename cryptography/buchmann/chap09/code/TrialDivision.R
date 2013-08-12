
TrialDivision <- function(n = NULL, list.of.primes = NULL) {

	prime.factors <- c();
	exponents     <- c();

	index      <- 0;
	unfactored <- n;
	while (unfactored > 1 & index < length(list.of.primes)) {
		index <- 1 + index;
		current.prime = list.of.primes[index];
		if (0 == (unfactored %% current.prime)) {
			prime.factors    <- c(prime.factors,current.prime);
			unfactored       <- unfactored / current.prime;
			current.exponent <- 1;
			while (0 == unfactored %% current.prime) {
				current.exponent <- 1 + current.exponent;
				unfactored       <- unfactored / current.prime;
				}
			exponents <- c(exponents,current.exponent);
			}
		}

	LIST.output <- list(
		n              = n,
		list.of.primes = list.of.primes,
		prime.factors  = prime.factors,
		exponents      = exponents,
		unfactored     = unfactored
		);

	return(LIST.output);

	}

