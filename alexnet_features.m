% % Load the pretrained AlexNet model
% net = alexnet;
% 
% % Specify the path to your image data folder
% dataFolder = "C:\Users\RHEA TIWARI\Downloads\features frames\small normal";
% 
% % Load the pretrained AlexNet model
% 
% % Create an Image Datastore
% imds = imageDatastore(dataFolder, ...
%     'IncludeSubfolders', true, ...
%     'LabelSource', 'foldernames');
% 
% % Define the input size
% inputSize = net.Layers(1).InputSize;
% 
% % Initialize a cell array to store the features for each image
% allImageFeatures = {};
% 
% % Loop through each image in the datastore
% while hasdata(imds)
%     % Read the next image
%     img = read(imds);
% 
%     % Resize the image to match the input size of the network
%     img = imresize(img, [inputSize(1) inputSize(2)]);
% 
%     % Extract features from the drop7 layer
%     try
%         features = activations(net, img, 'drop7');
%         features = reshape(features, 1, []);
%         allImageFeatures{end+1} = features;
%         disp(['Extracted features from image ', num2str(numel(allImageFeatures)), ':']);
%         disp(features);
%     catch ME
%         disp('Could not extract features from layer: drop7');
%         disp(ME.message);
%     end
% end
% 
% % Display the features for each image
% for imgIdx = 1:numel(allImageFeatures)
%     disp(['Features for Image ', num2str(imgIdx), ':']);
%     disp(allImageFeatures{imgIdx});
% end
% 
% disp('Feature extraction completed.');
% Load the pretrained AlexNet model
% Load the pretrained AlexNet model
% net = alexnet;
% 
% % Specify the path to your image data folder
% dataFolder = "C:\Users\RHEA TIWARI\Downloads\features frames\normal";
% 
% % Load AlexNet
% %net = alexnet;
% 
% % Replace 'drop7' layer with a fully connected layer to get the activations
% layerName = 'drop7';
% 
% % Specify the folder containing images
% 
% imds = imageDatastore(dataFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
% 
% % Initialize matrix to store features
% numImages = numel(imds.Files);
% features = zeros(numImages, 4096);
% 
% % Process each image
% for i = 1:numImages
%     img = readimage(imds, i);
%     % Resize the image to match AlexNet input size
%     img = imresize(img, [227, 227]);
%     % Extract features using the specified layer
%     featureVector = activations(net, img, layerName, 'OutputAs', 'rows');
%     % Store features in matrix
%     features(i, :) = featureVector;
% end
% 
% % Convert features to table for easy writing to Excel
% featuresTable = array2table(features);
% 
% % Specify the output file name
% outputFileName = 'image_features_normal.xlsx';
% 
% % Write the table to an Excel file
% writetable(featuresTable, outputFileName);
% 
% disp(['Features extracted and saved to ', outputFileName]);
% 
% Load AlexNet
net = alexnet;

% Replace 'drop7' layer with a fully connected layer to get the activations
layerName = 'drop7';

% Specify the folder containing images
imageFolder ="C:\Users\RHEA TIWARI\Downloads\FINAL NORMAL";
% % Load AlexNet

imds = imageDatastore(imageFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% Initialize matrix to store features
numImages = numel(imds.Files);
features = zeros(numImages, 4096);
filenames = cell(numImages, 1);

% Process each image
for i = 1:numImages
    img = readimage(imds, i);
    % Resize the image to match AlexNet input size
    img = imresize(img, [227, 227]);
    % Extract features using the specified layer
    featureVector = activations(net, img, layerName, 'OutputAs', 'rows');
    % Store features in matrix
    features(i, :) = featureVector;
    % Store the full filename
    [~, name, ext] = fileparts(imds.Files{i});
    filenames{i} = [name, ext];
end

% Convert features to table and include filenames
featuresTable = array2table(features, 'VariableNames', strcat('Feature_', string(1:4096)));
filenamesTable = table(filenames, 'VariableNames', {'Filename'});
resultTable = [filenamesTable, featuresTable];

% Specify the output file name
outputFileName = 'image_features_finalfolder.xlsx';

% Write the table to an Excel file
writetable(resultTable, outputFileName);

disp(['Features extracted and saved to ', outputFileName]);
