# python3 code to get total_matrix element for tdm calculations
# (can be used to get any matrix value)

import pandas as pd
import numpy as np
import csv
import sys

# a function isdefined to get the tdm value
# For spin up/down use the file TDM_COMPONENTS_UP/down taken from argument in bash

def deb_val(argument):
    try:
        test_list = pd.read_table('TDM_COMPONENTS_'+argument+'.dat',
                    dtype=None, sep='\s+ ' , skip_blank_lines=True,
                    header=None, skiprows=2, engine='python')

        df = pd.DataFrame(data=test_list)    #making them into frames

        value = df.iat[0,4]                  #value to be concatinated 
        print('tran_amp is: ',value)


        with open('myfile.csv',mode="a") as f:
            writer = csv.writer(f)
            writer.writerow([value])
            
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)  # Exit with a non-zero code to indicate failure
        
# Check if the script is run standalone
if __name__ == "__main__":
    if len(sys.argv) != 2:   #checking for the availability of one argument with the script
        print("Error: Invalid number of arguments. Provide one argument.", file=sys.stderr)
        sys.exit(1)  # Exit with a non-zero code to indicate failure
    argument = sys.argv[1]
    deb_val(argument)