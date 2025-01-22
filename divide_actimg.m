root_folder = "C:\Users\RHEA TIWARI\Downloads\all frames\notprocessed"; % Replace with the actual path
output_root_folder ="C:\Users\RHEA TIWARI\Downloads\all frames\400sizeHCM"; % Output folder path

% Get a list of all subfolders
subfolders = dir(root_folder);
subfolders = subfolders([subfolders.isdir]); % Keep only directories
subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'})); % Remove '.' and '..' directories

% Loop through each subfolder
for folder_idx = 1:length(subfolders)
    current_folder = fullfile(root_folder, subfolders(folder_idx).name);
    output_folder = fullfile(output_root_folder, subfolders(folder_idx).name);
    
    % Create the output subfolder if it doesn't exist
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    % Create a datastore for the images in the current subfolder
    image_files = imageDatastore(current_folder);
    
    % Loop through each image in the current subfolder
    for i = 1:length(image_files.Files)
        try
            % Read the image
            disp(['Processing image ', num2str(i), ': ', image_files.Files{i}]);
            image = imread(image_files.Files{i});
            
            % Get the size of the image
            [rows, cols, ~] = size(image);
            disp(['Image size: ', num2str(rows), 'x', num2str(cols)]);
            
            % Check if the image is large enough for the specified regions
            if rows >= 430 && cols >= 600
                % Define the regions to crop, ensuring indices are within bounds
               top = image(190:270, 280:530, :);
                middle_left = image(270:355, 220:380, :);
                middle_right = image(270:355, 380:540, :);
                bottom_left = image(355:455, 135:285, :);
                bottom_middle = image(355:455, 285:445, :);
                bottom_right = image(355:455, 445:605, :);
                last = image(435:550, 190:600, :);
                % Save the divided images to the output folder
                imwrite(top, fullfile(output_folder, sprintf('top_%d.jpg', i)));
                imwrite(middle_left, fullfile(output_folder, sprintf('top_left_%d.jpg', i)));
                imwrite(middle_right, fullfile(output_folder, sprintf('top_right_%d.jpg', i)));
                imwrite(bottom_left, fullfile(output_folder, sprintf('bottom_left_%d.jpg', i)));
                imwrite(bottom_middle, fullfile(output_folder, sprintf('bottom_middle_%d.jpg', i)));
                imwrite(bottom_right, fullfile(output_folder, sprintf('bottom_right_%d.jpg', i)));
                imwrite(last, fullfile(output_folder, sprintf('last_%d.jpg', i)));
            else
                disp(['Skipping image ', num2str(i), ': dimensions are too small.']);
            end
        catch ME
            % Log any errors encountered during processing
            disp(['Error processing image ', num2str(i), ': ', ME.message]);
        end
    end
end



