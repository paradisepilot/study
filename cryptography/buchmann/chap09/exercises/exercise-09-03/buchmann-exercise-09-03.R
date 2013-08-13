
source("../../../code/EratosthenesSieve.R");
source("../../../code/TrialDivision.R");
source("../../../code/RepeatedSquaring.R");

####################################################################################################
RepeatedSquaring(base = 3, exponent = 23, modulus = 5);

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

