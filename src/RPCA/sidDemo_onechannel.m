% Xiaojie Guo, Oct 2013. 
% Questions? xj.max.guo@gmail.com
% Modified to support batch processing

function sidDemo(input_mat_path, output_result_path)
    close all;clc;
    % Default paths if not provided
    if nargin < 1
        input_mat_path = '/home/gyh/code/specularityRemovalTask/SHIQ/src/RPCA/data/dataFace.mat';
    end
    
    if nargin < 2
        output_result_path = '';
    end
    
    % close all;clear all;clc;
    
    % Load data
    disp(['Loading data from: ' input_mat_path]);
    load(input_mat_path);
    
    % Define necessary variables
    tmpT = {transfm};  % Transformation matrix
    % Create cell arrays from loaded data
    cell_arrays = {I0R, I0G, I0B};

    % Rest of the existing code remains unchanged...
    % [ROI processing, transfm processing, image processing code]
    % Calculate canonSize from ROI
    % ROI is a 2x4 matrix: [x1 x2 x3 x4; y1 y2 y3 y4]
    h = max(ROI(2,:)) - min(ROI(2,:)) + 1;
    w = max(ROI(1,:)) - min(ROI(1,:)) + 1;
    canonSize = floor([h, w]);
    


    % Call SID function with limited iterations
    try
        % Get the cell arrays
        % tmpI = cell_arrays{1}; % R channel
        tmpI = {I0R};
        % Call SID for R channel with mode=2 to get only 1 iteration
        disp('Calling SID function for R channel with mode=2 (1 iteration only)...');
        
        % Call the original SID function with mode=2 which gives only 1 iteration
        [Fotr, Tr, Rr, Nr, tran] = SID(tmpI, tmpT, canonSize, 2);
        
        % Save results if output path is provided
        if ~isempty(output_result_path)
            disp(['Saving results to: ' output_result_path]);
            save(output_result_path, 'Fotr', 'Tr', 'Rr', 'Nr', 'tran', 'canonSize');
        end
        
        % Display results (optional)
        disp('Displaying results from single iteration...');
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

        % 新添加：保存高光分离后的图像
        if ~isempty(output_result_path)
            % 提取文件名（不含扩展名）
            [path, name, ~] = fileparts(output_result_path);
            
            % 重塑图像数据
            original_img = reshape(Fotr(:, 1), canonSize);
            transmittance_img = reshape(Tr(:, 1), canonSize);  % 无高光部分
            specular_img = reshape(Rr(:, 1), canonSize);       % 高光部分
            
            % 归一化到0-255范围
            original_img = (original_img - min(original_img(:))) / (max(original_img(:)) - min(original_img(:)));
            transmittance_img = (transmittance_img - min(transmittance_img(:))) / (max(transmittance_img(:)) - min(transmittance_img(:)));
            specular_img = (specular_img - min(specular_img(:))) / (max(specular_img(:)) - min(specular_img(:)));
            
            % 转换为uint8
            original_img = uint8(original_img * 255);
            transmittance_img = uint8(transmittance_img * 255);
            specular_img = uint8(specular_img * 255);
            
            % 保存图像
            original_path = fullfile(path, [name '_original.png']);
            transmittance_path = fullfile(path, [name '_transmittance.png']);
            specular_path = fullfile(path, [name '_specular.png']);
            
            imwrite(original_img, original_path);
            imwrite(transmittance_img, transmittance_path);
            imwrite(specular_img, specular_path);
            
            disp(['Images saved to:']);
            disp(['  Original: ' original_path]);
            disp(['  Transmittance (No Specular): ' transmittance_path]);
            disp(['  Specular (Highlight): ' specular_path]);
        end
        
    catch ME
        disp(['Error occurred: ' ME.message]);
        % Error handling code remains unchanged...
    end
end

% The fix_image_dimensions function remains at the end of the file