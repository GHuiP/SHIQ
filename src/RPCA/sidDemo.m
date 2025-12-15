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
    
    % Load data
    disp(['Loading data from: ' input_mat_path]);
    load(input_mat_path);
    
    % Define necessary variables
    tmpT = {transfm};  % Transformation matrix
    
    % Calculate canonSize from ROI
    % ROI is a 2x4 matrix: [x1 x2 x3 x4; y1 y2 y3 y4]
    h = max(ROI(2,:)) - min(ROI(2,:)) + 1;
    w = max(ROI(1,:)) - min(ROI(1,:)) + 1;
    canonSize = floor([h, w]);
    
    % Call SID function for each channel
    try
        % Process all three channels (R, G, B)
        channels = {'R', 'G', 'B'};
        channel_data = {I0R, I0G, I0B};
        
        % Initialize variables to store results for each channel
        Fots = cell(1, 3);
        Ts = cell(1, 3);
        Rs = cell(1, 3);
        Ns = cell(1, 3);
        
        for i = 1:3
            disp(['Calling SID function for ' channels{i} ' channel with mode=2 (1 iteration only)...']);
            
            % Call the original SID function for current channel
            [Fots{i}, Ts{i}, Rs{i}, Ns{i}, tran] = SID({channel_data{i}}, tmpT, canonSize, 2);
        end
        
        % Save results if output path is provided
        if ~isempty(output_result_path)
            disp(['Saving results to: ' output_result_path]);
            save(output_result_path, 'Fots', 'Ts', 'Rs', 'Ns', 'tran', 'canonSize');
        end
        
        % Display results (optional) - show all channels
        disp('Displaying results from single iteration...');
        figure;
        for i = 1:3
            subplot(3, 3, i); % Original images
            imshow(reshape(Fots{i}(:, 1), canonSize), []);
            title(['Fot (' channels{i} ' channel)']);
            
            subplot(3, 3, i+3); % Transmittance images
            imshow(reshape(Ts{i}(:, 1), canonSize), []);
            title(['T (' channels{i} ' channel)']);
            
            subplot(3, 3, i+6); % Specular images
            imshow(reshape(Rs{i}(:, 1), canonSize), []);
            title(['R (' channels{i} ' channel)']);
        end
        
        % 新添加：保存彩色高光分离后的图像
        if ~isempty(output_result_path)
            % 提取文件名（不含扩展名）
            [path, name, ~] = fileparts(output_result_path);
            
            % 重塑每个通道的图像数据
            original_R = reshape(Fots{1}(:, 1), canonSize);
            original_G = reshape(Fots{2}(:, 1), canonSize);
            original_B = reshape(Fots{3}(:, 1), canonSize);
            
            transmittance_R = reshape(Ts{1}(:, 1), canonSize);  % 无高光部分 R
            transmittance_G = reshape(Ts{2}(:, 1), canonSize);  % 无高光部分 G
            transmittance_B = reshape(Ts{3}(:, 1), canonSize);  % 无高光部分 B
            
            specular_R = reshape(Rs{1}(:, 1), canonSize);       % 高光部分 R
            specular_G = reshape(Rs{2}(:, 1), canonSize);       % 高光部分 G
            specular_B = reshape(Rs{3}(:, 1), canonSize);       % 高光部分 B
            
            % 归一化到0-255范围
            % 处理原始图像
            original_min = min([original_R(:); original_G(:); original_B(:)]);
            original_max = max([original_R(:); original_G(:); original_B(:)]);
            
            original_R_norm = (original_R - original_min) / (original_max - original_min);
            original_G_norm = (original_G - original_min) / (original_max - original_min);
            original_B_norm = (original_B - original_min) / (original_max - original_min);
            
            % 处理透射率图像
            transmittance_min = min([transmittance_R(:); transmittance_G(:); transmittance_B(:)]);
            transmittance_max = max([transmittance_R(:); transmittance_G(:); transmittance_B(:)]);
            
            transmittance_R_norm = (transmittance_R - transmittance_min) / (transmittance_max - transmittance_min);
            transmittance_G_norm = (transmittance_G - transmittance_min) / (transmittance_max - transmittance_min);
            transmittance_B_norm = (transmittance_B - transmittance_min) / (transmittance_max - transmittance_min);
            
            % 处理高光图像
            specular_min = min([specular_R(:); specular_G(:); specular_B(:)]);
            specular_max = max([specular_R(:); specular_G(:); specular_B(:)]);
            
            specular_R_norm = (specular_R - specular_min) / (specular_max - specular_min);
            specular_G_norm = (specular_G - specular_min) / (specular_max - specular_min);
            specular_B_norm = (specular_B - specular_min) / (specular_max - specular_min);
            
            % 合并通道为彩色图像
            original_color = cat(3, uint8(original_R_norm * 255), uint8(original_G_norm * 255), uint8(original_B_norm * 255));
            transmittance_color = cat(3, uint8(transmittance_R_norm * 255), uint8(transmittance_G_norm * 255), uint8(transmittance_B_norm * 255));
            specular_color = cat(3, uint8(specular_R_norm * 255), uint8(specular_G_norm * 255), uint8(specular_B_norm * 255));
            
            % 保存图像
            original_path = fullfile(path, [name '_original_color.png']);
            transmittance_path = fullfile(path, [name '_transmittance_color.png']);
            specular_path = fullfile(path, [name '_specular_color.png']);
            
            imwrite(original_color, original_path);
            imwrite(transmittance_color, transmittance_path);
            imwrite(specular_color, specular_path);
            
            disp(['Color images saved to:']);
            disp(['  Original: ' original_path]);
            disp(['  Transmittance (No Specular): ' transmittance_path]);
            disp(['  Specular (Highlight): ' specular_path]);
        end
        
    catch ME
        disp(['Error occurred: ' ME.message]);
        % Error handling code remains unchanged...
    end
end