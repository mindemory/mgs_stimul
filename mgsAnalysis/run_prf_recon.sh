#!/bin/bash

#This script allows prf reconstruction/projection in parallel per subject

MATLAB_PATH='/usr/local/bin/matlab9.9'
PROJECT_DIR=/datc/nathan/TAFKAP_pRF
DATA_DIR='/data/wmConfidence';
T_ROI_BOUNDS='[7 15]';
PRF_FUNC='@wm_prf_response_cos'
SAVE_RECON='false'
SUBJ_LIST=('AL' 'AY' 'BB' 'CC' 'JK' 'KN' 'MH' 'MR' 'SF' 'SH' 'XL' 'YK' 'YS' 'GH')

CACHE_DIR='./cache'
CACHE_PRF=${CACHE_DIR}/prf_data_30-Nov-2022.mat

LOG_DIR=$PROJECT_DIR/logs

#WARNING MAX 32 cores! So choose these values appropriately.
CORE_START=0
NUM_CORES=${#SUBJ_LIST[@]}

MAX_CORE=55
FINAL_CORE=$(($CORE_START + $NUM_CORES -1))
#echo "FINAL CORE!!! $FINAL_CORE"

if [ $FINAL_CORE -gt $MAX_CORE ]; then
	echo "Not enough cores! Reduce # of subjects or number of cores/subject!"
	exit 1
fi

CORES=(`seq -s ' ' $(($CORE_START)) $(($CORE_START + $NUM_CORES - 1))`)
NSLOTS=${#CORES[@]} #`echo $CORES | grep -o '[0-9]*'| wc -l` #this is now redundant w/ NUM_CORES but a sanity check I guess


for s in ${!SUBJ_LIST[@]}; do

	SUBJ=${SUBJ_LIST[$s]}
	CORE=${CORES[$s]}


	DATE=`date --rfc-3339='date'`

	LOG_FILE=$LOG_DIR/prf_recon.sh.o.$SUBJ.${PRF_FUNC:1}.$DATE
	
	printf "\n\n"
	echo "Subject: $SUBJ"
	echo "Core: $CORE"
	echo "Date: $DATE"
	printf "Log file: $LOG_FILE\n\n"

	#touch $LOG_FILE

	#-u gives unbuffered output so can see fit output progress
	nohup taskset --cpu-list $CORE $MATLAB_PATH -sd $PROJECT_DIR -batch "compute_prf_recon('$SUBJ','$DATA_DIR','$CACHE_DIR',$PRF_FUNC,$T_ROI_BOUNDS,'$CACHE_PRF',$SAVE_RECON)" > $LOG_FILE &
	
done

taskset --cpu-list $CORENUM $MATLAB_PATH -u -r "try; run('test_script'); catch; end; quit" > $LOG_FILE &
