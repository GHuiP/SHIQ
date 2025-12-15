% Xiaojie Guo, Oct 2013. Modified for 640x480 images
% Questions? xj.max.guo@gmail.com
% This script processes 640x480 PNG images for specular highlight separation

close all;clear all;clc;

% User-defined parameters
INPUT_DIR = '<your_input_dir>'; % Directory containing 640x480 PNG images
OUTPUT_DIR = '<your_output_dir>'; % Directory to save separated results

% Create output directory if it doesn't exist
if ~exist(OUTPUT_DIR, 'dir')
    mkdir(OUTPUT_DIR);
end

% Get list of input images (assuming .png format)
image_files = dir(fullfile(INPUT_DIR, '*.png'));

for i = 1:numel(image_files)
    % Read the input image
    image_path = fullfile(INPUT_DIR, image_files(i).name);
    I = im2double(imread(image_path));
    
    % Check if image is 640x480
    [h, w, c] = size(I);
    if h ~= 480 || w ~= 640
        warning('Image %s is not 640x480, skipping...', image_files(i).name);
        continue;
    end
    
    disp(['Processing image: ' image_files(i).name]);
    
    % Prepare data for SID function
    I0R = I(:,:,1);
    I0G = I(:,:,2);
    I0B = I(:,:,3);
    
    % Set up transformation matrix (identity for single image)
    tmpT = eye(3, 3, 'single');
    
    % Set canonical size to 640x480
    canonSize = [h, w];
    
    % For R channel
    mode = 1; % Initialize mode
    [Fotr, Tr, Rr, Nr, tran] = SID(I0R, tmpT, canonSize, mode);
    tmpT = tran;
    
    % For G channel
    mode = 0;
    [Fotg, Tg, Rg, Ng] = SID(I0G, tmpT, canonSize, mode);
    
    % For B channel
    [Fotb, Tb, Rb, Nb] = SID(I0B, tmpT, canonSize, mode);
    
    % Reshape results
    diffuse_R = reshape(Fotr, canonSize);
    diffuse_G = reshape(Fotg, canonSize);
    diffuse_B = reshape(Fotb, canonSize);
    
    specular_R = reshape(Tr, canonSize);
    specular_G = reshape(Tg, canonSize);
    specular_B = reshape(Tb, canonSize);
    
    % Combine channels
    diffuse = cat(3, diffuse_R, diffuse_G, diffuse_B);
    specular = cat(3, specular_R, specular_G, specular_B);
    input_img = cat(3, I0R, I0G, I0B);
    
    % Save results with standard naming convention
    [~, name, ~] = fileparts(image_files(i).name);
    
    % Input image (_A)
    imwrite(input_img, fullfile(OUTPUT_DIR, [name '_A.png']));
    
    % Diffuse image (_D)
    imwrite(diffuse, fullfile(OUTPUT_DIR, [name '_D.png']));
    
    % Specular image (_S)
    imwrite(specular, fullfile(OUTPUT_DIR, [name '_S.png']));
    
    disp(['Saved results for ' image_files(i).name]);
end

close all;
disp('All images processed successfully!');