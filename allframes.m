% Define the paths to the image folders
net=alexnet;
image_folder1 = 'C:\Users\RHEA TIWARI\Downloads\all frames';


% Create an imageDatastore for each image folder separately
image_files = imageDatastore(image_folder1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
label_counts = countEachLabel(image_files);

% Find the minimum number of files associated with the labels
min_label_count = min(label_counts.Count);

% Determine the proportions of each subset based on the minimum label count
train_proportion = 0.7;
cv_proportion = 0.2;
test_proportion = 1 - train_proportion - cv_proportion;

% Check if any of the proportions are not positive
if train_proportion <= 0 || cv_proportion <= 0 || test_proportion <= 0
    error("Proportions must be positive numbers.");
end

% Split the dataset
[train_set, cv_set, test_set] = splitEachLabel(image_files, ...
    train_proportion, cv_proportion, test_proportion);
layers = net.Layers(1:end-3);
%for i = 1:numel(layers)
 %   if isa(layers(i), 'nnet.cnn.layer.Convolution2DLayer')
 %       layers(i).WeightLearnRateFactor = 0;
  %      layers(i).BiasLearnRateFactor = 0;
  %  end
%end

% Add new fully connected and classification output layers
numClasses = numel(categories(train_set.Labels));
layers(end+1) = fullyConnectedLayer(numClasses, 'Name', 'new_fc');
layers(end+1) = softmaxLayer('Name', 'softmax');
layers(end+1) = classificationLayer('Name', 'output');
% Define train_data (assuming it's the training set)
train_data = train_set;

% Define data augmentation
augmented_training_data = augmentedImageDatastore([227,227], train_set, "ColorPreprocessing", "gray2rgb");
augmented_cv_data = augmentedImageDatastore([227,227], cv_set, "ColorPreprocessing", "gray2rgb");
augmented_test_data = augmentedImageDatastore([227,227], test_set, "ColorPreprocessing", "gray2rgb");

% Now you can use augmented_training_data for training your model


% Now you can use augmented_training_data for training your model

% Get true labels for evaluation
true_labels = test_set.Labels;

disp(train_data);
%disp(size(test_auds));
%disp(auds)
%disp(true_labels)
disp(size(train_set.Labels))


numClasses = numel(categories(train_set.Labels));

lgraph = layerGraph(layers);

% Define options including cross-validation data
options = trainingOptions('sgdm', ...
    'MaxEpochs', 4, ...
    'MiniBatchSize', 48, ...
    'InitialLearnRate', 1e-3, ...
    'Momentum', 0.9, ...
    'ValidationData', augmented_cv_data, ... % Provide cross-validation data here
    'ValidationFrequency', 10, ... % Adjust validation frequency as needed
    'Plots', 'training-progress');

% Train the network
trained_network = trainNetwork(augmented_training_data, lgraph, options);


% Train the network
%trained_network = trainNetwork(augmented_training_data, lgraph, options);

predicted_labels = classify(trained_network, augmented_test_data);


%disp((predicted_labels));
disp(size(true_labels));

% Evaluate the performance of the network
accuracy = mean((predicted_labels == true_labels));
conf_matrix = confusionmat(true_labels, predicted_labels);

% Display evaluation results
disp(['Accuracy: ', num2str(accuracy)]);
disp('Confusion Matrix:');
disp(conf_matrix);

