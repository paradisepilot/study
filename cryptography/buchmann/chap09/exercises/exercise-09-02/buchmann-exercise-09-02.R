
source("EratosthenesSieve.R");
source("TrialDivision.R");

n <- 831802500;

primes <- EratosthenesSieve(upper.bound = ceiling(sqrt(n)));

results <- TrialDivision(n = n, list.of.primes = primes)
print( results$prime.factors );
print( results$exponents );

prod(results$prime.factors ^ results$exponents);

