#!/bin/bash

currentDIR=`pwd`
   codeDIR=${currentDIR}/code
 outputDIR=${currentDIR//github/gittmp}/output

parentDIR=`dirname ${currentDIR}`
# dataDIR=${parentDIR}/000-data
  dataDIR=./000-data

if [ ! -d ${outputDIR} ]; then
	mkdir -p ${outputDIR}
fi

cp -r ${codeDIR} ${outputDIR}
cp    $0         ${outputDIR}/code

##################################################
inputFileStem=S1A_IW_GRDH_1SDV_20210712T000200_20210712T000225_038737_049230_5E7B

stdoutFile=${outputDIR}/stdout.gpt
stderrFile=${outputDIR}/stderr.gpt

PATH=/Applications/snap/bin:$PATH
gpt ${codeDIR}/S1_GRD_preprocessing.xml \
    -Presolution=10 \
    -Porigin=5 \
    -Pfilter='Refined Lee' \
    -Pdem='SRTM 3Sec' \
    -Pcrs='GEOGCS["WGS84(DD)", DATUM["WGS84", SPHEROID["WGS84", 6378137.0, 298.257223563]], PRIMEM["Greenwich", 0.0], UNIT["degree", 0.017453292519943295], AXIS["Geodetic longitude", EAST], AXIS["Geodetic latitude", NORTH]]' \
    -Pinput=${dataDIR}/${inputFileStem}.SAFE \
    -Poutput=${outputDIR}/${inputFileStem}.dim > ${stdoutFile} 2> ${stderrFile}
##################################################
exit

