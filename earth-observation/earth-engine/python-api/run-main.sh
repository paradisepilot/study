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
source ${HOME}/.gee_environment_variables
if [[ "${OSTYPE}" =~ .*"linux".* ]]; then
  # cp ${HOME}/.gee_environment_variables ${outputDIR}/code/gee_environment_variables.txt
  pythonBinDIR=${GEE_ENV_DIR}/bin
else
  pythonBinDIR=`which python`
  pythonBinDIR=${pythonBinDIR//\/python/}
fi

########################################################
myPythonScript=${codeDIR}/main.py
stdoutFile=${outputDIR}/stdout.py.`basename ${myPythonScript} .py`
stderrFile=${outputDIR}/stderr.py.`basename ${myPythonScript} .py`
${pythonBinDIR}/python ${myPythonScript} ${dataDIR} ${codeDIR} ${outputDIR} > ${stdoutFile} 2> ${stderrFile}
