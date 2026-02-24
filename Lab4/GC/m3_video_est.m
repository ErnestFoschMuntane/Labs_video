%% Video Segmentation with Temporal Consistency (Flamingo / Camel)
clear all; close all; clc;

addpath data;

numFrames = 10;
frames = zeros(480, 854, 3, numFrames);      % store video frames
gt = zeros(480, 854, numFrames, 'logical');  % ground truth
error = zeros(1, numFrames);                 % segmentation error per frame

%% Load frames and ground truth
for i = 1:numFrames
    % Uncomment one of the sequences:
    % frames(:,:,:,i) = im2double(imread(sprintf('camel_000%02d.jpg',i-1)));
    % gt(:,:,i) = imread(sprintf('camel_000%02d.png',i-1));
    frames(:,:,:,i) = im2double(imread(sprintf('flamingo_000%02d.jpg',i-1)));
    gt(:,:,i) = imread(sprintf('flamingo_000%02d.png',i-1));
end

input_image = frames(:,:,:,1);

%% Compute superpixels for the first frame
L = superpixels(input_image,500);
figure;
BW = boundarymask(L);
imshow(imoverlay(input_image,BW,'cyan'),'InitialMagnification',67);

%% User interaction for foreground

%% 1) With bounding boxes:
% disp('Select foreground area...');
% [a] = ginput(2);
% f = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','g');
% foreground = createMask(f,input_image);
% 
% %% User interaction for background
% disp('Select background area...');
% [a] = ginput(2);
% b1 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','r');
% [a] = ginput(2);
% b2 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','r');
% background = createMask(b1,input_image) + createMask(b2,input_image);

% BW_prev = lazysnapping(input_image,L,foreground,background);

%% 2) With imageSegmenter (for better foreground and background masking):

imageSegmenter(input_image)
pause;
BW_prev = BW1; % After saving the mask to the workspace.
background = ~BW_prev;

%% --- First frame segmentation ---

% Compute error for frame 1
intersection = sum(gt(:,:,1) & BW_prev,'all');
total_fg = sum(gt(:,:,1),'all');
error(1) = 1 - (intersection / total_fg);

% Optional visualization
figure;
imshow(labeloverlay(input_image,BW_prev,'Colormap',[0 1 0]));
title('Frame 1 Segmentation');
pause;

%% --- Loop over remaining frames ---
for i = 2:numFrames
    % Compute superpixels for current frame
    L = superpixels(frames(:,:,:,i),500);
    
    % Use previous mask as seeds for temporal consistency
    foreground = BW_prev;
    % background = ~BW_prev;
    
    % Apply lazy snapping
    BW = lazysnapping(frames(:,:,:,i), L, foreground, background);
    
    % Update previous mask
    BW_prev = BW;
    
    % Compute error
    intersection = sum(gt(:,:,i) & BW,'all');
    total_fg = sum(gt(:,:,i),'all');
    error(i) = 1 - (intersection / total_fg);
    
    % Optional visualization
    figure;
    imshow(labeloverlay(frames(:,:,:,i),BW,'Colormap',[0 1 0]));
    title(['Frame ', num2str(i), ' Segmentation']);
    pause;
end

%% Mean error over all frames
mean_error = mean(error);
fprintf('Mean segmentation error: %.4f\n', mean_error);