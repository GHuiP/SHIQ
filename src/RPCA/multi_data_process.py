#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script generates the dataFace.mat file required by sidDemo.m
The file contains the following variables:
- I0R, I0G, I0B: Red, Green, Blue channel images (2D matrices)
- transfm: Transformation matrix (3x3 matrix)
- ROI: Region of Interest (2x4 matrix)

Usage:
  python ganerate_datamat.py <input> <output>
  <input> can be a single image file or a directory containing images
  <output> can be a single .mat file or a directory to save multiple .mat files
"""

import numpy as np
from scipy.io import savemat
import cv2
import os
import argparse
import glob

def generate_dataFace(input_image_path, output_mat_path):
    """
    Generate dataFace.mat file from an input image
    
    Args:
        input_image_path: Path to the input image (640x480 PNG recommended)
        output_mat_path: Path to save the generated dataFace.mat file
    """
    # Read the input image
    img = cv2.imread(input_image_path, cv2.IMREAD_COLOR)
    
    if img is None:
        print(f"Error: Could not read image {input_image_path}")
        return False
    
    # Check if image is 640x480, if not resize it
    if img.shape[0] != 480 or img.shape[1] != 640:
        print(f"Image is not 640x480, resizing from {img.shape[1]}x{img.shape[0]} to 640x480")
        img = cv2.resize(img, (640, 480))
    
    # Convert from BGR to RGB
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Split into R, G, B channels and ensure they are correct 2D arrays
    # Transpose if necessary to ensure correct orientation
    # Use float64 instead of float32 to ensure compatibility with MATLAB's double type
    R = img_rgb[:, :, 0].astype(np.float64)
    G = img_rgb[:, :, 1].astype(np.float64)
    B = img_rgb[:, :, 2].astype(np.float64)
    
    # Make sure channels are 2D with shape (480, 640)
    try:
        assert R.shape == (480, 640), f"R channel has wrong shape: {R.shape}"
        assert G.shape == (480, 640), f"G channel has wrong shape: {G.shape}"
        assert B.shape == (480, 640), f"B channel has wrong shape: {B.shape}"
    except AssertionError as e:
        print(f"Error processing {input_image_path}: {e}")
        return False
    
    # Create transformation matrix (identity matrix for single image)
    # Use float64 instead of float32 to ensure compatibility with MATLAB's double type
    trans = np.eye(3, dtype=np.float64)
    
    # Create ROI (Region of Interest) - full image in this case
    h, w = R.shape
    
    # Create ROI as a 2x4 matrix exactly as MATLAB expects
    # Use float64 instead of float32 to ensure compatibility with MATLAB's double type
    roi = np.zeros((2, 4), dtype=np.float64)
    roi[0, :] = [0, w-1, w-1, 0]     # x coordinates
    roi[1, :] = [0, 0, h-1, h-1]     # y coordinates
    
    # Create a dictionary with variables that match MATLAB's expected format
    mat_dict = {
        'I0R': R,
        'I0G': G,
        'I0B': B,
        'transfm': trans,
        'ROI': roi
    }
    
    # Save the .mat file using HDF5 format for better compatibility
    try:
        savemat(output_mat_path, mat_dict, appendmat=False, format='5')
        print(f"Generated {output_mat_path} from {input_image_path}")
        return True
    except Exception as e:
        print(f"Error saving {output_mat_path}: {e}")
        return False

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Generate dataFace.mat files from images')
    parser.add_argument('input', help='Input image file or directory')
    parser.add_argument('output', help='Output .mat file or directory')
    args = parser.parse_args()
    
    # Check if input is a directory
    if os.path.isdir(args.input):
        # Create output directory if it doesn't exist
        if not os.path.exists(args.output):
            os.makedirs(args.output)
        
        # Get all image files in the input directory
        image_extensions = ['*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff']
        image_files = []
        for ext in image_extensions:
            image_files.extend(glob.glob(os.path.join(args.input, ext)))
        
        # Process each image
        for img_file in image_files:
            # Generate output .mat file name
            base_name = os.path.splitext(os.path.basename(img_file))[0]
            output_mat = os.path.join(args.output, f"{base_name}.mat")
            
            # Process the image
            generate_dataFace(img_file, output_mat)
    else:
        # Input is a single file
        if os.path.isdir(args.output):
            # Output is a directory, generate output file name
            base_name = os.path.splitext(os.path.basename(args.input))[0]
            output_mat = os.path.join(args.output, f"{base_name}.mat")
        else:
            # Output is a single file
            output_mat = args.output
        
        # Process the single image
        generate_dataFace(args.input, output_mat)

if __name__ == "__main__":
    main()