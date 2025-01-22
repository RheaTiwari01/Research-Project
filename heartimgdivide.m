image = imread("C:\Users\RHEA TIWARI\Downloads\all frames\HCM frames\HCM48\012.jpg");
% Read the image


% Display the image
imshow(image);
title('Click on the image to select points');
hold on;

% Use ginput to select points
% The second argument specifmaakies the number of points you want to select
% Click on the image to select the points, press Enter when done
[x, y] = ginput(6);

% Display selected points
plot(x, y, 'r*', 'MarkerSize', 10);

[rows, cols, ~] = size(image);
disp(['Number of rows: ', num2str(rows)]);
disp(['Number of columns: ', num2str(cols)]);


 top = image(190:270, 280:530, :);
                middle_left = image(270:355, 220:380, :);
                middle_right = image(270:355, 380:540, :);
                bottom_left = image(355:455, 135:285, :);
                bottom_middle = image(355:455, 285:445, :);
                bottom_right = image(355:455, 445:605, :);
                last = image(435:550, 190:600, :);
        % Display top_left quadrant
% Define a 3x2 grid for subplots
% Display top_left quadrant
subplot(3, 3, 1);
imshow(top);
title('1 Quadrant');

% Display top_right quadrant
subplot(3, 3, 2);
imshow(middle_right);
title('3 Quadrant');

% Display bottom_left quadrant
subplot(3, 3, 3);
imshow(middle_left);
title('2 Quadrant');

% Display bottom_right quadrant
subplot(3, 3, 4);
imshow(bottom_right);
title('6 Quadrant');

% Display bottom_middle
subplot(3, 3, 5);
imshow(bottom_middle);
title('5 Quadrant');

% Display bottom_left again (or you may have meant a different quadrant)
subplot(3, 3, 6);
imshow(bottom_left);
title('4 Quadrant ');
subplot(3,3,7);

imshow(last);
title('7 Quadrant');



        

