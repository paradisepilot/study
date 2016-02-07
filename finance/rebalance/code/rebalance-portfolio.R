
command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- command.arguments[1];
code.directory    <- command.arguments[2];
output.directory  <- command.arguments[3];
tmp.directory     <- command.arguments[4];

setwd(output.directory);

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
library(yaml);

source(paste(code.directory, "getAdjustmentMatrix.R",    sep = "/"));
source(paste(code.directory, "getPortfolioAdjustment.R", sep = "/"));
source(paste(code.directory, "readConfig.R",             sep = "/"));
source(paste(code.directory, "preprocessTDDownload.R",   sep = "/"));

###################################################
new.contribution <- 16000; new.contribution;

###################################################
LIST.config <- readConfig(config = paste0(data.directory,'/config.yml'));
LIST.config;

FILE.RRSP <- paste0(data.directory,'/',LIST.config[["RRSP"]]);
DF.RRSP   <- precprocessTDDownload(inputfile = FILE.RRSP);

FILE.TFSA <- paste0(data.directory,'/',LIST.config[["TFSA"]]);
DF.TFSA   <- precprocessTDDownload(inputfile = FILE.TFSA);

str(DF.RRSP);
DF.RRSP;

str(DF.TFSA);
DF.TFSA;

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###


### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

q();

existing.portfolio <- read.table(
	file         = paste0(data.directory,"/portolio-2014-04-11.csv"),
	dec          = ".",
	header       = TRUE,
	row.names    = "investment",
	sep          = "\t",
	quote        = "",
	comment.char = "#"
	);
existing.portfolio;
str(existing.portfolio);

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

q();

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
target.total.value <- new.contribution + sum(existing.portfolio[['market.value']]);

names.of.target.investments <- rownames(existing.portfolio);
target.num.of.investments <- length(names.of.target.investments);

target.weights = existing.portfolio$target.proportion / sum(existing.portfolio$target.proportion);
target.weights = as.data.frame(
	target.weights,
	row.names = names.of.target.investments
	);
target.weights;

portfolio.adjustment <- getPortfolioAdjustment(
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

###################################################
sessionInfo();

q();

