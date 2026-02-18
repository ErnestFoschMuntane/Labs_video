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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Random number generation
rng(1);

%--------------------------------------------------------------------------
% EXPERIMENT GENERATION
% We consider 50 frames (n_space=5*cluster_size=10), where every cluster 
% is a piece of 10 consecutive frames. 
dim_data = 321; %number of features, pixels, etc.
n_space = 5;
cluster_size = 10;
dim_space = 4;

% Generating input data
A = gen_depmultivar_data(dim_data, dim_space, cluster_size, n_space, 0.1, 0.001);
A = normalize(A);
noise=max(max(abs(A-mean(reshape(A,dim_data*n_space*cluster_size,1)))));


% Potentially, including noisy observations
corruption = 0.0; % <------  Consider values in the range [0, 0.18]
N = randn(size(A)) * corruption * noise;
X = A + N;
X = normalize(X);
%--------------------------------------------------------------------------

% Solving optimization problem
lambda_1 = 0.099; % Weight coefficient to impose sparsity in affinities
lambda_2 = 0.001; % Weight coefficient to enforce temporal consistency
filter = 1; % <-------   Impose order for temporal filtering [1, 2, 4]
Z = osc_relaxed(X, lambda_1, lambda_2, filter);

% Observing the affinity matrix
figure(1)
imagesc(abs(Z) + abs(Z'))
xlabel('Frame number');
ylabel('Frame number');

% Split the video in clusters from affinity matrix Z
clusters = ncutW(abs(Z) + abs(Z'), n_space);
final_clusters = condense_clusters(clusters, 1);


% Computing clustering error
v = 1:n_space;
P = perms(v)'; %5x120
AA=kron(P,ones(cluster_size,1));
int=0;
for i=1:size(AA,2)
    [a,b]=find(final_clusters==AA(:,i));
    if (size(a,1)>int)
        nlabels=size(a,1);
        int=nlabels;
        ground_clusters=AA(:,i);
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
