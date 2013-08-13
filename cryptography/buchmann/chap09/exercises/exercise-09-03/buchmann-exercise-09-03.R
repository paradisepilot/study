
source("../../../code/EratosthenesSieve.R");
source("../../../code/TrialDivision.R");
source("../../../code/RepeatedSquaring.R");
source("../../../code/pMinusOne.R");

####################################################################################################
#size     <- 1000;
#base     <- sample(size = size, x = seq( 2,10), replace = TRUE);
#exponent <- sample(size = size, x = seq( 5, 8), replace = TRUE);
#modulus  <- sample(size = size, x = seq(17,51), replace = TRUE);
#
#correct.remainders  <- (base ^ exponent) %% modulus;
#computed.remainders <- integer(length = size);
#for (i in 1:size) {
#	computed.remainders[i] <- RepeatedSquaring(
#		base     = base[i],
#		exponent = exponent[i],
#		modulus  = modulus[i]
#		);
#	}
#
#sum(abs(computed.remainders-correct.remainders));
#all.equal(computed.remainders,correct.remainders);
#cbind(n = (base ^ exponent), modulus, computed.remainders, correct.remainders);

####################################################################################################
n <- 138277151;

primes <- EratosthenesSieve(upper.bound = ceiling(sqrt(n)));

results <- TrialDivision(n = n, list.of.primes = primes)
print( results$prime.factors );
print( results$exponents );
print( results$unfactored );

results$unfactored * prod(results$prime.factors ^ results$exponents);

####################################################################################################
n <- results$unfactored;
print( n );

primes <- EratosthenesSieve(upper.bound = ceiling(sqrt(n)));

results <- TrialDivision(n = n, list.of.primes = primes)
print( results$prime.factors );
print( results$exponents );
print( results$unfactored );

results$unfactored * prod(results$prime.factors ^ results$exponents);

####################################################################################################
n <- results$unfactored - 1;
print( n );

primes <- EratosthenesSieve(upper.bound = ceiling(sqrt(n)));

results <- TrialDivision(n = n, list.of.primes = primes)
print( results$prime.factors );
print( results$exponents );
print( results$unfactored );

results$unfactored * prod(results$prime.factors ^ results$exponents);

####################################################################################################
n <- 11616;
print( n );

primes <- EratosthenesSieve(upper.bound = ceiling(sqrt(n)));

results <- TrialDivision(n = n, list.of.primes = primes)
print( results$prime.factors );
print( results$exponents );
print( results$unfactored );

results$unfactored * prod(results$prime.factors ^ results$exponents);

####################################################################################################
#n <- 138277151;
#n <- (3^2)*(11*5);
n <- 997 * 11617;
pMinusOne(
	n                = n,
	loop.bound       = 30,
	#num.bases.to.try = 100
	);

