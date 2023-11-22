import os
import csv
import glob

# You should know what you are doing, else it might not give correct results

# if the script is not used in the loop i.e. it is used separarely, change the UP/DW according the calculations

# final_band_number is also changed to the band_number used in the calculations

def create_output_matrix(file_pattern, output_file,final_band_number):
    # Get a list of all files matching the pattern
    files = sorted(glob.glob(file_pattern))

    if not files:
        raise FileNotFoundError(f"No files found with the pattern: {file_pattern}")

    # Create the output matrix file
    with open(output_file, 'w', newline='') as output:
        writer = csv.writer(output, delimiter=',')

        # Write the header row
        header = ["TDM_UP"] + final_band_number
        writer.writerow(header)

        # Write the data rows
        for file_path in files:
            # Extract the file number from the file name
            file_number = int(file_path.split('_')[-1].split('.')[0])

            # Read the data from the file
            with open(file_path, 'r') as file:
                data = [float(line.strip()) for line in file]

            # Write the file number and transpose of the data
            row_data = [file_number] + data
            writer.writerow(row_data)

    print(f"Output matrix written to {output_file}")

if __name__ == "__main__":
    # Specify the file pattern to match 
    file_pattern = 'myfile_UP_*.dat'                #for debug purpose

    # Specify the output file
    output_file = 'TDM_UP.csv'                      #for debug purpose

    # For the header and the final band number
    final_band_number = list(range(571, 725, 5))    #for debug purpose

    create_output_matrix(file_pattern, output_file,final_band_number)
