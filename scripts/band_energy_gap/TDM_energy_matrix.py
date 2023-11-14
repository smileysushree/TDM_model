import numpy as np

# Input data for UP transitions
ALL_INITIAL_UP = list(range(293, 571, 5))
ALL_FINAL_UP = list(range(571, 725, 5))

# Input data for DOWN transitions
ALL_INITIAL_DW = list(range(322, 592, 5))
ALL_FINAL_DW = list(range(592, 722, 5))

energy_file = 'BAND.dat'
output_file_UP = 'TDM_ediff_UP.dat'
output_file_DW = 'TDM_ediff_DW.dat'

# Read energy data from the file
with open(energy_file, 'r') as file:
    lines = file.readlines()

# Function to extract energy for a given band number and kpath
def get_energy(band_number, kpath='0.00000', spin='UP'):
    spin_column = 1 if spin == 'UP' else 2
    try:
        start_index = lines.index(f'# Band-Index  {band_number}\n')
    except ValueError:
        raise ValueError(f"Band number {band_number} should be exactly 3 digits.")
    for i in range(start_index, len(lines)):
        if lines[i].startswith(f'   {kpath}'):
            # Extracting energy for the specified spin
            return float(lines[i].split()[spin_column])
    return None

# Function to calculate energy differences matrix
def calculate_energy_matrix(all_initial, all_final, output_file,spin):
    # Initialize an empty matrix for energy differences
    energy_matrix = np.zeros((len(all_initial), len(all_final)))

    # Fill the matrix with energy differences
    for i, initial_band in enumerate(all_initial):
        for j, final_band in enumerate(all_final):
            initial_energy = get_energy(initial_band, spin=spin)
            final_energy = get_energy(final_band, spin=spin)
            if initial_energy is not None and final_energy is not None:
                energy_matrix[i, j] = initial_energy -final_energy

    # Write the resulting matrix to a file
    with open(output_file, 'w') as output:
        # Write header row
        output.write('\t' + '\t'.join(map(str, all_final)) + '\n')

        # Write data rows
        for i, initial_band in enumerate(all_initial):
            output.write(f"{initial_band}\t" + '\t'.join(map(str, energy_matrix[i])) + '\n')

    print(f"Energy Difference Matrix for {output_file} written.")

# Calculate and write energy differences matrix for UP transitions
calculate_energy_matrix(ALL_INITIAL_UP, ALL_FINAL_UP, output_file_UP, spin="UP")

# Calculate and write energy differences matrix for DOWN transitions
calculate_energy_matrix(ALL_INITIAL_DW, ALL_FINAL_DW, output_file_DW,spin="DW")
