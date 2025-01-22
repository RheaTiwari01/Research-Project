% Specify the root folder containing the 41 subfolders, each containing 10 images
root_folder = "C:\Users\RHEA TIWARI\Desktop\researchproject\archive (7)"; % Replace 'path_to_root_folder' with the actual path

% Get a list of all subfolders
subfolders = dir(root_folder);
subfolders = subfolders([subfolders.isdir]); % Keep only directories
subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'})); % Remove '.' and '..' directories

% Loop through each subfolder
for folder_idx = 1:length(subfolders)
    current_folder = fullfile(root_folder, subfolders(folder_idx).name);
    
    % Create a datastore for the images in the current subfolder
    image_files = imageDatastore(current_folder);
    
    % Loop through each image in the current subfolder
    for i = 1:length(image_files.Files)
        % Read the image
        image = imread(image_files.Files{i});
        
        % Get the size of the image
        [rows, cols, ~] = size(image);
        
        % Calculate the midpoints of rows and columns
        mid_row = floor(rows / 2);
        mid_col = floor(cols / 2);
        
        % Divide the image into quarters
        top_left = image(1:mid_row, 1:mid_col, :);
        top_right = image(1:mid_row, mid_col+1:end, :);
        bottom_left = image(mid_row+1:end, 1:mid_col, :);
        bottom_right = image(mid_row+1:end, mid_col+1:end, :);
        
        
        % Save the divided images back into the current folder
        imwrite(top_left, fullfile(current_folder, sprintf('top_left_%d.jpg', i)));
        imwrite(top_right, fullfile(current_folder, sprintf('top_right_%d.jpg', i)));
        imwrite(bottom_left, fullfile(current_folder, sprintf('bottom_left_%d.jpg', i)));
        imwrite(bottom_right, fullfile(current_folder, sprintf('bottom_right_%d.jpg', i)));
    end
end
 % Remove '.' and '..' directories

% Loop through each subfolder


