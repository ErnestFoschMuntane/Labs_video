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
% video=VideoReader('input-video.avi');

% Extracting frames (a set of them or, all of them). 10 frames in the example
% frames=read(video,[11 20]);
%---------------------------------------------------------------------------

% Obtaining the background image or the template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MISSING CODE HERE
% Loading frames
image_template = double(imread('imagen0000.png')); % background only frame
% Fixing a threshold
th=10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Showing the image template
figure(1)
imshow(image_template/255) % If type = double then 0-1



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Video Segmentation
for i = 1:10 %%%%%%%%%%%%%%%%%%%%%% MISSING CODE HERE (11 frames but 1st one is the reference)
    
  % Loading image
  input_image=imread(sprintf('imagen00%02d.png',i));
  input_imagew = double(input_image);

  %Extracting foreground
  [foreground,cc(i),cr(i),radius,flag]=extract_object(input_imagew,image_template,th);
  if flag==0
    continue
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

