
outputDIR=output
if [ -d ${outputDIR} ]; then
	echo "The directory ${outputDIR} already exists. Program aborted."
	exit
else
	mkdir ${outputDIR}
fi

cd ${outputDIR}

myRscript=buchmann-exercise-08-01.R
outputFILE=stdout.R.`basename ${myRscript} .R`
R --no-save < ../${myRscript} 2>&1 > ${outputFILE}

