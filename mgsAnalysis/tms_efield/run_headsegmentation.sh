#!/bin/bash
#Created by Mrugank Dake for batch Anatomical segmentation
#Date:11/04/2023

MATLAB_PATH='/usr/local/bin/matlab9.6'
#!/bin/bash

# Define the array of subject numbers
subs=(1 3)

original_dir=$(pwd)

# Define the maximum number of cores to use
MAX_CORE=55

# Get the length of the subjects array
NUM_SUBS=${#subs[@]}

# Check if the number of subjects exceeds the maximum number of cores available
if [ $NUM_SUBS -gt $MAX_CORE ]; then
    echo "Not enough cores! Reduce # of subjects or number of cores/subject!"
    exit 1
fi

DATE=$(date +%Y%m%d_%H%M%S)

# Initialize the core number counter
CORENUM=0

# Loop over the subject numbers
for sub in "${subs[@]}"; do
    sub_id=$(printf "sub%02d" $sub)
    work_dir="/d/DATC/datc/MD_TMS_EEG/SIMNIBS_output/${sub_id}/"
    LOG_FILE="/d/DATC/datc/MD_TMS_EEG/SIMNIBS_output/logs/charm_$sub_id_$DATE.log"
    
    mkdir -p "/d/DATC/datc/MD_TMS_EEG/SIMNIBS_output/logs"

    echo "Starting processing for Subject: $sub_id on Core: $CORENUM (Log: $LOG_FILE)"
    
    (
      cd "$work_dir"
      
      # Check if T2.nii exists
      if [ -e "T2.nii" ]; then
        command=(charm "$sub_id" "T1.nii" "T2.nii" "--forceqform")
      else
        command=(charm "$sub_id" "T1.nii" "--forceqform")
      fi
      
      {
        echo "Standard Output:"
        "${command[@]}"
        echo "Standard Error:" >&2
      } &> "$LOG_FILE" &
    ) &

    taskset --cpu-list $CORENUM -p $!

    ((CORENUM++))
    if [ $CORENUM -ge $MAX_CORE ]; then
        CORENUM=0
    fi
done

wait

echo "All processing jobs have completed."

exit 0
