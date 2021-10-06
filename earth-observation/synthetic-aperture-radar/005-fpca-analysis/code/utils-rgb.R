
rgb.transform <- function(x,xmin,xmax) {
    temp <- 255 * (x - xmin) / (xmax - xmin) ;
    temp <- sapply(temp, FUN = function(z) {max(0,min(255,z))} );
    temp <- matrix(temp,nrow = nrow(x), ncol = ncol(x));
    return(temp);
    }
