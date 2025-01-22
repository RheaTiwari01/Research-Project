net = alexnet;


image_folder =""; % Replace 'path_to_your_images' with the actual path to your images
image_files = dir(fullfile(image_folder, '*.jpg')); % Assumes all images are in JPG format


rng('default'); % Set random seed for reproducibility
shuffled_indices = randperm(numel(image_files));
shuffled_files = image_files(shuffled_indices);


total_samples = numel(shuffled_files);
train_size = round(0.7 * total_samples);
cv_size = round(0.2 * total_samples);
test_size = total_samples - train_size - cv_size;


train_indices = 1:train_size;
cv_indices = train_size+1:train_size+cv_size;
test_indices = train_size+cv_size+1:total_samples;

% Copy images to their respective folders
train_folder = 'train';
cv_folder = 'cv';
test_folder = 'test';


if ~exist(train_folder, 'dir')
    mkdir(train_folder);
end
if ~exist(cv_folder, 'dir')
    mkdir(cv_folder);
end
if ~exist(test_folder, 'dir')
    mkdir(test_folder);
end

% Move images to train folder
for i = train_indices
    copyfile(fullfile(image_folder, shuffled_files(i).name), train_folder);
end

% Move images to cross-validation folder
for i = cv_indices
    copyfile(fullfile(image_folder, shuffled_files(i).name), cv_folder);
end

% Move images to test folder
for i = test_indices
    copyfile(fullfile(image_folder, shuffled_files(i).name), test_folder);
end

disp(['Training Set Size: ', num2str(train_size)]);
disp(['Cross-Validation Set Size: ', num2str(cv_size)]);
disp(['Testing Set Size: ', num2str(test_size)]);

train_data = imageDatastore(train_folder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');


cv_data = imageDatastore(cv_folder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');


test_data = imageDatastore(test_folder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% Display the sizes of each dataset
disp(['Training Set Size: ', num2str(numel(train_data.Files))]);
disp(['Cross-Validation Set Size: ', num2str(numel(cv_data.Files))]);
disp(['Testing Set Size: ', num2str(numel(test_data.Files))]);

% Create augmented image datastores
auds = augmentedImageDatastore([227,227], train_data, "ColorPreprocessing", "gray2rgb");
cv_auds = augmentedImageDatastore([227,227], cv_data, "ColorPreprocessing", "gray2rgb");
test_auds = augmentedImageDatastore([227,227], test_data, "ColorPreprocessing", "gray2rgb");

% Display the sizes of augmented datastores
disp(['Augmented Training Set Size: ', num2str(numel(auds.Files))]);
disp(['Augmented Cross-Validation Set Size: ', num2str(numel(cv_auds.Files))]);
disp(['Augmented Testing Set Size: ', num2str(numel(test_auds.Files))]);

% Get true labels for evaluation
true_labels = test_data.Labels;

disp(train_data);
disp(size(test_auds));
%disp(auds)
%disp(true_labels)
disp(size(train_data.Labels))


numClasses = numel(categories(train_data.Labels));
layers = net.Layers;

layers = layers(1:end-1);

% Add a new fully connected layer with the number of units equal to the number of classes
layers(end+1) = fullyConnectedLayer(numClasses, 'Name', 'new_fc');

% Add a classification output layer
layers(end+1) = classificationLayer('Name', 'new_output');

lgraph = layerGraph(layers);

options = trainingOptions('sgdm', 'MaxEpochs', 4, 'MiniBatchSize', 48, 'InitialLearnRate', 1e-3, 'Momentum', 0.9, 'Plots', 'training-progress');

% Train the network
trained_network = trainNetwork(auds, lgraph, options);

predicted_labels = classify(trained_network, test_auds);


%disp((predicted_labels));
disp(size(true_labels));

% Evaluate the performance of the network
accuracy = mean((predicted_labels == true_labels));
conf_matrix = confusionmat(true_labels, predicted_labels);

% Display evaluation results
disp(['Accuracy: ', num2str(accuracy)]);
disp('Confusion Matrix:');
disp(conf_matrix);

