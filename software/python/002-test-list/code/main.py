#!/usr/bin/env python

import os, sys, shutil, getpass
import pprint, logging, datetime
import stat

dir_data   = os.path.realpath(sys.argv[1])
dir_code   = os.path.realpath(sys.argv[2])
dir_output = os.path.realpath(sys.argv[3])

if not os.path.exists(dir_output):
    os.makedirs(dir_output)

os.chdir(dir_output)

myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( "\n" + myTime + "\n" )
print("####################")

print( "\ndir_data: "   + dir_data   )
print( "\ndir_code: "   + dir_code   )
print( "\ndir_output: " + dir_output )
print( "\n" )

logging.basicConfig(filename='log.debug',level=logging.DEBUG)

##################################################
##################################################
import seaborn as sns
import numpy   as np
import pandas  as pd

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
node_pool_value = "dummy-node-pool-value"

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
injest_input_data_command = """
echo \
"\n\
apiVersion: storage.k8s.io/v1\n\
kind: StorageClass\n\
metadata:\n\
  name: my-storage-class\n\
  namespace: default\n\
provisioner: kubernetes.io/gce-pd\n\
parameters:\n\
  type: pd-ssd\n"\
> create_sc.yaml

echo \
"\n\
apiVersion: v1\n\
kind: PersistentVolumeClaim\n\
metadata:\n\
  name: pvc-{BUCKET_NAME}\n\
  namespace: default\n\
spec:\n\
  resources:\n\
    requests:\n\
      storage: 64Gi\n\
  accessModes:\n\
    - ReadWriteOnce\n\
  storageClassName: my-storage-class\n"\
> create_pvc.yaml

echo \
"\n\
apiVersion: v1\n\
kind: Pod\n\
metadata:\n\
  name: pd-{BUCKET_NAME}\n\
  namespace: default\n\
spec:\n\
  containers:\n\
  - name: datatransfer-container\n\
    image: nginx\n\
    volumeMounts:\n\
    - mountPath: /datatransfer\n\
      name: script-data\n\
  volumes:\n\
  - name: script-data\n\
    persistentVolumeClaim:\n\
      claimName: pvc-{BUCKET_NAME}\n"\
> create_pod_data.yaml

    echo;echo cat create_sc.yaml
    cat create_sc.yaml
    echo

    echo;echo cat create_pvc.yaml
    cat create_pvc.yaml
    echo

    echo;echo cat create_pod_data.yaml
    cat create_pod_data.yaml
    echo

    sleep 10

    echo; echo Executing: gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE}
    sudo gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE}
    sleep 10

    echo;echo Executing: sudo kubectl create -f create_sc.yaml
    sudo kubectl create -f create_sc.yaml
    sleep 10

    echo;echo Executing: sudo kubectl create -f create_pvc.yaml
    sudo kubectl create -f create_pvc.yaml
    sleep 10

    echo;echo Executing: sudo kubectl create -f create_pod_data.yaml
    sudo kubectl create -f create_pod_data.yaml
    sleep 10

    echo;echo Executing: sudo kubectl get nodes ; echo ; sudo kubectl get pods -o wide
    sudo kubectl get nodes ; echo ; sudo kubectl get pods -o wide
    sleep 10

    # Assume that the environment variable BUCKET has been set.
    echo;echo BUCKET_NAME={BUCKET_NAME}

    echo;echo Executing: gsutil ls {BUCKET_NAME}/TrainingData_Geojson
    gsutil ls {BUCKET_NAME}/TrainingData_Geojson

    echo;echo Executing: mkdir datatransfer
    mkdir datatransfer

    echo;echo Executing: gsutil -m cp -r gs://{BUCKET_NAME}/TrainingData_Geojson datatransfer
    gsutil -m cp -r gs://{BUCKET_NAME}/TrainingData_Geojson datatransfer

    echo;echo Executing: sudo kubectl cp datatransfer/TrainingData_Geojson default/pd-{BUCKET_NAME}:/datatransfer
    sudo kubectl cp datatransfer/TrainingData_Geojson default/pd-{BUCKET_NAME}:/datatransfer

    # echo;echo Executing: gsutil -m cp -r gs://{BUCKET_NAME}/img datatransfer
    # gsutil -m cp -r gs://{BUCKET_NAME}/img datatransfer

    # echo;echo Executing: sudo kubectl cp datatransfer/img default/pd-{BUCKET_NAME}:/datatransfer
    # sudo kubectl cp datatransfer/img default/pd-{BUCKET_NAME}:/datatransfer

    echo;echo Executing: ls -l datatransfer
    ls -l datatransfer

    echo;echo Executing: ls -l datatransfer/*
    ls -l datatransfer/*
    """

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
delete_datatransfer_pod_command = """
    echo;echo Executing: sudo gcloud config set container/cluster ${COMPOSER_GKE_NAME}
    sudo gcloud config set container/cluster ${COMPOSER_GKE_NAME}

    sleep 10

    echo;echo Executing: sudo gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE}
    sudo gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE}
    sleep 10

    # Generate node-pool name
    NODE_POOL=""" + node_pool_value + """

    ### Set the airflow variable name
    echo;echo Executing: airflow variables -s node_pool ${NODE_POOL}
    airflow variables -s node_pool ${NODE_POOL}
    sleep 10

    ### Examine clusters
    echo;echo Executing: gcloud container clusters list
    gcloud container clusters list
    sleep 60

    echo;echo Executing: sudo kubectl get nodes
    sudo kubectl get nodes

    echo;echo Executing: sudo kubectl get pods -o wide
    sudo kubectl get pods -o wide

    echo;echo Executing: sudo kubectl delete pod pd-{BUCKET_NAME}
    sudo kubectl delete pod pd-{BUCKET_NAME}
    """

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
persist_output_data_command = """
echo \
"\n\
apiVersion: storage.k8s.io/v1\n\
kind: StorageClass\n\
metadata:\n\
  name: my-storage-class\n\
  namespace: default\n\
provisioner: kubernetes.io/gce-pd\n\
parameters:\n\
  type: pd-ssd\n"\
> create_sc.yaml

echo \
"\n\
apiVersion: v1\n\
kind: PersistentVolumeClaim\n\
metadata:\n\
  name: pvc-{BUCKET_NAME}\n\
  namespace: default\n\
spec:\n\
  resources:\n\
    requests:\n\
      storage: 64Gi\n\
  accessModes:\n\
    - ReadWriteOnce\n\
  storageClassName: my-storage-class\n"\
> create_pvc.yaml

echo \
"\n\
apiVersion: v1\n\
kind: Pod\n\
metadata:\n\
  name: pd-{BUCKET_NAME}\n\
  namespace: default\n\
spec:\n\
  containers:\n\
  - name: datatransfer-container\n\
    image: nginx\n\
    volumeMounts:\n\
    - mountPath: /datatransfer\n\
      name: script-data\n\
  volumes:\n\
  - name: script-data\n\
    persistentVolumeClaim:\n\
      claimName: pvc-{BUCKET_NAME}\n"\
> create_pod_data.yaml

    echo;echo cat create_sc.yaml
    cat create_sc.yaml
    echo

    echo;echo cat create_pvc.yaml
    cat create_pvc.yaml
    echo

    echo;echo cat create_pod_data.yaml
    cat create_pod_data.yaml
    echo
    sleep 10

    echo; echo Executing: gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE}
    sudo gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE}
    sleep 10

    echo;echo Executing: sudo kubectl create -f create_sc.yaml
    # sudo kubectl create -f create_sc.yaml
    sleep 10

    echo;echo Executing: sudo kubectl create -f create_pvc.yaml
    # sudo kubectl create -f create_pvc.yaml
    sleep 10

    echo;echo Executing: sudo kubectl create -f create_pod_data.yaml
    sudo kubectl create -f create_pod_data.yaml
    sleep 10

    echo;echo Executing: sudo kubectl get nodes
    sudo kubectl get nodes
    sleep 10

    echo;echo Executing: sudo kubectl get pods -o wide
    sudo kubectl get pods -o wide
    sleep 10

    echo;echo Executing: mkdir -p datatransfer/output
    mkdir -p datatransfer/output
    sleep 10

    echo;echo Executing: ls -l
    ls -l
    sleep 10

    echo;echo Executing: ls -l datatransfer
    ls -l datatransfer
    sleep 10

    echo;echo Executing: sudo kubectl cp default/pvc-{BUCKET_NAME}:/datatransfer/output datatransfer/output
    sudo kubectl cp default/pvc-{BUCKET_NAME}:/datatransfer/output datatransfer/output
    sleep 10

    echo;echo Executing: ls -l datatransfer
    ls -l datatransfer
    sleep 10

    echo;echo Executing: ls -l datatransfer/output
    ls -l datatransfer/output
    sleep 10

    # Assume that the environment variable EXTERNAL_BUCKET has been set.
    echo;echo Executing: gsutil -m cp -r datatransfer/output ${EXTERNAL_BUCKET}
    gsutil -m cp -r datatransfer/output ${EXTERNAL_BUCKET}
    sleep 10

    echo;echo Executing: gsutil ls ${EXTERNAL_BUCKET}
    gsutil ls ${EXTERNAL_BUCKET}
    sleep 10

    echo;echo Executing: gsutil ls ${EXTERNAL_BUCKET}/output
    gsutil ls ${EXTERNAL_BUCKET}/output
    sleep 10

    echo;echo Executing: sudo kubectl delete pod pvc-{BUCKET_NAME}
    sudo kubectl delete pod pvc-{BUCKET_NAME}

    echo;echo Executing: sudo kubectl get nodes
    sudo kubectl get nodes
    sleep 10

    echo;echo Executing: sudo kubectl get pods -o wide
    sudo kubectl get pods -o wide
    sleep 10
    """

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
bucket_list = ['fpca-bay-of-quinte-test','fpca-williston-a']
for BUCKET_NAME in bucket_list:

    printed_string = injest_input_data_command.replace("{BUCKET_NAME}",BUCKET_NAME)
    print( printed_string )

    printed_string = delete_datatransfer_pod_command.replace("{BUCKET_NAME}",BUCKET_NAME)
    print( printed_string )

    printed_string = persist_output_data_command.replace("{BUCKET_NAME}",BUCKET_NAME)
    print( printed_string )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###
for i in range(0,len(bucket_list)):
    print( bucket_list[i] )

### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ###

##################################################
##################################################
print("\n####################\n")
myTime = "system time: " + datetime.datetime.now().strftime("%c")
print( myTime + "\n" )
