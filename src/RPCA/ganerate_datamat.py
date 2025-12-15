#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
This script generates the dataFace.mat file required by sidDemo.m
The file contains the following variables:
- I0R, I0G, I0B: Red, Green, Blue channel images (2D matrices)
- transfm: Transformation matrix (3x3 matrix)
- ROI: Region of Interest (2x4 matrix)
"""

import numpy as np
from scipy.io import savemat
import cv2

def generate_dataFace(input_image_path, output_mat_path):
    """
    Generate dataFace.mat file from an input image
    
    Args:
        input_image_path: Path to the input image (640x480 PNG recommended)
        output_mat_path: Path to save the generated dataFace.mat file
    """
    # Read the input image
    img = cv2.imread(input_image_path, cv2.IMREAD_COLOR)
    
    # Check if image is 640x480, if not resize it
    if img.shape[0] != 480 or img.shape[1] != 640:
        print(f"Image is not 640x480, resizing from {img.shape[1]}x{img.shape[0]} to 640x480")
        img = cv2.resize(img, (640, 480))
    
    # Convert from BGR to RGB
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # Split into R, G, B channels and ensure they are correct 2D arrays
    # Transpose if necessary to ensure correct orientation
    R = img_rgb[:, :, 0].astype(np.float32)
    G = img_rgb[:, :, 1].astype(np.float32)
    B = img_rgb[:, :, 2].astype(np.float32)
    
    # Make sure channels are 2D with shape (480, 640)
    assert R.shape == (480, 640), f"R channel has wrong shape: {R.shape}"
    assert G.shape == (480, 640), f"G channel has wrong shape: {G.shape}"
    assert B.shape == (480, 640), f"B channel has wrong shape: {B.shape}"
    
    print(f"Channel shapes in Python:")
    print(f"  R: {R.shape}")
    print(f"  G: {G.shape}")
    print(f"  B: {B.shape}")
    
    # Create transformation matrix (identity matrix for single image)
    trans = np.eye(3, dtype=np.float32)
    print(f"Transformation matrix shape: {trans.shape}")
    
    # Create ROI (Region of Interest) - full image in this case
    h, w = R.shape
    
    # Create ROI as a 2x4 matrix exactly as MATLAB expects
    roi = np.zeros((2, 4), dtype=np.float32)
    roi[0, :] = [0, w-1, w-1, 0]     # x coordinates
    roi[1, :] = [0, 0, h-1, h-1]     # y coordinates
    
    print(f"Generated ROI matrix:")
    print(f"  x coordinates: {roi[0, :]}")
    print(f"  y coordinates: {roi[1, :]}")
    print(f"  ROI shape: {roi.shape}")
    
    # Create a dictionary with variables that match MATLAB's expected format
    # IMPORTANT: We'll save them as direct 2D matrices, not cell arrays
    # We'll let MATLAB convert them to cell arrays if needed
    mat_dict = {
        'I0R': R,
        'I0G': G,
        'I0B': B,
        'transfm': trans,
        'ROI': roi
    }
    
    # Save the .mat file using HDF5 format for better compatibility
    savemat(output_mat_path, mat_dict, appendmat=False, format='5')
    
    print(f"\nGenerated dataFace.mat at {output_mat_path}")
    print(f"Image dimensions: {w}x{h}")
    print("Variables saved as direct 2D matrices.")

if __name__ == "__main__":
    import os
    
    # Create data directory if it doesn't exist
    data_dir = os.path.join(os.path.dirname(__file__), 'data')
    if not os.path.exists(data_dir):
        os.makedirs(data_dir)
    
    # Path to input image
    input_image = '/home/gyh/code/specularityRemovalTask/SHIQ/network/data/36.jpg'
    
    # Output path for dataFace.mat
    output_mat = os.path.join(data_dir, 'dataFace.mat')
    
    # Generate the .mat file
    generate_dataFace(input_image, output_mat)