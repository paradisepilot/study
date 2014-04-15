
source("../code/get.adjustment.matrix.R");
source("../code/get.portfolio.adjustment.R");

existing.portfolio <- read.table(
	"portolio-2011-02-04.csv",
	dec = ".",
	header = TRUE,
	row.names = 1,
	sep = ",",
	comment.char = "#"
	);
existing.portfolio;
str(existing.portfolio);

# new.contribution <- 1139.58 + 5160 + 5000; new.contribution;
new.contribution <- 5160 + 5000; new.contribution;
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

cbind(
	adjustments,
	target.market.values,
	adjusted.values,
	existing.values,
	inception.values,
	fold
	);

sum(target.market.values);
sum(existing.values);
sum(inception.values);
sum(existing.values) / sum(inception.values);
sum(target.market.values) - sum(existing.values);
sum(adjustments);

sessionInfo();

q();

