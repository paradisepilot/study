
myRscript=../../../code/rebalance-portfolio.R
  codeDIR=../../../code
  dataDIR=../data
outputDIR=../output
   tmpDIR=${outputDIR}/tmp

##################################################
if [ ! -d ${outputDIR} ]; then
	mkdir ${outputDIR}
fi

if [ ! -d ${tmpDIR} ]; then
	mkdir ${tmpDIR}
fi

stdoutFile=stdout.R.`basename ${myRscript} .R`
R --no-save --args ${dataDIR} ${codeDIR} ${outputDIR} ${tmpDIR} < ${myRscript} 2>&1 > ${stdoutFile}

