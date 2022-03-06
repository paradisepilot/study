#!/bin/bash

# data_snapshot=NULL
#
# for argument in "$@"
# do
#     key=$(  echo $argument | cut -f1 -d=)
#     value=$(echo $argument | cut -f2 -d=)
#
#     if [[ $key == *"--"* ]]; then
#         v="${key/--/}"
#         declare $v="${value}"
#    fi
# done
#
# args=()
# args+=( '--data_snapshot' ${data_snapshot} )

##################################################
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

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
### Launch MS SQL Docker container. (Docker Desktop is assumed installed.)

### If it hasn't been done, pull MS SQL Server docker image from Microsoft's Docker Hub registry
### docker pull mcr.microsoft.com/mssql/server

### Launch MS SQL Server container
dbuserid=SA
dbpasswd=L96175e3EH48MGqw0g
dbUseridPasswd=${dbuserid}_PASSWORD=${dbpasswd}
docker run -d --name containerName -e 'ACCEPT_EULA=Y' -e ${dbUseridPasswd} -p 1433:1433 mcr.microsoft.com/mssql/server
sleep 10

### Copy vPIC MS SQL backup file from host file system to Docker container file system:
### docker cp <path to the file vPICList_lite_2022_02.bak in host file system> containerName:/var/opt/mssql/data/vPICList_lite_2022_02.bak
docker cp ${dataDIR}/vPIC/2022-02/vPICList_lite_2022_02.bak containerName:/var/opt/mssql/data/vPICList_lite_2022_02.bak
sleep 10

##################################################
myRscript=${codeDIR}/main.R
stdoutFile=${outputDIR}/stdout.R.`basename ${myRscript} .R`
stderrFile=${outputDIR}/stderr.R.`basename ${myRscript} .R`
R --no-save --args ${dataDIR} ${codeDIR} ${outputDIR} ${dbuserid} ${dbpasswd} < ${myRscript} > ${stdoutFile} 2> ${stderrFile}

##################################################
### Kill vPIC Docker containter
sleep 10
docker container kill containerName
sleep 10
docker container rm --volumes containerName

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
exit
