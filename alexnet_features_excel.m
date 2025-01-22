% Load the pretrained AlexNet model
net = alexnet;

% Specify the path to your image data folder
dataFolder = "C:\Users\RHEA TIWARI\Downloads\features frames\small normal";

% Load the pretrained AlexNet model

% Create an Image Datastore
imds = imageDatastore(dataFolder, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% Define the input size
inputSize = net.Layers(1).InputSize;

% Initialize a cell array to store the features for each image
allImageFeatures = {};

% Loop through each image in the datastore
while hasdata(imds)
    % Read the next image
    img = read(imds);
    
    % Resize the image to match the input size of the network
    img = imresize(img, [inputSize(1) inputSize(2)]);
    
    % Initialize a cell array to store the features from all layers for the current image
    imageFeatures = cell(numel(net.Layers), 1);
    
    % Loop through each layer and extract features
    for i = 1:numel(net.Layers)
        layerName = net.Layers(i).Name;
        try
            features = activations(net, img, layerName);
            imageFeatures{i} = features;
            disp(['Extracted features from layer: ', layerName]);
        catch ME
            disp(['Could not extract features from layer: ', layerName]);
            disp(ME.message);
        end
    end
    
    % Store the features for the current image
    allImageFeatures{end+1} = imageFeatures;
end
clear layerName
clear imageFeatures
% Determine the maximum length of feature vectors
maxLength = 0;
for imgIdx = 1:numel(allImageFeatures)
    for layerIdx = 1:numel(net.Layers)
        if ~isempty(allImageFeatures{imgIdx}{layerIdx})
            features = reshape(allImageFeatures{imgIdx}{layerIdx}, 1, []);
            maxLength = max(maxLength, numel(features));
        end
    end
end

% Create a table to store features for writing to Excel
featureTable = table;

% Loop through each image and each layer to flatten the features and add them to the table
for imgIdx = 1:numel(allImageFeatures)
    for layerIdx = 1:numel(net.Layers)
        if ~isempty(allImageFeatures{imgIdx}{layerIdx})
            % Flatten the features into a row vector
            features = reshape(allImageFeatures{imgIdx}{layerIdx}, 1, []);
            
            % Pad the feature vector with NaNs to match the maximum length
            paddedFeatures = nan(1, maxLength);
            paddedFeatures(1:numel(features)) = features;
            
            % Create a column name for the features
            colName = sprintf('Image%d_Layer%s', imgIdx, net.Layers(layerIdx).Name);
            
            % Add the features as a new column to the table
            featureTable.(colName) = paddedFeatures';
        end
    end
end

% Write the table to an Excel file
writetable(featureTable, 'extracted_features.xlsx');
