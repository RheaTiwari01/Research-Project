image_folder = "C:\Users\RHEA TIWARI\Desktop\researchproject\archive (7)";
image_files = imageDatastore(image_folder, "IncludeSubfolders", true, "LabelSource", "foldernames");


% Count the number of files associated with each label
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
numClasses = numel(categories(train_set.Labels));
layers=[
    imageInputLayer([227 227 3])
    convolution2dLayer([11 11], 96, 'Padding', 4, 'NumChannels', 3)
    batchNormalizationLayer
    reluLayer
   maxPooling2dLayer([3 3], 'Stride', [2 2], 'Padding', [1 1 1 1])

    convolution2dLayer([3 3],64,"stride",[3,3],"Padding",2)
    batchNormalizationLayer();
    reluLayer
    convolution2dLayer([4 4],64,'Stride',[1 1],'Padding',1)
    
    batchNormalizationLayer
    maxPooling2dLayer([3 3],'Stride',[2 2],'Padding',0)
    reluLayer
    convolution2dLayer([3 3],128,'Stride',[2 2],'Name','conv2')
    batchNormalizationLayer
   % additionLayer(2)
    reluLayer
    convolution2dLayer([4 4],128,'Stride',[2 2])
    batchNormalizationLayer
    reluLayer
    convolution2dLayer([3 3],256,'Stride',[2 2],'Padding',1,'Name','conv3')
    batchNormalizationLayer
    %additionLayer(2)
    reluLayer

    averagePooling2dLayer([2 2], 'Name', 'average_pool','Padding',[0 0 0 0]);
    fullyConnectedLayer(numClasses)
    reluLayer
    dropoutLayer(0.35)
    fullyConnectedLayer(numClasses)
    softmaxLayer()
    classificationLayer()
    ];
disp(layers)
% Adjust the pooling dimensions to ensure compatibility with input size

%connectLayers(lgraph, 'conv3', 'addition_1/in1');
%connectLayers(lgraph, 'conv2', 'addition_1/in2');
%connectLayers(lgraph, 'conv3', 'addition_2/in1');
%connectLayers(lgraph, 'conv3', 'addition_2/in2');
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

% Connect the layers properly
lgraph = layerGraph(layers);


% Define options including cross-validation data
options = trainingOptions('sgdm', ...
    'MaxEpochs', 8, ...
    'MiniBatchSize',32 , ...
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

