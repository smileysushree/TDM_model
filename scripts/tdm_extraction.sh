#! /bin/bash

# BASH script to grab the TDM values for spin up and spin down transition
# The values are grabbed using python script debye_value.py

# Usage:
# ./tdm_extraction.sh

# Redirecting the error of the script to error_log.txt
exec 2> error_log.txt

# Check the number required arguments = 0. If incorrect, then print a helpful
# error message and exit with an appropriate return value, E_ARGS
if [ $# -ne 0 ]
then
  echo
  echo "  Usage: $(basename $0)"
  echo
  exit ${E_ARGS}
fi


# Include the function library
# If running in Superior HPC by Michigan Tech uncomment this section. 
# This is done to save us from duplicate function creation
# if [ -r "${HOME}/bin/functions.sh" ]
# then
#   source ${HOME}/bin/functions.sh
# fi

# Get the directory of the currently executing script
SCRIPT_DIR=$(dirname "$0")

# Error codes
E_VASPKIT="65"
E_DEBYE="66"
E_FILE_MISSING="67"
E_CHECK_FILE_ROWS='68'
E_TDM_MATRIX="69"

# Check if vaspkit is installed
if ! command -v vaspkit >/dev/null 2>&1
then
  echo
  echo "  Error: vaspkit is not installed. Please install vaspkit to proceed."
  echo "  Exiting the script/workflow."
  echo
  exit ${E_VASPKIT}  # Exit with a non-zero status code to indicate failure
fi

# Check if the debye_value.py script exists in the same directory as the Bash script
if [ ! -f "${SCRIPT_DIR}/debye_value.py" ]; 
then
  echo
  echo "  Error: debye_value.py script not found in the same directory as the Bash script"
  echo "  Change the script location to ${SCRIPT_DIR} or make the necessary"
  echo "    file location change in the python3 command section"
  echo
  exit ${E_DEBYE}  # Exit with a non-zero status code to indicate failure
fi


# Declare associative arrays for initial and final bands
declare -A ALL_INITIAL
declare -A ALL_FINAL

# Variables
TRANSITION_TYPE=("UP" "DW")
START_TIME=$(date +"%Y%m%d_%H%M%S")   #Capture start time

# True data - Change the number of bands as per need
# For spin up transitions 
ALL_INITIAL_UP=($(seq 293 5 570))   #range of initial bands -4.9 to 4.9
ALL_FINAL_UP=($(seq 571 5 724))     #range of final bands
# For spin down transitions 
ALL_INITIAL_DW=($(seq 322 5 591))
ALL_FINAL_DW=($(seq 592 5 721))



# DEBUG
# Uncomment this section and edit when there is a need
 #echo "ALL_INITIAL        : ${ALL_INITIAL_UP[@]}"
 #echo "ALL_FINAL          : ${ALL_FINAL_UP[@]}"
 #ALL_INITIAL_UP=(560 565)
 #ALL_FINAL_UP=(571 576)
 #ALL_INITIAL_DW=(581)
 #ALL_FINAL_DW=(592)

#BEGIN getting TDM data from the bandstructure
# Function to extract TDM data for a specific transition type
# Args: $1 - Transition type (SPIN_UP or SPIN_DOWN)
# Returns: csv files for args respectively. 
function tdm_extract() {
  # Check the number required arguments. If incorrect, then print a helpful
  # error message and exit with an appropriate return value, E_ARGS.
  if [ $# -ne 1 ]
  then
    echo
    echo " Error: Invalid number of arguments. Provide only one."
    echo
    exit ${E_ARGS}
  fi
  
  # Check the number required arguments. If incorrect, then print a helpful
  # error message and exit with an appropriate return value, E_ARGS.
  if [ $# -ne 1 ]
  then
    echo
    echo "  Error: Invalid number of arguments. Provide only one."
    echo
    exit ${E_ARGS}
  fi
  
  # Check the the type of argument passed is in TRANSITION_TYPE. If not, then print a helpful
  # error message and exit with an appropriate return value, E_ARGS.
  if [[ ! " ${TRANSITION_TYPE[@]} " =~ " $1 " ]]
  then
    echo
    echo "  Error: Invalid argument. Please provide a valid argument: ${TRANSITION_TYPE[*]}"
    echo
    exit ${E_ARGS}
  fi
  
  tmp1="ALL_INITIAL_${1}[@]" # All initial bands for the ongoing transition loop
  # echo "1"${!tmp1}
  tmp2="ALL_FINAL_${1}[@]"   # All final bands for the ongoing transition loop
  # echo "2"${!tmp2}

  for initial_bandnumber in ${!tmp1}
  do 
    # echo ${initial_bandnumber}                    
    for final_bandnumber in ${!tmp2}; 
    do
      # echo ${final_bandnumber}  
      echo ${initial_bandnumber} ${final_bandnumber}
      
      # run vaspkit
      # this gives the tdm value for the particular transition range from valence to conduction bands
      
      printf '71\n713\n 1\n'"${initial_bandnumber}""\n""${final_bandnumber}""\n"  | vaspkit
      
      # Get the debye^2 amplitude using debye_value.py for the specified transition type
      python3 "$SCRIPT_DIR/debye_value.py" "${1}"     # Argument for up/down transition

      # renaming files
      echo "  Moving TDM.dat to TDM_${initial_bandnumber}_${final_bandnumber}.dat"
      mv TDM.dat TDM_${initial_bandnumber}_${final_bandnumber}.dat
      
      echo '  Moving TDM.jpg to TDM_${initial_bandnumber}_${final_bandnumber}.jpg'
      mv TDM.jpg TDM_${initial_bandnumber}_${final_bandnumber}.jpg
      
      echo '  Moving TDM_COMPONENTS_UP.dat to TDM_COMPONENTS_UP_${initial_bandnumber}_${final_bandnumber}.dat'
      mv TDM_COMPONENTS_UP.dat TDM_COMPONENTS_UP_${initial_bandnumber}_${final_bandnumber}.dat
      
      echo '  Moving TDM_COMPONENTS_DW.dat to TDM_COMPONENTS_DW_${initial_bandnumber}_${final_bandnumber}.dat'
      mv TDM_COMPONENTS_DW.dat TDM_COMPONENTS_DW_${initial_bandnumber}_${final_bandnumber}.dat


    done

    # myfile.csv is created by debye_value.py for each initial bandnumber value.
    # It contains all the amplitube in one column for various final bandnumbers. 
    # In this step, it is renamed to initial_bandnumber (first loop) 
    echo '  Moving myfile.csv myfile_${1}_${initial_bandnumber}.dat'
    mv myfile.csv myfile_${1}_${initial_bandnumber}.dat

  done
}



# Call the function
for transition_type in ${TRANSITION_TYPE[@]}
  do
    echo "  Before function starts "${transition_type}""  #for debug purpose 
    tdm_extract "${transition_type}"
    # Check if the check_file_rows.py script exists in the same directory as the Bash script
    if [ ! -f "${SCRIPT_DIR}/TDM_matrix.py" ]; 
    then
     echo
     echo "  Error: check_file_rows.py  script not found in the same directory as the Bash script"
     echo "  Change the script location to ${SCRIPT_DIR} or make the necessary"
     echo "    file location change in the python3 command section"
     echo
     exit ${E_CHECK_FILE_ROWS}  # Exit with a non-zero status code to indicate failure
    fi
    # Check if the TDM_matrix.py script exists in the same directory as the Bash script
    if [ ! -f "${SCRIPT_DIR}/TDM_matrix.py" ]; 
    then
     echo
     echo "  Error: TDM_matrix.py  script not found in the same directory as the Bash script"
     echo "  Change the script location to ${SCRIPT_DIR} or make the necessary"
     echo "    file location change in the python3 command section"
     echo
     exit ${E_TDM_MATRIX}  # Exit with a non-zero status code to indicate failure
    fi
    python3 "$SCRIPT_DIR/TDM_matrix.py" "my_file_${transition_type}*.dat" "TDM_${transition_type}.csv" "ALL_FINAL_${transition_type}"
    # Sanitize file_csv for Linux environments
    dos2unix -q TDM_${transition_type}.csv
    echo "  After function ends "${transition_type}""     #for debug purpose 
    echo
  done

 

END_TIME=$(date +"%Y%m%d_%H%M%S")   #Capture end time

# Running MATLAB in a Linux environment using 1 processor
#matlab -nodisplay -nosplash -singleCompThread -r fr_with_tdm -logfile fr_with_tdm_${TIME_STAMP}.log

# Log a message indicating the end of the script along with start and end times and exit 
echo "over"
echo 
echo "  Script execution started at: ${START_TIME}"
echo "  Script execution completed at: ${END_TIME}"
exit 0    #exits to command line all the calculations are over   