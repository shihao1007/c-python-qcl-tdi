%% Read captured images and average them
% Editor: Shihao Ran
% STIM Lab
% Last updated: 10/27/2016

%% read images then averaging and cut into smaller part if necessary

grabs = 1;                                                                    % total grabs in different position of the sample plane                                                                % images acquired during the same grab
                                                                                % imaged sample length = grabs * footstep, footstep is set to 5 or 10 micron
frames = 1600;                                                                    % frames captured at the same position used for averaging

num_wn = 30;                                                                   % number of imaged wavenumbers

cut_X_min = 0;                                                                  % set minimal x coordinate for ROI
cut_X_max = 128;                                                                % set maximal x coordinate for ROI
cut_Y_min = 30;                                                                 % set minimal y coordinate for ROI
cut_Y_max = 80;                                                                % set minimal y coordinate for ROI

% define the curtain size for TDI
% which is the integration interval
c = 2;                                                                          % depend on the size of FOV and footstep, c is usually set to 1-3


for i = 1 : num_wn                                                              % for each wavenumber that has been imaged
    
    wn = 1570+(i)*2;                                                            % convert to wavenumber 
    
    backgroundDIR = sprintf('D:\\ir images\\IR Images\\ir-speeded-2bar\\background\\%d', wn);

    % Averaging background

    fname = sprintf('%s\\sbf161_img_0_1600.txt',backgroundDIR);
    background_ID = fopen(fname);
    I_background = fread(background_ID,'uint32');                                      % read in image to a vector
    fclose(background_ID);
    I_background = reshape(I_background, [128,128]);                    % reshape it to the size of image, 128*128
    I_background = I_background.';                                      % transpose to the correct orentation
       
    IR_background_average(:,:,i) = double( I_background /frames);                   % average those frames out then save with the index of wavenumber
    IR_background_cuted(:,:,i) = IR_background_average(cut_Y_min:cut_Y_max,:,i);    % cut the image according to ROI
    IR_background_line(1,:,i) = double(sum (IR_background_cuted(:,:,i), 1));
        
    dataDIR = sprintf('D:\\ir images\\IR Images\\ir-speeded-2bar\\target\\%d',wn);
    
    for j= 0 : grabs - 1                                                        % during each grab, at the same position                
        
            fname = sprintf('%s\\sbf161_img_0_1600.txt',dataDIR);          % geting image file name
            raw_ID = fopen(fname);
            I_raw = fread(raw_ID,'uint32');
            fclose(raw_ID)
            I_raw = reshape(I_raw, [128,128]);
            I_raw = I_raw.';
            
            IR(:,:,j+1) = I_raw;                                              % read in image
                                                                            % finish reading in frames of the same grab

            IR_frame_average(:,:,j+1) = double(IR(:,:,j+1)/frames);                 % average those frames into one image representing the grab
            IR_frame_cuted(:,:,i) = IR_frame_average(cut_Y_min:cut_Y_max,:,j+1);             % cut image into small part due to limited laser beam size                                                         % finish averaging single frame
            IR_frame_line(1,:,i) = double(sum (IR_frame_cuted(:,:,i), 1));

    end                                                                           

% % TDI
%     T = grabs;
% 
%     X = cut_X_max - cut_X_min;                                                  % cut image according to ROI
%     Y = cut_Y_max - cut_Y_min + 1;
% 
%     I = zeros((T - 1) * c + Y, X);                                              % initialize a big array of TDI
% 
%     for t = 1:T
%         ti = (t - 1) * c + 1;
%         I(ti:ti + Y - 1, :) = I(ti:ti+Y-1, :) + flipud(double(IR_frame_ratio(:,:,t)));  % for each grab, add them up with interval of c
%     end

    % do ratio to remove background
    IR_frame_ratio_line(:,:,i) = - log( IR_frame_line(1,:,i) ./ IR_background_line(1,:,i));
    IR_frame_ratio(:,:,i) = - log( IR_frame_cuted(:,:,i) ./ IR_background_cuted(:,:,i));  

%     IR_absorbance(:,:,i) = I(80:300,:);                                                   % save to a array with index of wavenumber
    
end

% write images out to a binary file

%images before retio
fid = fopen('I_line','w');
fwrite(fid, IR_frame_line, 'float32');
fclose(fid);

% absorbance image which is after ratio
fid = fopen('A_line','w');
fwrite(fid, IR_frame_ratio_line, 'float32');
fclose(fid);

% background
fid = fopen('I0_line','w');
fwrite(fid, IR_background_line, 'float32');
fclose(fid);

%images before retio
fid = fopen('I','w');
fwrite(fid, IR_frame_cuted, 'float32');
fclose(fid);

% absorbance image which is after ratio
fid = fopen('A','w');
fwrite(fid, IR_frame_ratio, 'float32');
fclose(fid);

% background
fid = fopen('I0','w');
fwrite(fid, IR_background_cuted, 'float32');
fclose(fid);