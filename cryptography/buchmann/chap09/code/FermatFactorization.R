
FermatFactorization <- function(n = NULL, max.iterations = NULL) {

	x <- ceiling(sqrt(n));
	y <- 0;

	# Fermat Factorization Algorithm
	count <- 0;
	while (count < max.iterations) {
		count <- 1 + count;
		temp <- x^2 - y^2 - n;
		if (0 == temp) {
			LIST.output <- list( num.iterations = count, x = x, y = y, n = n);
			return(LIST.output);
		} else if (0 < temp) {
			while (0 < x^2 - y^2 - n) {
				y <- 1 + y;
				}
		} else {
			x <- 1 + x;
		}
	}

	return(NULL);

}

