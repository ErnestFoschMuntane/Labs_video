%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%              LABORATORY #2 
%%%              VIDEO PROCESSING 2025-2026
%%%              VIDEO SEGMENTATION - VIDEO SCENE SEGMENTATION BY 
%%%                                   SUBSPACE CLUSTERING 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You should tune the variable "corruption" and "filter" to add or not
% noisy observations, and to consider a particular order in your temporal
% filtering. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc


addpath common
addpath osc
addpath libs\ncut
addpath data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MISSING CODE HERE, WHEN A VIDEO IS CONSIDERED AS INPUT. COMMENT THE NEXT
% LINES TO PRODUCE SYNTHETIC DATA IN THIS CASE

numFrames = 10;
frames = zeros(32,32,numFrames);
for i=1:numFrames
    frames(:,:,i) = imread(sprintf('n%d.bmp',i));
    % imshow(frames(:,:,i));
    % pause;
end

dim_data = size(frames,1)*size(frames,2); %number of pixels.
n_space = 2; % Number of clusters (1 for number 7 and 1 for number 1).
cluster_size = 5; % five frames for each cluster.
dim_space = 4;

% Reshape X to a matrix with size num_pixels x frames:
X = reshape(frames,size(frames,1)*size(frames,2), 10);

% Solving optimization problem
lambda_1 = 0.099; % Weight coefficient to impose sparsity in affinities
lambda_2 = 0.001; % Weight coefficient to enforce temporal consistency
filter = 4; % <-------   Impose order for temporal filtering [1, 2, 4]
Z = osc_relaxed(X, lambda_1, lambda_2, filter);

% Observing the affinity matrix
figure(1)
imagesc(abs(Z) + abs(Z'))
xlabel('Frame number');
ylabel('Frame number');

% Split the video in clusters from affinity matrix Z
clusters = ncutW(abs(Z) + abs(Z'), n_space);
final_clusters = condense_clusters(clusters, 1); % cluster (1 or 2) assigned to each frame.

ground_clusters = [ones(1,5), 2*ones(1,5)];
v = 1:n_space; % possible cluster labels.
P = perms(v); % generates all possible label permutations in order to align the labels to the ground truth.

AA = kron(P, ones(cluster_size,1)); % each column of AA is a possible ground truth.

int = 0; %max number of matching labels found so far.
for i=1:size(AA,2) % loops over each possible gt.
    [a,b] = find(final_clusters == AA(:,i)); % returns indices where labels match. (row, col)
    if (size(a,1) > int) % if a better match is found --> update. (size(a,1) = num of matches)
        nlabels = size(a,1);
        int = nlabels;
        ground_clusters = AA(:,i); % solution --> all rows from col i
    end
end

disp('The error in % is')
error=(1-(nlabels/(n_space*cluster_size)))*100

% Observing the results
figure(2) 
subplot(121)
imagesc(final_clusters);
ylabel('Label for every frame');
title('Your estimation')
subplot(122)
imagesc(ground_clusters);
ylabel('Label for every frame');
title('Ground truth')