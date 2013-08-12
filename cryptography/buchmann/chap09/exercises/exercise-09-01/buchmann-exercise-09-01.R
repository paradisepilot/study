
source("../../../code/FermatFactorization.R");

n       <- 13199;
results <- FermatFactorization(n = n, max.iterations = 100);
print( results );
print(paste0("x = ",results$x,"; y = ",results$y,"; x^2 - y^2 = ",results$x^2-results$y^2,"; n = ",n));

