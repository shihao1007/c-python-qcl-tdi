function qcltdi(input_path, outfile, dy, background)
    
    DNoiseDir = 'D:\ir images\IR Images\ir-short-path\1st-test\noise\1502\sbf161_img_000_1600.mat';
    load(DNoiseDir);
    DNoise = s;

    BACKGROUND = false;
    if(nargin > 3)
        BACKGROUND = true;              %flag for calculating a background ratio
    end
    
    F = dir(input_path);            %get a list of files in the input location
    D = F([F(:).isdir]);
    D = D(3:end);
    fid = fopen(outfile, 'wb');     %open an output file for binary writing

    
    for j = 1:length(D)
        if(D(j).isdir)
            filemask = sprintf('target/%d/*.mat',910 + 2*j);
            S = load_tdi_sequence(filemask);

            X = size(S, 1);
            Y = size(S, 2);

            N = size(S, 3);                     %calculate the number of images
            fX = X;                             %calculate the final image size
            fY = round(dy * (N-1)) + size(S, 2);
            I = S;                  %allocate space for the final image

%             for n = 1:N                         %for each image frame
%                 i = round((n - 1) * dy + 1);              %calculate the start index for this frame
%                 I(:, i:i + Y - 1) = I(:, i:i + Y - 1) + fliplr(S(:, :, n)/800 - DNoise/4800);
%             end

            if (BACKGROUND == true)
                F_b = dir(background);            %get a list of files in the input location
                D_b = F_b([F_b(:).isdir]);
                D_b = D_b(3:end);
                I0_0 = zeros(fX, fY);                  %allocate space for the final image
                filemask_b = sprintf('background/%d/*.mat',910 + 2*j);
                B = load_tdi_sequence(filemask_b);
%                 for n = 1:N                         %for each image frame
%                 i = round((n - 1) * dy + 1);              %calculate the start index for this frame
%                 I0_0(:, i:i + Y - 1) = I0_0(:, i:i + Y - 1) + fliplr(B(:, :)/800 - DNoise/4800);
%                 end

%                 I0_l(:,1) = I0_0(:,round(size(I0_0,2)/2));      

                A_0(:,:) = -log10(I ./ B);  %use line as background
                %A_0(:,:) = -log10(I ./ I0_0);                               %use whole image as background
%                 A(:,:) = A_0(:,round(0.02*fY):round(0.98*fY));
%                 I0(:,:) = I0_0(:,round(0.02*fY):round(0.98*fY));
            else
                A = I;
            end
            fwrite(fid, A_0, 'float32');
        end
        
    end
    fclose(fid);

end
