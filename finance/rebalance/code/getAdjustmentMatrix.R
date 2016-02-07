getAdjustmentMatrix <- function(original=NULL,target=NULL) {
	return(
		(target - original) %*% t(original) / sum(original^2)
		);
	}
