% Xiaojie Guo, Oct 2013. 
% Questions? xj.max.guo@gmail.com
%
% Reference: Robust Separation of Reflection Using Multiple Images,
% Xiaojie Guo, Xiaochun Cao and Yi Ma, CVPR 2014
%
% Modified version with enhanced error handling and input validation

close all;clear all;clc;

% Load data
load('/home/gyh/code/specularityRemovalTask/SHIQ/src/RPCA/data/dataFace.mat');

% Display loaded variables
disp('Loaded variables:');
who

% Check ROI format and calculate canonSize accordingly
try
    roi_data = ROI;
    disp(['Direct ROI class: ' class(roi_data)]);
    disp(['Direct ROI size: ' mat2str(size(roi_data))]);
    
    % Handle 3D array if needed
    if ndims(roi_data) == 3
        roi_data = squeeze(roi_data);
        disp(['After squeeze, ROI size: ' mat2str(size(roi_data))]);
    end
    
    if size(roi_data,1) >= 2
        canonSize = floor([max(roi_data(2,:))-min(roi_data(2,:)),...
                     max(roi_data(1,:))-min(roi_data(1,:))]+1);
        disp('Using direct ROI matrix access');
    end
catch ME
    disp(['ROI access failed: ' ME.message]);
    canonSize = [480, 640]; % Default to expected size
    disp('Using default canonSize [480, 640]');
end

% Ensure canonSize is double, 1-by-2 vector with real values
canonSize = double(reshape(canonSize, 1, 2));
disp(['Final canonSize: ' mat2str(canonSize)]);
disp(['Final canonSize class: ' class(canonSize)]);

% Check and fix transfm matrix
disp(['Original transfm class: ' class(transfm)]);
disp(['Original transfm size: ' mat2str(size(transfm))]);

if ndims(transfm) > 2
    transfm = squeeze(transfm);
    disp(['After squeeze, transfm size: ' mat2str(size(transfm))]);
end

if size(transfm, 1) ~= 3 || size(transfm, 2) ~= 3
    transfm = eye(3);
    disp('Created new identity transformation matrix');
else
    transfm = double(transfm);
end

% Check for NaN or Inf in transfm
if any(isnan(transfm(:))) || any(isinf(transfm(:)))
    disp('Warning: transfm contains NaN or Inf values, replacing with identity matrix');
    transfm = eye(3);
end

% Create cell arrays for SID function input
tmpT = {transfm};
disp('Created transfm cell array');

% Process each color channel
channels = {'R', 'G', 'B'};
image_vars = {'I0R', 'I0G', 'I0B'};
cell_arrays = cell(1, 3);

for i = 1:3
    channel_name = channels{i};
    var_name = image_vars{i};
    
    % Get the image data
    img_data = eval(var_name);
    
    % Fix dimensions
    disp(['\nProcessing ' channel_name ' channel:']);
    disp(['Original ' var_name ' size: ' mat2str(size(img_data))]);
    
    img_fixed = fix_image_dimensions(img_data, [480, 640]);
    disp(['Fixed ' var_name ' size: ' mat2str(size(img_fixed))]);
    
    % Normalize to [0, 1] range for better numerical stability
    img_norm = double(img_fixed) / 255.0;
    disp(['Normalized ' var_name ' to [0, 1] range']);
    
    % Convert to cell array
    cell_arrays{i} = {img_norm};
    disp(['Converted ' channel_name ' to cell array (double)']);
end

% Call SID function with limited iterations (only 1 iteration)
try
    % Get the cell arrays
    tmpI = cell_arrays{1}; % R channel
    
    % Call SID for R channel with mode=2 to get only 1 iteration
    disp('\nCalling SID function for R channel with mode=2 (1 iteration only)...');
    
    % Add additional debugging info
    disp(['tmpI structure:']);
    disp(['  Class: ' class(tmpI)]);
    disp(['  Size: ' mat2str(size(tmpI))]);
    disp(['  Element class: ' class(tmpI{1})]);
    disp(['  Element size: ' mat2str(size(tmpI{1}))]);
    disp(['  Element range: [' num2str(min(tmpI{1}(:))) ', ' num2str(max(tmpI{1}(:))) ']']);
    
    disp(['tmpT structure:']);
    disp(['  Class: ' class(tmpT)]);
    disp(['  Size: ' mat2str(size(tmpT))]);
    disp(['  Element class: ' class(tmpT{1})]);
    disp(['  Element size: ' mat2str(size(tmpT{1}))]);
    
    % Call the original SID function with mode=2 which gives only 1 iteration
    [Fotr, Tr, Rr, Nr, tran] = SID(tmpI, tmpT, canonSize, 2);
    
    % Display results for R channel
    disp('\nDisplaying results from single iteration...');
    figure;
    subplot(1, 3, 1);
    imshow(reshape(Fotr(:, 1), canonSize), []);
    title('Fot (R channel)');
    
    subplot(1, 3, 2);
    imshow(reshape(Tr(:, 1), canonSize), []);
    title('T (R channel)');
    
    subplot(1, 3, 3);
    imshow(reshape(Rr(:, 1), canonSize), []);
    title('R (R channel)');
    
catch ME
    disp(['\nError occurred: ' ME.message]);
    disp(['Error identifier: ' ME.identifier]);
    
    if isfield(ME, 'stack') && ~isempty(ME.stack)
        disp(['\nError stack trace:']);
        for k = 1:length(ME.stack)
            disp(['  ' k '. ' ME.stack(k).file ' at line ' num2str(ME.stack(k).line)]);
            disp(['     Function: ' ME.stack(k).name]);
        end
    end
    
    % Check if we have the debug variables
    if exist('tmpI', 'var')
        disp(['\nDebug info - tmpI:']);
        disp(['  Class: ' class(tmpI)]);
        disp(['  Size: ' mat2str(size(tmpI))]);
        if ~isempty(tmpI)
            disp(['  First element size: ' mat2str(size(tmpI{1}))]);
        end
    end
    
    if exist('tmpT', 'var')
        disp(['\nDebug info - tmpT:']);
        disp(['  Class: ' class(tmpT)]);
        disp(['  Size: ' mat2str(size(tmpT))]);
        if ~isempty(tmpT)
            disp(['  First element size: ' mat2str(size(tmpT{1}))]);
        end
    end
    
    if exist('canonSize', 'var')
        disp(['\nDebug info - canonSize:']);
        disp(['  Class: ' class(canonSize)]);
        disp(['  Size: ' mat2str(size(canonSize))]);
        disp(['  Value: ' mat2str(canonSize)]);
    end
end

% Function to fix image dimensions (moved to end of file)
function img_fixed = fix_image_dimensions(img, expected_size)
    % Correct way to extract dimensions from vector in MATLAB
    h = expected_size(1);
    w = expected_size(2);
    
    % First try simple squeeze
    img_squeezed = squeeze(img);
    
    if isequal(size(img_squeezed), [h, w])
        img_fixed = img_squeezed;
        return;
    end
    
    % Try transpose if dimensions are swapped
    if isequal(size(img_squeezed), [w, h])
        img_fixed = transpose(img_squeezed);
        disp('Transposed image to fix dimensions');
        return;
    end
    
    % Try reshaping if number of elements matches
    if numel(img_squeezed) == h * w
        img_fixed = reshape(img_squeezed, h, w);
        disp('Reshaped image to fix dimensions');
        return;
    end
    
    % Final fallback - create a new array
    img_fixed = zeros(h, w, class(img));
    
    % Copy as much as possible
    [src_h, src_w] = size(img_squeezed);
    copy_h = min(src_h, h);
    copy_w = min(src_w, w);
    img_fixed(1:copy_h, 1:copy_w) = img_squeezed(1:copy_h, 1:copy_w);
    
    disp('Created new image with correct dimensions (filled with zeros where needed)');
end