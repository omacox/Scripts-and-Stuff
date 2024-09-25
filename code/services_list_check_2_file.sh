#!/bin/bash
# services_list_check_2_file.sh
# This script reads from aws_all_services_mod.csv, 
# checks if each service is being used,
# and outputs the usage information to a timestamped file.
# Oma Cox 2024.09.25

# Get current timestamp
timestamp=$(date +"%Y%m%d_%H%M%S")

# Output file with timestamp
output_file="${timestamp}_aws_all_services_review_simp.txt"

# Initialize the output file and output to terminal
echo "AWS Services Usage Report - Generated on $(date)" | tee "$output_file"
echo "" | tee -a "$output_file"

# Read the CSV file
while IFS=, read -r category service cli_command
do
    # Remove quotes
    category=$(echo "$category" | tr -d '"')
    service=$(echo "$service" | tr -d '"')
    cli_command=$(echo "$cli_command" | tr -d '"')

    # Skip if no CLI command is available
    if [[ "$cli_command" == "[No AWS CLI Command Available]" ]]; then
        continue
    fi

    # Execute the CLI command and capture output
    output=$($cli_command 2>/dev/null)

    # Check if output is not empty
    if [[ -n "$output" ]]; then
        echo "Service: $service" | tee -a "$output_file"
        echo "$output" | tee -a "$output_file"
        echo "" | tee -a "$output_file"
    fi
done < "aws_all_services_mod.csv"

echo "Report generated: $output_file"
