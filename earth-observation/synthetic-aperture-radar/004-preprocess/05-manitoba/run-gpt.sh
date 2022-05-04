#!/bin/bash

currentDIR=`pwd`
   codeDIR=${currentDIR}/code
 outputDIR=${currentDIR//github/gittmp}/output

parentDIR=`dirname ${currentDIR}`
parentDIR=`dirname ${parentDIR}`
  dataDIR=${parentDIR}/000-data

if [ ! -d ${outputDIR} ]; then
	mkdir -p ${outputDIR}
fi

cp -r ${codeDIR} ${outputDIR}
cp    $0         ${outputDIR}/code

##################################################
inputFolder=manitoba

inputFileStems=( \
    "S1B_IW_GRDH_1SDV_20211212T003147_20211212T003212_029985_03946B_B2AB" \
    "S1B_IW_GRDH_1SDV_20211212T003212_20211212T003237_029985_03946B_CE50" \
    "S1B_IW_GRDH_1SDV_20211212T003237_20211212T003302_029985_03946B_FCA1" \
    "S1B_IW_GRDH_1SDV_20211212T003302_20211212T003327_029985_03946B_76B1" \
    "S1B_IW_GRDH_1SDV_20211214T001511_20211214T001536_030014_039562_0B0A" \
    "S1B_IW_GRDH_1SDV_20211214T001536_20211214T001601_030014_039562_A92B" \
    "S1B_IW_GRDH_1SDV_20211214T001601_20211214T001626_030014_039562_9CCF" \
    "S1B_IW_GRDH_1SDV_20211202T001601_20211202T001626_029839_038FDF_259E" \
    )

##################################################
# preprocessing

if [ `uname` == Darwin ]
then
    PATH=/Applications/snap/bin:$PATH
elif [ `whoami` == jovyan ]
then
    PATH=/home/jovyan/data-vol-1/software/snap/bin:$PATH
else
    PATH=~/Software/SNAP/SNAP_8.0.0/bin:$PATH
fi

echo
for inputFileStem in "${inputFileStems[@]}"
do
    stdoutFile=${outputDIR}/stdout.gpt.${inputFileStem}
    stderrFile=${outputDIR}/stderr.gpt.${inputFileStem}
    inputFileZIP=${dataDIR}/${inputFolder}/${inputFileStem}.zip
    echo processing: ${inputFileZIP}
    echo
    gpt ${codeDIR}/S1_GRD_preprocessing.xml \
        -Presolution=10 \
        -Porigin=5 \
        -Pfilter='Refined Lee' \
        -Pdem='SRTM 3Sec' \
        -Pcrs='GEOGCS["WGS84(DD)", DATUM["WGS84", SPHEROID["WGS84", 6378137.0, 298.257223563]], PRIMEM["Greenwich", 0.0], UNIT["degree", 0.017453292519943295], AXIS["Geodetic longitude", EAST], AXIS["Geodetic latitude", NORTH]]' \
        -Pinput=${inputFileZIP} \
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
stdoutFile=${outputDIR}/stdout.gpt.export.GeoTIFF
stderrFile=${outputDIR}/stderr.gpt.export.GeoTIFF
gpt ${codeDIR}/export.xml \
    -Pinput=${outputDIR}/coregistered_stack.dim \
    -PoutputFormat='GeoTIFF' \
    -Poutput=${outputDIR}/coregistered_stack > ${stdoutFile} 2> ${stderrFile}

##################################################
# save as NetCDF4-CF

sleep 10
stdoutFile=${outputDIR}/stdout.gpt.export.NetCDF4-CF
stderrFile=${outputDIR}/stderr.gpt.export.NetCDF4-CF
gpt ${codeDIR}/export.xml \
    -Pinput=${outputDIR}/coregistered_stack.dim \
    -PoutputFormat='NetCDF4-CF' \
    -Poutput=${outputDIR}/coregistered_stack > ${stdoutFile} 2> ${stderrFile}

##################################################
exit
