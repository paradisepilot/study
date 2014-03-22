
command.arguments <- commandArgs(trailingOnly = TRUE);
data.directory    <- command.arguments[1];
code.directory    <- command.arguments[2];
output.directory  <- command.arguments[3];
tmp.directory     <- command.arguments[4];

####################################################################################################
library(ggplot2);

#source(paste(code.directory, "bugs-chains.R", sep = "/"));
#source(paste(code.directory, "which-bugs.R",  sep = "/"));

####################################################################################################
FILE.input <- paste0(data.directory,'/train.csv');

####################################################################################################
DF.titanic.training <- read.table(
	file   = FILE.input,
	header = TRUE,
	sep    = ',',
	quote  = "\""
	);
str(DF.titanic.training);

####################################################################################################
setwd(output.directory);

xtab.sex <- xtabs(
	formula = ~ Survived + Sex,
	data    = DF.titanic.training
	);
print('xtab.sex');
print( xtab.sex );

xtab.pclass <- xtabs(
	formula = ~ Survived + Pclass,
	data    = DF.titanic.training
	);
print('xtab.pclass');
print( xtab.pclass );

#temp.filename <- '.png';
#my.ggplot <- ggplot(data = NULL);
#my.ggplot <- my.ggplot + geom_
#my.ggplot <- my.ggplot + xlab("Time (Years)");
#my.ggplot <- my.ggplot + theme(title = element_text(size = 20), axis.title = element_text(size = 30), axis.text  = element_text(size = 25));
#my.ggplot <- my.ggplot + ggtitle(paste0("log.rank: ",formatC(logrank.stat),", pval: ",logrank.pval));
#ggsave(file = temp.filename, plot = my.ggplot, dpi = resolution, height = 6, width = 12, units = 'in');

####################################################################################################

