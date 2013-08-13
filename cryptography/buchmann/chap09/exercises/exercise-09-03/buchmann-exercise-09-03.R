
source("../../../code/EratosthenesSieve.R");
source("../../../code/TrialDivision.R");
source("../../../code/RepeatedSquaring.R");

####################################################################################################
base <- 7; exponent <- 11; modulus <- 14;

RepeatedSquaring(base = base, exponent = exponent, modulus = modulus);
(base ^ exponent);
(base ^ exponent) %% modulus;

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

