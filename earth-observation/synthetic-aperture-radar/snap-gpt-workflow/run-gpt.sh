#!/bin/bash

currentDIR=`pwd`
   codeDIR=${currentDIR}/code
 outputDIR=${currentDIR//github/gittmp}/output

parentDIR=`dirname ${currentDIR}`
  dataDIR=${parentDIR}/000-data
# dataDIR=./000-data

if [ ! -d ${outputDIR} ]; then
	mkdir -p ${outputDIR}
fi

cp -r ${codeDIR} ${outputDIR}
cp    $0         ${outputDIR}/code

##################################################
#  inputFolder=louisiana-pass-a-loutre
#inputFileStem=S1A_IW_GRDH_1SDV_20210712T000200_20210712T000225_038737_049230_5E7B

  inputFolder=great-salt-lake
inputFileStem=S1A_IW_GRDH_1SDV_20210731T133415_20210731T133440_039022_049ABB_0DF6

#  inputFolder=kathmandu
#inputFileStem=S1A_IW_SLC__1SDV_20150429T001907_20150429T001935_005691_0074DC_7332

##################################################
stdoutFile=${outputDIR}/stdout.gpt
stderrFile=${outputDIR}/stderr.gpt
PATH=/Applications/snap/bin:$PATH
gpt ${codeDIR}/S1_GRD_preprocessing.xml \
    -Presolution=10 \
    -Porigin=5 \
    -Pfilter='Refined Lee' \
    -Pdem='SRTM 3Sec' \
    -Pcrs='GEOGCS["WGS84(DD)", DATUM["WGS84", SPHEROID["WGS84", 6378137.0, 298.257223563]], PRIMEM["Greenwich", 0.0], UNIT["degree", 0.017453292519943295], AXIS["Geodetic longitude", EAST], AXIS["Geodetic latitude", NORTH]]' \
    -Pinput=${dataDIR}/${inputFolder}/${inputFileStem}.SAFE \
    -Poutput=${outputDIR}/${inputFileStem}.dim > ${stdoutFile} 2> ${stderrFile}
##################################################
exit

