#!/bin/bash

currentDIR=`pwd`
   codeDIR=${currentDIR}/code
 outputDIR=${currentDIR//github/gittmp}/output

parentDIR=`dirname ${currentDIR}`
  dataDIR=${parentDIR}/000-data

if [ ! -d ${outputDIR} ]; then
    mkdir -p ${outputDIR}
fi

cp -r ${codeDIR} ${outputDIR}
cp    $0         ${outputDIR}/code

########################################################
myPythonScript=${codeDIR}/main.py
stdoutFile=${outputDIR}/stdout.py.`basename ${myPythonScript} .py`
stderrFile=${outputDIR}/stderr.py.`basename ${myPythonScript} .py`
python ${myPythonScript} ${dataDIR} ${codeDIR} ${outputDIR} > ${stdoutFile} 2> ${stderrFile}
