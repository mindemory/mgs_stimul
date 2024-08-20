#!/bin/bash
#Created by Mrugank for EEG preprocessing in Python
#Date: 08/16/2024

SUBJ_LIST=(1 3 5 6 7 10 12 14 15 17 22 23 25 26 27)
#taskset --cpu-list $CORENUM conda activate eegmne python mneEEG_loader.py $SUBJ > $LOG_FILE &
#SUBJ_LIST=(1 3)
PROJECT_DIR=/d/DATD/datd/MD_TMS_EEG
FILES_DIR=$PROJECT_DIR/EEGpy
RAW_DIR=$PROJECT_DIR/EEGfiles

LOG_DIR=$FILES_DIR/logs
# cd ..
LEN_SUBJ=${#SUBJ_LIST[@]}
NUM_CORES="$((10#$LEN_SUBJ))"

#Maximum cores on Vader = 56
MAX_CORE=55
if [ $NUM_CORES -gt $MAX_CORE ]; then
    NUM_CORES=$MAX_CORE
fi

#DATE=`date --rfc-3339='date'`
DATE=`date +%Y%m%d_%H%M%S`
echo $DATE

CORENUM=0

for s in ${!SUBJ_LIST[@]}; do
    
    SUBJ=${SUBJ_LIST[$s]}
    LOG_FILE=$LOG_DIR/pre.$SUBJ.notms.$DATE.txt
    
    printf "\n"
    echo "Subject: $SUBJ"
    echo "Day: $DAY"
    echo "Core: $CORENUM"
    echo "Date: $DATE"
    printf "Log file: $LOG_FILE\n"
    
    taskset --cpu-list $CORENUM bash -c "source activate eegmne; python mneEEG_notms.py $SUBJ > $LOG_FILE" &
    
    (( CORENUM++ ))
        
done
exit 1
