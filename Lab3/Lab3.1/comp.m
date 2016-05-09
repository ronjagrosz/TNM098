%% Take all features into account to compare images

load features.mat

M = size(features,2);

%index for image to compare
img = 8;
tot_dE = 0;

% For every feature M...
for i = 1:M
    
    %each feature in the feature vector has a specific dimension
    %every row correspond to a new image
    [rows,cols] = size(features{i});
    
    %Go through the images in feature i
    for j = 1:rows
        dE(j) = sqrt(sum((features{i}(j,:) - features{i}(img,:)).^ 2)); 
    end
    
    dE = dE/max(dE);
    tot_dE = tot_dE + dE;
    
    % Sort dE depcreasingly
    % I contains index of images, 
    % the first one is the image that is compared (the color dist will be highest when comparing with itself)
    % the second one has closest color distribution
    [dE_sorted,I] = sort(tot_dE)
end