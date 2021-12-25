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
    "S1A_IW_GRDH_1SDV_20190109T224409_20190109T224434_025407_02D06C_7E15" \
    "S1A_IW_GRDH_1SDV_20190121T224408_20190121T224433_025582_02D6CB_6705" \
    "S1A_IW_GRDH_1SDV_20190202T224408_20190202T224433_025757_02DD2B_2B28" \
    "S1A_IW_GRDH_1SDV_20190226T224408_20190226T224433_026107_02E9A3_BF0D" \
    "S1A_IW_GRDH_1SDV_20190310T224408_20190310T224433_026282_02EFEF_0689" \
    "S1A_IW_GRDH_1SDV_20190322T224408_20190322T224433_026457_02F662_6E5B" \
    "S1A_IW_GRDH_1SDV_20190602T224411_20190602T224436_027507_031A98_3422" \
    "S1A_IW_GRDH_1SDV_20190813T224415_20190813T224440_028557_033AC6_BD26" \
    "S1A_IW_GRDH_1SDV_20190825T224416_20190825T224441_028732_0340CF_A3BA" \
    "S1A_IW_GRDH_1SDV_20190906T224416_20190906T224441_028907_0346EC_68EE" \
    "S1A_IW_GRDH_1SDV_20190930T224417_20190930T224442_029257_035302_BF63" \
    "S1A_IW_GRDH_1SDV_20191012T224417_20191012T224442_029432_0358FF_3DB6" \
    "S1A_IW_GRDH_1SDV_20191024T224417_20191024T224442_029607_035F02_EA03" \
    "S1A_IW_GRDH_1SDV_20191105T224417_20191105T224442_029782_03652B_C7EA" \
    "S1A_IW_GRDH_1SDV_20191117T224417_20191117T224442_029957_036B4A_0808" \
    "S1A_IW_GRDH_1SDV_20191129T224417_20191129T224442_030132_03715A_FCDF" \
    "S1A_IW_GRDH_1SDV_20191211T224416_20191211T224441_030307_03775D_D0BE" \
    "S1A_IW_GRDH_1SDV_20191223T224416_20191223T224441_030482_037D6D_E29C" \
    "S1A_IW_GRDH_1SDV_20200104T224415_20200104T224440_030657_038378_9B85" \
    "S1A_IW_GRDH_1SDV_20200116T224415_20200116T224440_030832_038996_6C7C" \
    "S1A_IW_GRDH_1SDV_20200128T224414_20200128T224439_031007_038FBF_344C" \
    "S1A_IW_GRDH_1SDV_20200209T224414_20200209T224439_031182_0395D9_80B9" \
    "S1A_IW_GRDH_1SDV_20200221T224414_20200221T224439_031357_039BDC_5856" \
    "S1A_IW_GRDH_1SDV_20200304T224414_20200304T224439_031532_03A1EE_7587" \
    "S1A_IW_GRDH_1SDV_20200316T224414_20200316T224439_031707_03A7FB_1A46" \
    "S1A_IW_GRDH_1SDV_20200328T224414_20200328T224439_031882_03AE21_38B6" \
    "S1A_IW_GRDH_1SDV_20200409T224414_20200409T224439_032057_03B455_D921" \
    "S1A_IW_GRDH_1SDV_20200421T224415_20200421T224440_032232_03BA74_7ECA" \
    "S1A_IW_GRDH_1SDV_20200503T224415_20200503T224440_032407_03C0A0_A57B" \
    "S1A_IW_GRDH_1SDV_20200819T224422_20200819T224447_033982_03F188_55FA" \
    "S1A_IW_GRDH_1SDV_20201006T224424_20201006T224449_034682_040A2C_F404" \
    "S1A_IW_GRDH_1SDV_20201018T224424_20201018T224449_034857_041052_B0C2" \
    "S1A_IW_GRDH_1SDV_20201030T224424_20201030T224449_035032_04163C_B76B" \
    "S1A_IW_GRDH_1SDV_20201111T224423_20201111T224448_035207_041C60_A0F4" \
    "S1A_IW_GRDH_1SDV_20201123T224423_20201123T224448_035382_042267_77E9" \
    "S1A_IW_GRDH_1SDV_20201205T224423_20201205T224448_035557_04286F_D78F" \
    "S1A_IW_GRDH_1SDV_20201217T224422_20201217T224447_035732_042E77_23DC" \
    "S1A_IW_GRDH_1SDV_20201229T224422_20201229T224447_035907_043498_F0B1" \
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
        -Pgeoregion='POLYGON(( -72.66 45.78 , -72.32 45.78 , -72.32 46.02 , -72.66 46.02 , -72.66 45.78 ))' \
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
