#!/bin/bash

# Batch processing script for image dataset
# Usage: ./batch_process.sh <input_image_dir> <output_dir>

# Check input arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_image_dir> <output_dir>"
    exit 1
fi

INPUT_IMG_DIR=$1
OUTPUT_DIR=$2

# Create temporary directory for .mat files
MAT_DIR=$(mktemp -d)

# Step 1: Generate .mat files from images
# python3 ganerate_datamat.py "$INPUT_IMG_DIR" "$MAT_DIR"
python3 multi_data_process.py "$INPUT_IMG_DIR" "$MAT_DIR"
# Check if .mat files were generated
if [ -z "$(ls -A "$MAT_DIR")" ]; then
    echo "Error: No .mat files generated"
    rm -rf "$MAT_DIR"
    exit 1
fi

# Step 2: Process .mat files with MATLAB
matlab -nodisplay -r "batch_sid_process('$MAT_DIR', '$OUTPUT_DIR'); exit;"

# Step 3: Clean up temporary directory
rm -rf "$MAT_DIR"

echo "Batch processing completed! Results saved to $OUTPUT_DIR"