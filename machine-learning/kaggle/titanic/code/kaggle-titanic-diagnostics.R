
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
DF.titanic.training[,'Pclass'] <- as.factor(DF.titanic.training[,'Pclass']);
DF.titanic.training[,'Dead']   <- 1 - DF.titanic.training[,'Survived'];

DF.titanic.training[,'with.help'] <- rep(0,nrow(DF.titanic.training));
temp <- (4 <= DF.titanic.training[,'SibSp'] + DF.titanic.training[,'Parch'])
DF.titanic.training[temp,'with.help'] <- 1;

str(DF.titanic.training);

summary(DF.titanic.training);

####################################################################################################
setwd(output.directory);

results.glm.logit <- glm(
	formula = cbind(Survived, 1 - Survived) ~ Sex * Pclass + with.help,
	data    = DF.titanic.training,
	family  = binomial(link = logit)
	);
summary(results.glm.logit);
anova(results.glm.logit, test = 'LRT');

(deviance.residuals <- sum(residuals(results.glm.logit)^2));
df.residual(results.glm.logit);
pchisq(q = deviance.residuals, df = df.residual(results.glm.logit), lower.tail = FALSE);

survivals <- DF.titanic.training[,'Survived'];
probs <- predict(results.glm.logit,type='response');
predictions <- rep(0,length(probs));
predictions[probs > 0.5] <- 1;
cbind(Survived = survivals,prediction = predictions, prob = probs);
sum(survivals == predictions);
sum(survivals == predictions) / length(survivals);

q();

####################################################################################################
xtab.sex <- xtabs(
	formula = ~ Sex + Survived,
	data    = DF.titanic.training
	);
xtab.sex <- as.matrix(xtab.sex);
xtab.sex;
DF.sex <- as.data.frame(xtab.sex[,c('0','1')]);
colnames(DF.sex) <- gsub(x = colnames(DF.sex), pattern = '0', replacement = 'dead');
colnames(DF.sex) <- gsub(x = colnames(DF.sex), pattern = '1', replacement = 'survived');
DF.sex[,'Sex'] <- rownames(DF.sex);
rownames(DF.sex) <- NULL;
DF.sex;

results.glm <- glm(formula = cbind(survived,dead) ~ Sex, data = DF.sex, family = binomial);
summary(results.glm);

xtab.pclass <- xtabs(
	formula = ~ Survived + Sex + Pclass,
	data    = DF.titanic.training
	);
print('xtab.pclass');
print( xtab.pclass );

DF.Survived <- aggregate(
	formula = Survived ~ Sex + Pclass,
	data    = DF.titanic.training,
	FUN     = sum
	);

DF.Dead <- aggregate(
	formula = Dead ~ Sex + Pclass,
	data    = DF.titanic.training,
	FUN     = sum
	);

DF.temp <- merge(x = DF.Survived, y = DF.Dead, by = c("Sex","Pclass"));
DF.temp[,'total'] <- DF.temp[,'Survived'] + DF.temp[,'Dead'];
DF.temp;

results.poisson <- glm(
	formula = Survived ~ offset(log(total)) + Sex * Pclass,
	data    = DF.temp,
	family  = poisson
	);
summary(results.poisson);
anova(results.poisson,test='LRT');

DF.temp[,'poisson.predicted'] <- predict(object = results.poisson, type = 'response');
DF.temp;

results.binomial.logit <- glm(
	formula = cbind(Survived,Dead) ~ Sex * Pclass,
	data    = DF.temp,
	family  = binomial(link = 'logit')
	);
summary(results.binomial.logit);
anova(results.binomial.logit,test='LRT');

DF.temp[,'logit.predicted'] <- DF.temp[,'total'] * predict(object = results.binomial.logit, type = 'response');
DF.temp;

#temp.filename <- '.png';
#my.ggplot <- ggplot(data = NULL);
#my.ggplot <- my.ggplot + geom_
#my.ggplot <- my.ggplot + xlab("Time (Years)");
#my.ggplot <- my.ggplot + theme(title = element_text(size = 20), axis.title = element_text(size = 30), axis.text  = element_text(size = 25));
#my.ggplot <- my.ggplot + ggtitle(paste0("log.rank: ",formatC(logrank.stat),", pval: ",logrank.pval));
#ggsave(file = temp.filename, plot = my.ggplot, dpi = resolution, height = 6, width = 12, units = 'in');

####################################################################################################

