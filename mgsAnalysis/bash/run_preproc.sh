#!/bin/bash
#Created by Mrugank Dake for batch EEG Preprocessing
#Date:12/07/2022
#Adapted from Nathan Tardiff

MATLAB_PATH='/usr/local/bin/matlab9.6'
PROJECT_DIR=/datc/MD_TMS_EEG
FILES_DIR=${PROJECT_DIR}/EEGfiles
RAW_DIR=${PROJECT_DIR}/EEGData
SUBJ_LIST=(98)
DAYS=(1)

LOG_DIR=$FILES_DIR/logs
cd ..
LEN_SUBJ=${#SUBJ_LIST[@]}
LEN_DAYS=${#DAYS[@]}
NUM_CORES="$((10#$LEN_SUBJ*10#$LEN_DAYS-1))"

#Maximum Cores on Vader = 56
MAX_CORE=55
if [ $NUM_CORES -gt $MAX_CORE ]; then
    echo "Not enough cores! Reduce # of subjects or number of cores/subject!"
    exit 1
fi

#DATE=`date --rfc-3339='date'`
DATE=`date +%Y%m%d_%H%M%S`
echo $DATE

CORENUM=0
for s in ${!SUBJ_LIST[@]}; do
    for d in ${!DAYS[@]}; do
        SUBJ=${SUBJ_LIST[$s]}
        DAY=${DAYS[$d]}
        LOG_FILE=$LOG_DIR/pre.$SUBJ.$DAY.$DATE.txt
        
        printf "\n"
        echo "Subject: $SUBJ"
        echo "Day: $DAY"
        echo "Core: $CORENUM"
        echo "Date: $DATE"
        printf "Log file: $LOG_FILE\n"
        
        taskset --cpu-list $CORENUM $MATLAB_PATH -v -r "A03_PreprocEEG($SUBJ, $DAY)" > $LOG_FILE &
        (( CORENUM++ ))
        
    done
done
exit 1
