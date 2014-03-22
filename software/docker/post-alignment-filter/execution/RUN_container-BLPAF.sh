#!/bin/sh

launchDIR=/Users/woodenbeauty/Work/github/paradisepilot/study/software/docker/post-alignment-filter

inputSAM=/data/test-data-100K.sam
post_alignment_filtered_SAM=/output/output.sam
logFile=/output/log.BLPAF

#docker run -i -t -v ${launchDIR}/data:/data:ro -v ${launchDIR}/output:/output BLPAFcontainer /bin/bash
docker run -i -t -v ./chris/data:/data:ro -v ./chris/output:/output BLPAFcontainer /bin/bash

#docker run -i -t -v ${launchDIR}/data:/data:ro -v ${launchDIR}/output:/output:rw BLPAFcontainer --inputSAM ${inputSAM} --outputSAM ${post_alignment_filtered_SAM} --log ${logFile}

####################################################################################################
#docker run -i -t BLPAFcontainer --inputSAM ${inputSAM} --outputSAM ${post_alignment_filtered_SAM} --log ${logFile}
#docker run -i -t -v /Users/woodenbeauty/Work/github/paradisepilot/study/software/docker/post-alignment-filter/data/:/data BLPAFcontainer --inputSAM ${inputSAM} --outputSAM ${post_alignment_filtered_SAM} --log ${logFile}
#docker run BLPAFcontainer

