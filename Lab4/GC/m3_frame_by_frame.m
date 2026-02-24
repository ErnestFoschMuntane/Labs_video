clear all
close all
clc

addpath data

numFrames = 10;
frames = zeros(480, 854, 3, numFrames); % array to store the frames
gt = zeros(480, 854, numFrames, 'logical'); % array to store the ground truth
error = zeros(1, numFrames); % array to store the error of the segmentation

%figure(1);
% Get all the frames:
for i=1:numFrames
    % frames(:,:,:,i) = im2double(imread(sprintf('camel_000%02d.jpg',i-1)));
    % gt(:,:,i) = imread(sprintf('camel_000%02d.png',i-1));
    frames(:,:,:,i) = im2double(imread(sprintf('flamingo_000%02d.jpg',i-1)));
    gt(:,:,i) = imread(sprintf('flamingo_000%02d.png',i-1));
    %imshow(frames(:,:,:,i));
    %pause;
end

% Input Image is the 1st frame:
input_image = frames(:,:,:,1);

% Computing superpixels for graph (nodes and edges) initialization instead
% of pixel based approach.
L = superpixels(input_image,500); % 1st frame with 500 superpixels
figure(2);
BW = boundarymask(L); imshow(imoverlay(input_image,BW,'cyan'),'InitialMagnification',67);

% Fixing samples within the foreground region by means of rectangular
% box/es. Creating the corresponding mask
disp('Selecting foreground area...');
[a]=ginput(2);
f1 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','g');
[a]=ginput(2);
f2 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','g');
[a]=ginput(2);
f3 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','g');
% If several, mix them
foreground = createMask(f1,input_image) + createMask(f2,input_image) + createMask(f3,input_image);

% Fixing samples within the background region by means of rectangular
% box/es. Creating the corresponding mask
disp('Selecting background area...');
[a]=ginput(2);
b1 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','r');
[a]=ginput(2);
b2 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','r');
[a]=ginput(2);
b3 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','r');
% If several, mix them
background = createMask(b1,input_image) + createMask(b2,input_image) + createMask(b3,input_image);

disp('Observing input user interaction...');

for i=1:numFrames
    % Applying lazysnapping algorithm, a graph cut based algorithm
    L = superpixels(frames(:,:,:,i),500);
    BW = lazysnapping(frames(:,:,:,i),L,foreground,background);
    % Observing the foreground region
    figure(3);
    imshow(labeloverlay(frames(:,:,:,i),BW,'Colormap',[0 1 0]))
    disp('Press any key...');
    pause;
    % Extracting foreground region
    maskedImage = frames(:,:,:,i);
    maskedImage(repmat(~BW,[1 1 3])) = 0;
    figure(4);
    imshow(maskedImage)
    disp('Press any key...');
    pause;
    
    intersection = sum(gt(:,:,i) & BW(:,:), 'all'); % which pixels hava a correct label
    total_fg = sum(gt(:,:,i), 'all'); % how many pixels belong to the segmentation 
    error(i) = 1-(intersection / total_fg); % 1-accuracy
end

mean_error = sum(error)/numFrames;

fprintf('The mean error is %.4f\n', mean_error);