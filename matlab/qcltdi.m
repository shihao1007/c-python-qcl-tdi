%%
% This function is written by Shihao Ran and David Mayerich
% Used for data process acquired by QCL-based DFIR system
% Parameters:
% -- input_path : foreground image folder path
% -- outfile    : ENVI file name
% -- dy         : Time delay integration interval size
% -- bc         : boxcar spectrum smoothing gate size
% -- background : background image folder path
% Copyright STIM Lab
% 05/10/2017

%%
function qcltdi(input_path, outfile, dy, bc, background)
    
    DNoiseDir = 'D:\ir images\IR Images\ir-short-path\1st-test\noise\1502\sbf161_img_000_1600.mat';  %local saved detector noise image
    load(DNoiseDir);
    DNoise = s;                        %load noise image

    BACKGROUND = false;
    if(nargin > 3)
        BACKGROUND = true;              %flag for calculating a background ratio
    end
    
    F = dir(input_path);            %get a list of files in the input location
    D = F([F(:).isdir]);
    D = D(3:end);
    fid = fopen(outfile, 'wb');     %open an output file for binary writing

    
    for j = 1:length(D)                         %for all the bands
        if(D(j).isdir)
            filemask = sprintf('target/%d/*.mat',1500 + 2*j);
            S = load_tdi_sequence(filemask);

            X = size(S, 1);
            Y = size(S, 2);

            N = size(S, 3);                     %calculate the number of images
            fX = X;                             %calculate the final image size
            fY = round(dy * (N-1)) + size(S, 2);
            I = zeros(fX, fY);                  %allocate space for the final image

            for n = 1:N                         %for each image frame
                i = round((n - 1) * dy + 1);              %calculate the start index for this frame
                I(:, i:i + Y - 1) = I(:, i:i + Y - 1) + fliplr(S(:, :, n)/800 - DNoise/4800);
            end

            if (BACKGROUND == true)
                F_b = dir(background);            %get a list of files in the input location
                D_b = F_b([F_b(:).isdir]);
                D_b = D_b(3:end);
                I0_0 = zeros(fX, fY);                  %allocate space for the final image
                filemask_b = sprintf('background/%d/*.mat',1500 + 2*j);
                B = load_tdi_sequence(filemask_b);
                for n = 1:N                         %for each image frame
                i = round((n - 1) * dy + 1);              %calculate the start index for this frame
                I0_0(:, i:i + Y - 1) = I0_0(:, i:i + Y - 1) + fliplr(B(:, :)/800 - DNoise/4800);
                end

                I0_l(:,1) = I0_0(:,round(size(I0_0,2)/2));      

                A_0(:,:) = -log10(I ./ repmat(I0_l(:,1), [1, size(I,2)]));  %use line as background
                %A_0(:,:) = -log10(I ./ I0_0);                               %use whole image as background
                A(:,:) = A_0(:,round(0.2*fY):round(0.8*fY));
                %I0(:,:) = I0_0(:,round(0.02*fY):round(0.98*fY));
            else
                A = I;
            end
            Absor(:,:,j) = A;
        end
    end

    %%Smooth the spectrum
    for x = 1 : size(Absor,1)
        for y = 1 : size(Absor,2)
            for k = 1 : size(Absor,3)
                for n = 1: bc
                    if (k-n < 1)
                        k_b = 1;
                    else k_b = k - n;
                    end
                    if (k+n >size(Absor,3))
                        k_f = size(Absor,3);
                    else k_f = k + n;
                    end
                    A_c(n) = Absor(x,y,k) + Absor(x,y,k_b) + Absor(x,y,k_f);
                end
                A_s = sum(A_c) - Absor(x,y,k) * (bc - 1);
                A_a = A_s / (2*bc + 1);
                Absor(x,y,k) = A_a;
            end
        end
    end
    
    fwrite(fid, Absor, 'float32');
    fclose(fid);
end