% Batch processing script for SID algorithm
% Processes multiple .mat files and saves results to output directory

function batch_sid_process(input_dir, output_dir)
    % Check input directory
    if ~exist(input_dir, 'dir')
        error('Input directory does not exist: %s', input_dir);
    end
    
    % Create output directory if it doesn't exist
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Get all .mat files in input directory
    mat_files = dir(fullfile(input_dir, '*.mat'));
    num_files = length(mat_files);
    
    if num_files == 0
        disp('No .mat files found in input directory');
        return;
    end
    
    disp(['Found ' num2str(num_files) ' .mat files to process']);
    
    % Process each .mat file
    for i = 1:num_files
        % Get current file
        mat_file = mat_files(i);
        input_path = fullfile(input_dir, mat_file.name);
        
        % Generate output file name
        [~, base_name, ~] = fileparts(mat_file.name);
        output_path = fullfile(output_dir, [base_name '_result.mat']);
        
        disp(['Processing file ' num2str(i) '/' num2str(num_files) ': ' mat_file.name]);
        
        try
            % Call sidDemo with input and output paths
            sidDemo(input_path, output_path);
        catch ME
            disp(['Error processing ' mat_file.name ': ' ME.message]);
            continue;
        end
    end
    
    disp('Batch processing completed!');
end