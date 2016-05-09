clear all
N = 12;
IMAGES = cell(1,N);

%Feature vector, stores the feature and NOT the result
features = cell(1,3);
% CIELab vector
% Intensity vector
% CIELab vector from weighted result

for i = 1:N
   IMAGES{i} = im2double(imread(sprintf('img/%d.jpg', i)));  
end

%% Calculate mean xyz-values and convert to lab
% Compare color distribution with euclidean distance 
% in the CIELab color space

lab = zeros(N,3);
%Take the mean CIEXYZ value and calculate CIELab from it
for i = 1:N
    rows = size(IMAGES{i}(:,:,1),1);
    cols = size(IMAGES{i}(:,:,1),2);
    
    %reshape RGB matrices to arrays to fit the rgb2xyz transform
    r = reshape(IMAGES{i}(:,:,1), rows*cols,1);
    g = reshape(IMAGES{i}(:,:,2), rows*cols,1);
    b = reshape(IMAGES{i}(:,:,3), rows*cols,1);
    
    tmp = rgb2xyz(r, g, b); 
    
    xyzm(1) = mean(tmp(:,1));
    xyzm(2) = mean(tmp(:,2));
    xyzm(3) = mean(tmp(:,3));
    
    %calc cielab from mean xyz
    lab(i,:) = xyz2lab(xyzm, 'd65_64', [ 0.9642, 1.0000, 0.8249])';
end

%Store the lab values in the feature vector
features{1} = lab;

%% mean intensity 

for i = 1:N
    int(i,:) = imhist(rgb2gray(IMAGES{i}))';
end

features{2} = int;

%% Color distribution around the central point
%Calculate distance from a pixel to the center of the image
%Normalize it to [0,1], where 0 -> center pixel and 1-> corner pixel

%construct cell dist with distance matrices for all images. A distance
%matrix contains the normalized distance from a pixel to the centrum pixel
dist = cell(1,N);

for i = 1:N
    center = [round(size(IMAGES{i},1)/2), round(size(IMAGES{i},2)/2)];
    max_dist = sqrt((1 - center(1))^2 + (1 - center(2))^2);
    for col = 1:size(IMAGES{i},2)
        for row = 1:size(IMAGES{i},1)
            dist{i}(row,col) = (sqrt((row - center(1))^2 + (col - center(2))^2))/max_dist;
        end
    end    
end


lab_w = zeros(N,3);

for i = 1:N
    
    rows = size(IMAGES{i},1);
    cols = size(IMAGES{i},2);
    xyz = zeros(rows, cols, 3);
    w_xyz = zeros(rows, cols, 3);
    r2 = reshape(IMAGES{i}(:,:,1), rows*cols,1);
    g2 = reshape(IMAGES{i}(:,:,2), rows*cols,1);
    b2 = reshape(IMAGES{i}(:,:,3), rows*cols,1);
    
    tmp = rgb2xyz(r2, g2, b2)'; 

    %reshape back to obtain image (instead of an array) in CIEXYZ space 
    xyz(:,:,1) = reshape(tmp(1,:),rows, cols);
    xyz(:,:,2) = reshape(tmp(2,:),rows, cols);
    xyz(:,:,3) = reshape(tmp(3,:),rows, cols);
   
    %weight images depending on the distance to the center
    w_xyz(:,:,1) = (1-dist{i}(:,:,1)).*xyz(:,:,1);
    w_xyz(:,:,2) = (1-dist{i}(:,:,1)).*xyz(:,:,2);
    w_xyz(:,:,3) = (1-dist{i}(:,:,1)).*xyz(:,:,3);
     
    xyzm_w(1) = mean(mean(w_xyz(:,:,1)));
    xyzm_w(2) = mean(mean(w_xyz(:,:,2)));
    xyzm_w(3) = mean(mean(w_xyz(:,:,3)));

    %calc cielab from mean xyz
    lab_w(i,:) = xyz2lab(xyzm_w, 'd65_64', [ 0.9642, 1.0000, 0.8249])';
end

%Store the lab values in the feature vector
features{3} = lab_w;

save('features.mat','features')
