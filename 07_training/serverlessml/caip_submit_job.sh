#!/bin/bash

PACKAGE_PATH="./flowers"
now=$(date +"%Y%m%d_%H%M%S")
JOB_NAME="flowers_$now"
MODULE_NAME="flowers.classifier.train"
JOB_DIR="gs://ai-analytics-solutions-kfpdemo/flowers"
REGION='us-west1'  # make sure you have GPU/TPU quota in this region

# gcloud ai-platform local train --package-path $PACKAGE_PATH --module-name $MODULE_NAME --job-dir ${JOB_DIR}_local -- --num_training_examples 100 --with_color_distort False --crop_ratio 0.6; exit

# cpu only
#DISTR="cpu"

# gpus on one machine
DISTR="gpus_one_machine"

# multiworker needs virtual epochs
#DISTR="gpus_multiple_machines"
#EXTRAS="--num_training_examples 4000"

#DISTR="tpu_caip"
#REGION="us-central1"

CONFIG=${DISTR}.yaml

# hyperparameter tuning
#CONFIG=hparam.yaml
#DISTR="gpus_one_machine"

# hyperparameter tuning
CONFIG=hparam-continue.yaml  # note job identifier here
DISTR="gpus_one_machine"
EXTRAS="--l2 0 --with_color_distort False"

gcloud ai-platform jobs submit training ${JOB_NAME}_${DISTR} \
        --config ${CONFIG} --region ${REGION} \
        --package-path $PACKAGE_PATH \
        --module-name $MODULE_NAME \
        --job-dir ${JOB_DIR}_${DISTR} \
        --runtime-version 2.3 --python-version 3.7 \
        --stream-logs \
        -- \
        --pattern='-*' \
        --num_epochs=20 --distribute $DISTR $EXTRAS
