import os
import pandas as pd
import numpy as np

def check_rows(file_prefix, max_rows):
    # Get a list of all files with the specified prefix
    file_list = [file for file in os.listdir() if file.startswith(file_prefix)]

    if not file_list:
        raise FileNotFoundError(f"No files found with the prefix: {file_prefix}")

    row_data_list = []

    # Check the row count for each file
    for file_path in file_list:
        current_df = pd.read_csv(file_path, header=None)  # Check for appropriate delimiter 
        current_rows = len(current_df)

        # Raise an error if the row count is different
        if current_rows != max_rows:
            print(f"Current rows: {current_rows}")
            print(f"File {file_path} doesn't have the expected number of rows ({max_rows}).")
        else:
            # Append the transposed row data to the list
            row_data_list.append(np.array(current_df).reshape(1, -1))

    return row_data_list

if __name__ == "__main__":
    # Specify the prefix of your files
    file_prefix = "myfile_UP_"

    # Specify the maximum number of rows expected
    max_rows = len(list(range(571, 725, 5)))

    try:
        row_data_list = check_rows(file_prefix, max_rows)
        
        for idx, row_data in enumerate(row_data_list):
            print(row_data)
    except FileNotFoundError as e:
        print(f"Error: {e}")
