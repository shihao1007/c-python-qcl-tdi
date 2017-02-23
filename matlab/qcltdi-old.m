%% Read captured images and average them
% Editor: Shihao Ran
% STIM Lab
% Last updated: 10/27/2016

%% read images then averaging and cut into smaller part if necessary

grabs = 200;                                                                 % total grabs in different position of the sample plane                                                                % images acquired during the same grab
frames = 20;
cut_X_min = 0;
cut_X_max = 128;
cut_Y_min = 0;
cut_Y_max = 128;
%define the curtain size
c = 2;


for i = 1 : 81
    k = 500+(i)*2;
    dataDIR = sprintf('D:\\ir images\\IR Images\\ir-target-1500-1700-2cm-1\\1%d', k);
    
    for j= 0 : grabs - 1   % during each grab                
        for f = 1 : frames
            fname = sprintf('%s\\sbf161_img_%d_%d.pgm',dataDIR, j, f);                        % geting image file name
            IR(:,:,f,j+1) = imread(fname);                                        % read in that image
        end                                                             % finish reading in frames of the same grab

        for f = 1 : frames
            IR_frame_average(:,:,j+1) = double(sum (IR(:,:,:,j+1), 3));          % average those frames into one image representing the grab
            IR_frame_cuted(:,:,j+1) = IR_frame_average(cut_Y_min:cut_Y_max,:,j+1);             % cut image into small part due to limited laser beam size                                                         % finish averaging single frame
        end
    end                                                                           % finish post prosscing all grabs


    T = grabs-1;

%cutted image size*
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
    
    I_crop = I(Y+20:size(I,1)-Y-20,:);

    background_i = repmat(I_crop(50,:), [size(I_crop,1), 1]);
    I_ratio(:,:) = - log( I_crop(:,:) ./ background_i);
    
    I_background(:,:,i+1) = background_i;
    I_before_ratio(:,:,i+1) = I_crop(:,:);
    I_spectral(:,:,i+1) = I_ratio(:,:);
    

    
end

I = rot90(I_before_ratio);
fid = fopen('I','w');
fwrite(fid, I, 'float32');
fclose(fid);

A = rot90(I_spectral);
fid = fopen('A','w');
fwrite(fid, A, 'float32');
fclose(fid);

I0 = rot90(I_background);
fid = fopen('I0','w');
fwrite(fid, I0, 'float32');
fclose(fid);