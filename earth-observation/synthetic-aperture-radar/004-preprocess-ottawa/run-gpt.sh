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
inputFolder=ottawa

# inputFileStems=( \
#     "S1A_IW_GRDH_1SDV_20201128T225233_20201128T225258_035455_0424F1_1E8C" \
#     "S1A_IW_GRDH_1SDV_20201203T230033_20201203T230109_035528_04276B_FF88" \
#     "S1A_IW_GRDH_1SDV_20201210T225233_20201210T225257_035630_042AF5_6A3A" \
#     "S1A_IW_GRDH_1SDV_20201215T230033_20201215T230108_035703_042D7B_42C5" \
#     "S1A_IW_GRDH_1SDV_20201222T225232_20201222T225257_035805_0430FC_950F" \
#     "S1A_IW_GRDH_1SDV_20201227T230032_20201227T230108_035878_04338F_0873"
#     )
inputFileStems=( \
    "S1A_IW_GRDH_1SDV_20201128T225233_20201128T225258_035455_0424F1_1E8C" \
    "S1A_IW_GRDH_1SDV_20201210T225233_20201210T225257_035630_042AF5_6A3A" \
    "S1A_IW_GRDH_1SDV_20201222T225232_20201222T225257_035805_0430FC_950F"
    )

##################################################
# preprocessing

if [ `uname` != Darwin ]
then
    PATH=/home/jovyan/data-vol-1/software/snap/bin:$PATH
else
    PATH=/Applications/snap/bin:$PATH
fi

for inputFileStem in "${inputFileStems[@]}"
do
    stdoutFile=${outputDIR}/stdout.gpt.${inputFileStem}
    stderrFile=${outputDIR}/stderr.gpt.${inputFileStem}
    gpt ${codeDIR}/S1_GRD_preprocessing.xml \
        -Presolution=10 \
        -Porigin=5 \
        -Pfilter='Refined Lee' \
        -Pdem='SRTM 3Sec' \
        -Pcrs='GEOGCS["WGS84(DD)", DATUM["WGS84", SPHEROID["WGS84", 6378137.0, 298.257223563]], PRIMEM["Greenwich", 0.0], UNIT["degree", 0.017453292519943295], AXIS["Geodetic longitude", EAST], AXIS["Geodetic latitude", NORTH]]' \
        -Pgeoregion='POLYGON((-76.0006 45.2206,-75.3625 45.2206,-75.3625 45.5594,-76.0006 45.5594,-76.0006 45.2206))' \
        -Pinput=${dataDIR}/${inputFolder}/${inputFileStem}.ZIP \
        -Poutput=${outputDIR}/${inputFileStem}.dim > ${stdoutFile} 2> ${stderrFile}
done

##################################################
# coregistration

fileList=${outputDIR}/${inputFileStems[0]}.dim
for inputFileStem in "${inputFileStems[@]:1}"
do
    fileList=${fileList},${outputDIR}/${inputFileStem}.dim
done

sleep 10
stdoutFile=${outputDIR}/stdout.gpt.coregistration
stderrFile=${outputDIR}/stderr.gpt.coregistration
gpt ${codeDIR}/coregistration.xml \
    -PresamplingType='NONE' \
    -Pextent='Master' \
    -PinitialOffsetMethod='Orbit' \
    -PfileList=${fileList} \
    -Poutput=${outputDIR}/coregistered_stack.dim > ${stdoutFile} 2> ${stderrFile}

##################################################
# save as GeoTIFF

sleep 10
stdoutFile=${outputDIR}/stdout.gpt.saveAsGeoTIFF
stderrFile=${outputDIR}/stderr.gpt.saveAsGeoTIFF
gpt ${codeDIR}/saveAsGeoTIFF.xml \
    -Pinput=${outputDIR}/coregistered_stack.dim \
    -PoutputFormat='GeoTIFF' \
    -Poutput=${outputDIR}/coregistered_stack.tif > ${stdoutFile} 2> ${stderrFile}

##################################################
exit

