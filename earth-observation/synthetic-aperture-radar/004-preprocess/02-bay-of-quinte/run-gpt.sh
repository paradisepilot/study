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
inputFolder=bay-of-quinte

inputFileStems=( \
    "S1A_IW_GRDH_1SDV_20191226T230828_20191226T230852_030526_037EDA_8C50" \
    "S1A_IW_GRDH_1SDV_20191214T230828_20191214T230853_030351_0378D3_C44C" \
    "S1A_IW_GRDH_1SDV_20191202T230829_20191202T230853_030176_0372C4_E2FF" \
    "S1A_IW_GRDH_1SDV_20191120T230829_20191120T230854_030001_036CB5_42C8" \
    "S1A_IW_GRDH_1SDV_20191108T230829_20191108T230854_029826_0366A8_8734" \
    "S1A_IW_GRDH_1SDV_20191027T230829_20191027T230854_029651_036075_5EAF" \
    "S1A_IW_GRDH_1SDV_20191015T230829_20191015T230854_029476_035A71_8528" \
    "S1A_IW_GRDH_1SDV_20191003T230829_20191003T230854_029301_035465_8194" \
    "S1A_IW_GRDH_1SDV_20190921T230829_20190921T230854_029126_034E5F_AE43" \
    "S1A_IW_GRDH_1SDV_20190909T230829_20190909T230853_028951_03486B_D494" \
    "S1A_IW_GRDH_1SDV_20190828T230828_20190828T230852_028776_034258_5E65" \
    "S1A_IW_GRDH_1SDV_20190816T230827_20190816T230852_028601_033C30_EB3E" \
    "S1A_IW_GRDH_1SDV_20190804T230827_20190804T230851_028426_033652_227C" \
    "S1A_IW_GRDH_1SDV_20190723T230826_20190723T230850_028251_0330F6_5B24" \
    "S1A_IW_GRDH_1SDV_20190711T230825_20190711T230849_028076_032BAF_99BB" \
    "S1A_IW_GRDH_1SDV_20190629T230824_20190629T230849_027901_032662_66E9" \
    "S1A_IW_GRDH_1SDV_20190617T230824_20190617T230848_027726_032128_CDC0" \
    "S1A_IW_GRDH_1SDV_20190605T230823_20190605T230847_027551_031BE4_B7EE" \
    "S1A_IW_GRDH_1SDV_20190512T230822_20190512T230846_027201_031102_9047" \
    "S1A_IW_GRDH_1SDV_20190430T230821_20190430T230846_027026_030B18_6819" \
    "S1A_IW_GRDH_1SDV_20190418T230821_20190418T230845_026851_0304BD_5B22" \
    "S1A_IW_GRDH_1SDV_20190406T230820_20190406T230845_026676_02FE61_F190" \
    "S1A_IW_GRDH_1SDV_20190325T230820_20190325T230845_026501_02F7F0_B58B" \
    "S1A_IW_GRDH_1SDV_20190313T230820_20190313T230844_026326_02F180_E24D" \
    "S1A_IW_GRDH_1SDV_20190301T230820_20190301T230844_026151_02EB1A_54E0" \
    "S1A_IW_GRDH_1SDV_20190217T230820_20190217T230844_025976_02E4D4_1038" \
    "S1A_IW_GRDH_1SDV_20190124T230820_20190124T230845_025626_02D84E_7D45" \
    "S1A_IW_GRDH_1SDV_20190112T230821_20190112T230845_025451_02D1EA_DA15"
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
        -Pgeoregion='POLYGON(( -77.43 43.86 , -77.00 43.86 , -77.00 44.15 , -77.43 44.15 , -77.43 43.86 ))' \
        -Pinput=${dataDIR}/${inputFolder}/${inputFileStem}.zip \
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
