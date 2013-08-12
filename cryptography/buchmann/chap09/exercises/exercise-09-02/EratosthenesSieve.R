
EratosthenesSieve <- function(upper.bound = NULL) {
	
	limit         <- ceiling(sqrt(upper.bound));
	remaining     <- 2:upper.bound;
	current.prime <- 2;
	primes        <- c();
	while (current.prime < limit) {
		primes <- c(primes,current.prime);
		remaining <- setdiff(remaining,current.prime*seq(1:upper.bound));
		current.prime <- min(setdiff(remaining,primes));
		}

	return(remaining);
	
	}

