%% Read captured images and show one single wavelength picture
% Editor: Shihao Ran
% STIM Lab
% Last updated: 10/27/2016

%% read images then averaging and cut into smaller part if necessary

grabs = 500;                                                                 % total grabs in different position of the sample plane                                                                % images acquired during the same grab
cut_X_min = 0;
cut_X_max = 128;
cut_Y_min = 25;
cut_Y_max = 100;
%define the curtain size
c = 2;

for j= 0 : grabs - 1                                                        % during each grab                
      fname = sprintf('sbf161_img_%d_1.pgm', j);                        % geting image file name
      IR(:,:,j+1) = imread(fname);                                        % read in that image
                                                                         % finish reading in frames of the same grab
   
      IR_frame_cuted(:,:,j+1) = IR(cut_Y_min:cut_Y_max,:,j+1);             % cut image into small part due to limited laser beam size
                                                                         % finish averaging single frame
end                                                                         % finish post prosscing all grabs


% %% scale image before saving
% t = IR_frame_cuted;                                                         % make a temp for images
% t = t./max(t(:));                                                           % scale images by deviding values by the maximum value
% 
% %% image save
% for i=1:grabs                                                               % for each grab
%         fname = sprintf('IR_target_averaged%02d.jpg',i);                    % make image file name
%         imwrite(t(:,:,i),fname);                                            % write image out
% end                                                                         % finish saving image
% 
% %%TDI 
% 
% %read in images
% fmask = '*.jpg';
% 
% %load the image file list
% flist = dir(fmask);
% 
%assemble the list into a 3D array
T = grabs-1;

%cutted image size
X = cut_X_max - cut_X_min;
Y = cut_Y_max - cut_Y_min + 1;

%I = zeros(Y, X, T);
I = zeros((T - 1) * c + Y, X);

%TDI
for t = 1:T
    ti = (t - 1) * c + 1;
    
    I(ti:ti + Y - 1, :) = I(ti:ti+Y-1, :) + flipud(double(IR_frame_cuted(:,:,t)));            % if footstep is negative, flip images
%    I(ti:ti + Y - 1, :) = I(ti:ti+Y-1, :) + double(img);
end

background = repmat(I(172,:), [1072, 1]);
I(:,:) = - log( I(:,:) ./ background);

% subplot(1,2,1)
% imagesc(IR_compare);                                                          % show the image, flip pixels if necessary
% axis image;                                                                         % show the image in the limited axis
% image_title = sprintf('Compare Image');                                              
% title(image_title);   

% subplot(1,2,2)
figure;
imagesc(I);
axis image;                                                                         % show the image in the limited axis
axis off;
image_title = sprintf('wave number 1800', c);                                              
title(image_title,'Fontsize',14);
brewer = stimBrewerMap (128);
colormap(brewer);
print('Breast TMA row G 1800','-dpng','-r300');
    