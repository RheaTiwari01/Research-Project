net = alexnet;

% Load your image dataset
image_folder ="C:\Users\RHEA TIWARI\Downloads\all frames";
image_files = imageDatastore(image_folder, "IncludeSubfolders", true, "LabelSource", "foldernames");

% Determine the proportions of each subset based on the minimum label count
train_proportion = 0.7;
cv_proportion = 0.15;
test_proportion = 1 - train_proportion - cv_proportion;

% Check if any of the proportions are not positive
if train_proportion <= 0 || cv_proportion <= 0 || test_proportion <= 0
    error("Proportions must be positive numbers.");
end

% Split the dataset
[train_set, cv_set, test_set] = splitEachLabel(image_files, ...
    train_proportion, cv_proportion, test_proportion);

% Define data augmentation
augmented_training_data = augmentedImageDatastore([227, 227,3], train_set, "ColorPreprocessing", "gray2rgb");
augmented_cv_data = augmentedImageDatastore([227, 227,3], cv_set, "ColorPreprocessing", "gray2rgb");
augmented_test_data = augmentedImageDatastore([227, 227,3], test_set, "ColorPreprocessing", "gray2rgb");

% Define the CNN architecture
% Define the CNN architecture
layers = [
    imageInputLayer([227 227 3], 'Name', 'input')
    net.Layers(2:end-3)
    fullyConnectedLayer(numClasses, 'Name', 'new_fc')
    softmaxLayer('Name', 'softmax')
    classificationLayer('Name', 'output')
];

% Define options including cross-validation data
options = trainingOptions('sgdm', ...
    'MaxEpochs', 6, ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 0.003, ...
    'Momentum', 0.9, ...
    'ValidationData', augmented_cv_data, ... % Provide cross-validation data here
    'ValidationFrequency', floor(numel(augmented_training_data.Files)/32), ... % Adjust validation frequency as needed
    'Plots', 'training-progress', ...
    'Verbose', true, ...
    'ExecutionEnvironment', 'auto', ... % Use GPU if available
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 5, ...
    'ValidationPatience', 5, ... % Stop training if validation accuracy doesn't improve for 5 consecutive epochs
    'Shuffle', 'every-epoch', ...
    'CheckpointPath', tempdir);

% Train the network
trained_network = trainNetwork(augmented_training_data, layers, options);

% Evaluate on the test set
predicted_labels = classify(trained_network, augmented_test_data);
true_labels = test_set.Labels;

% Calculate accuracy
accuracy = mean(predicted_labels == true_labels);
disp(['Test Accuracy: ', num2str(accuracy * 100), '%']);

% Calculate confusion matrix
conf_matrix = confusionmat(true_labels, predicted_labels);
disp('Confusion Matrix:');
disp(conf_matrix);
