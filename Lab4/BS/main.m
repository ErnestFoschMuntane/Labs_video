%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%              LABORATORY #2 
%%%              VIDEO PROCESSING 2025-2026
%%%              VIDEO SEGMENTATION - BACKGROUND SUBTRACTION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath data


%--------------------------------------------------------------------------
%% Use this set of code lines for the thirh task in BS
% Loading input data
video=VideoReader('input-video.avi');

% Extracting frames (a set of them or, all of them). 10 frames in the example
frames=read(video,[11 20]);
numFrames = size(frames, 4);

mean_frame = zeros(size(frames, 1), size(frames, 2), size(frames, 3));
for f = 1:numFrames
    % imshow(frames(:,:,:,f));
    % disp('Observing frames. Press any key');  
    % pause;
    mean_frame = mean_frame + double(frames(:,:,:,f));
end
mean_frame = mean_frame / numFrames;
%---------------------------------------------------------------------------

% Obtaining the background image or the template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MISSING CODE HERE
% Loading frames
% image_template = double(imread('imagen0000.png')); % background only frame (for the 1st part)
% numFrames = 11;

% Option 1: We consider the first frame as the reference frame
% image_template = double(frames(:,:,:,1)); % wrong detection if reference frame is the 1st one

% Option 2: We consider the second frame as the reference frame
% image_template = double(frames(:,:,:,2)); % We get the second frame as the reference frame because there are less illumination changes

% Option 3: We consider the mean of the frames as the reference frame
% image_template = mean_frame;

% Fixing a threshold
th=10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Showing the image template (for the 1st part)
% figure(1)
% imshow(image_template/255) % If type = double then 0-1



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Video Segmentation
for i = 2:numFrames %%%%%%%%%%%%%%%%%%%%%% MISSING CODE HERE

  % Loading image
  % input_image=imread(sprintf('imagen00%02d.png',i-1));
  input_image=frames(:,:,:,i);
  input_imagew = double(input_image);

  image_template = double(frames(:,:,:,i-1));

  %Extracting foreground
  [foreground,cc(i),cr(i),radius,flag]=extract_object(input_imagew,image_template,th);
  if flag==0 
    continue %If no object detected continue
  end

  %Observing results
  figure(2)
  clf
  imshow(input_image)
  hold on
  for c = -0.97*radius: radius/20 : 0.97*radius
      r = sqrt(radius^2-c^2);
      plot(cc(i)+c,cr(i)+r,'g.')
      plot(cc(i)+c,cr(i)-r,'g.')
  end 
  hold off

  disp('Observing detection. Press any key');  
  pause;


end

% Recovering the full trajectory
cr=size(input_image,1)-cr;
figure(100)
plot(cc(2:end),cr(2:end),'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10)
axis([0 size(input_image,2) 0 size(input_image,1)])

