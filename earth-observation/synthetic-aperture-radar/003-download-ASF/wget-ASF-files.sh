#!/bin/bash

ASF_FILES=( \
    "https://datapool.asf.alaska.edu/GRD_HD/SA/S1A_IW_GRDH_1SDV_20201227T230032_20201227T230108_035878_04338F_0873.zip" \
    "https://datapool.asf.alaska.edu/GRD_HD/SA/S1A_IW_GRDH_1SDV_20201222T225232_20201222T225257_035805_0430FC_950F.zip" \
    "https://datapool.asf.alaska.edu/GRD_HD/SA/S1A_IW_GRDH_1SDV_20201215T230033_20201215T230108_035703_042D7B_42C5.zip" \
    "https://datapool.asf.alaska.edu/GRD_HD/SA/S1A_IW_GRDH_1SDV_20201210T225233_20201210T225257_035630_042AF5_6A3A.zip" \
    "https://datapool.asf.alaska.edu/GRD_HD/SA/S1A_IW_GRDH_1SDV_20201203T230033_20201203T230109_035528_04276B_FF88.zip" \
    "https://datapool.asf.alaska.edu/GRD_HD/SA/S1A_IW_GRDH_1SDV_20201128T225233_20201128T225258_035455_0424F1_1E8C.zip"
    )
 
source ~/.eo-credentials/credentials-nasa-earthdata.sh
for tempfile in "${ASF_FILES[@]}"
do
    echo
    echo downloading: ${tempfile}
    # for instructions on ASF Search API, see: https://docs.asf.alaska.edu/api/tools/
    wget -c --http-user=${NASAEarthdataUsername} --http-password=${NASAEarthdataPassword} ${tempfile}
done
echo

