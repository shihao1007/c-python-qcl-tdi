%% Read captured images and average them
% Editor: Shihao Ran
% STIM Lab
% Last updated: 10/27/2016

%% read images then averaging and cut into smaller part if necessary

grabs = 350;                                                                    % total grabs in different position of the sample plane                                                                % images acquired during the same grab
                                                                                % imaged sample length = grabs * footstep, footstep is set to 5 or 10 micron
frames = 1600;                                                                    % frames captured at the same position used for averaging

num_wn = 1;                                                                   % number of imaged wavenumbers

cut_X_min = 0;                                                                  % set minimal x coordinate for ROI
cut_X_max = 128;                                                                % set maximal x coordinate for ROI
cut_Y_min = 0;                                                                 % set minimal y coordinate for ROI
cut_Y_max = 128;                                                                % set minimal y coordinate for ROI

X = cut_X_max - cut_X_min;                                                  % cut image according to ROI
Y = cut_Y_max - cut_Y_min;

% define the curtain size for TDI
% which is the integration interval
c = 1;                                                                          % depend on the size of FOV and footstep, c is usually set to 1-3

for i = 1 : num_wn                                                              % for each wavenumber that has been imaged
    
    wn = 1578+(i)*2;                                                            % convert to wavenumber 
    
    backgroundDIR = sprintf('D:\\ir images\\IR Images\\ir-spreadbeam-tdi\\background\\%d', wn);

    % Averaging background

    fname = sprintf('%s\\sbf161_img_0_1600.bin',backgroundDIR);
    background_ID = fopen(fname,'rb');
    IR_background = fread(background_ID, [128,128],'uint32');                                      % read in image to a vector
    fclose(background_ID);
       
    IR_background_average(:,:,i) = IR_background / 1600;                   % average those frames out then save with the index of wavenumber
    IR_background_cuted(:,:,i) = IR_background_average(:,cut_X_min + 1:cut_X_max,i);    % cut the image according to ROI
    
    T = grabs;

    I_background(:,:,i) = zeros(Y, (T - 1) * c + X);                                              % initialize a big array of TDI

    for t = 1:T
        ti = (t - 1) * c + 1;
        I_background(:, ti:ti + X - 1,i) = I_background(:, ti:ti+X-1) + fliplr(IR_background_cuted(:,:,i));  % for each grab, add them up with interval of c
    end
    
    IR_background_line(:,1,i) = I_background(:,round(size(I_background,2)/2));
        
    dataDIR = sprintf('D:\\ir images\\IR Images\\ir-spreadbeam-tdi\\target\\%d',wn);
    
    for j= 0 : grabs - 1                                                        % during each grab, at the same position                
        
            fname = sprintf('%s\\sbf161_img_%d_1600.bin',dataDIR,j);          % geting image file name
            raw_ID = fopen(fname,'rb');
            I_raw = fread(raw_ID,[128,128],'uint32');
            fclose(raw_ID);
            
            IR(:,:,j+1) = I_raw;                                              % read in image
                                                                            % finish reading in frames of the same grab

            IR_frame_average(:,:,j+1) = IR(:,:,j+1)/frames;                 % average those frames into one image representing the grab
            IR_frame_cuted(:,:,j+1) = IR_frame_average(:,cut_X_min+1:cut_X_max,j+1);             % cut image into small part due to limited laser beam size      

    end                                                                           

    I_target(:,:) = zeros(Y, (T - 1) * c + X);                                              % initialize a big array of TDI

    for t = 1:T
        ti = (t - 1) * c + 1;
        I_target(:, ti:ti + X - 1) = I_target(:, ti:ti+X-1) + fliplr(IR_frame_cuted(:,:,t));  % for each grab, add them up with interval of c
    end
    

    % do ratio to remove background
    A(:,:,i) = -log10(I_target ./ repmat(IR_background_line(:,1,i), [1, size(I_target,2)]));
    A_cuted(:,:,i) = A (:,24:130,i);
end

% write images out to a binary file

% absorbance image which is after ratio
fid = fopen('A','wb');
fwrite(fid, A_cuted, 'float32');
fclose(fid);