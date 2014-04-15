
source("../code/get.adjustment.matrix.R");
source("../code/get.portfolio.adjustment.R");

existing.portfolio <- read.table(
	"../data/portolio-2014-04-11.csv",
	dec          = ".",
	header       = TRUE,
	row.names    = "investment",
	sep          = "\t",
	quote        = "",
	comment.char = "#"
	);
existing.portfolio;
str(existing.portfolio);

new.contribution <- 16000; new.contribution;
target.total.value <- new.contribution + sum(existing.portfolio$market.value);

names.of.target.investments <- rownames(existing.portfolio);
target.num.of.investments <- length(names.of.target.investments);

target.weights = existing.portfolio$target.proportion / sum(existing.portfolio$target.proportion);
target.weights = as.data.frame(
	target.weights,
	row.names = names.of.target.investments
	);
target.weights;

portfolio.adjustment <- get.portfolio.adjustment(
	existing.portfolio = existing.portfolio,
	target.portfolio.weights = target.weights,
	target.portfolio.value = target.total.value
	);
portfolio.adjustment;

target.market.values <- portfolio.adjustment$target.portfolio.value * portfolio.adjustment$target.portfolio.weights;
colnames(target.market.values) <- "target.market.value";
adjustments <- as.matrix(portfolio.adjustment$adjustment.data.frame) %*% portfolio.adjustment$extended.original.portfolio$market.value;
adjusted.values <- portfolio.adjustment$extended.original.portfolio$market.value + adjustments;
existing.values <- portfolio.adjustment$extended.original.portfolio$market.value;
inception.values <- portfolio.adjustment$extended.original.portfolio$book.value;
fold <- existing.values / inception.values;

DF.output <- cbind(
	investment          = rownames(portfolio.adjustment$extended.original.portfolio),
	adjustment          = adjustments,
	target.market.value = target.market.values,
	adjusted.value      = adjusted.values,
	existing.value      = existing.values,
	inception.value     = inception.values,
	fold                = fold
	);

write.table(
	file = '../output/portfolio-rebalance-2014.csv',
	x = DF.output,
	sep = '\t',
	quote = FALSE,	
	row.names = FALSE
	);

sum(target.market.values);
sum(existing.values);
sum(inception.values);
sum(existing.values) / sum(inception.values);
sum(target.market.values) - sum(existing.values);
sum(adjustments);

sessionInfo();

q();

