
pMinusOne <- function(
	n                = NULL,
	loop.bound       = 47 * 10,
	num.bases.to.try = 100
	) {

	require(schoolmath);

	for (b in 1:num.bases.to.try) {
		A.to.i = sample(x = seq(2,n), size = 1);
		for (i in seq(1:loop.bound)) {
			A.to.i   <- RepeatedSquaring(base = A.to.i, exponent = i, modulus = n);
			temp.gcd <- gcd(A.to.i - 1,n);
			print(paste0("b = ",b,", i = ",i,", A.to.i = ",A.to.i,", gcd = ",temp.gcd));
			if (1 < temp.gcd & temp.gcd < n){ return(temp.gcd); }
			if (n == temp.gcd){ break; }
			}
		}

	return(NULL);

	}

