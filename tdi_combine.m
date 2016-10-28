%% Read captured images and average them
% Editor: Shihao Ran
% STIM Lab
% Last updated: 10/27/2016

%% read images then averaging and cut into smaller part if necessary

grabs = 50;                                                                 % total grabs in different position of the sample plane
frames = 20;                                                                % images acquired during the same grab
cut_X_min = 1;
cut_X_max = 128;
cut_Y_min = 36;
cut_Y_max = 90;
%define the curtain size
c = 5;

for j= 0 : grabs - 1                                                        % during each grab 
   for i=1:frames                                                           % during each frame within that grab                
      fname = sprintf('sbf161_img_%d_%d.png', j, i);                        % geting image file name
      IR(:,:,i,j+1) = imread(fname);                                        % read in that image
   end                                                                      % finish reading in frames of the same grab
   
   for i = 1:frames                                                         % after reading frames of the same grab
       IR_frame_average(:,:,j+1) = double(sum (IR(:,:,:,j+1), 3));          % average those frames into one image representing the grab
       IR_frame_cuted(:,:,j+1) = IR_frame_average(cut_Y_min:cut_Y_max,:,j+1);             % cut image into small part due to limited laser beam size
   end                                                                      % finish averaging single frame
end                                                                         % finish post prosscing all grabs


%% scale image before saving
t = IR_frame_cuted;                                                         % make a temp for images
t = t./max(t(:));                                                           % scale images by deviding values by the maximum value

%% image save
for i=1:grabs                                                               % for each grab
        fname = sprintf('IR_target_averaged%02d.jpg',i);                    % make image file name
        imwrite(t(:,:,i),fname);                                            % write image out
end                                                                         % finish saving image

%%TDI 

%read in images
fmask = '*.jpg';

%load the image file list
flist = dir(fmask);

%assemble the list into a 3D array
T = length(flist);

%cutted image size
X = cut_X_max - cut_X_min + 1;
Y = cut_Y_max - cut_Y_min + 1;

%I = zeros(Y, X, T);
I = zeros((T - 1) * c + Y, X);

%TDI
for t = 1:T
    ti = (t - 1) * c + 1;
    img = imread(flist(t).name);
    I(ti:ti + Y - 1, :) = I(ti:ti+Y-1, :) + flipud(double(img));
end

% subplot(1,2,1)
% imagesc(IR_compare);                                                          % show the image, flip pixels if necessary
% axis image;                                                                         % show the image in the limited axis
% image_title = sprintf('Compare Image');                                              
% title(image_title);   

% subplot(1,2,2)
imagesc(I);
axis image;                                                                         % show the image in the limited axis
image_title = sprintf('TDI Image');                                              
title(image_title);

    