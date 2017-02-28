function qcltdi(input_path, outfile, dy, background)
    
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
            filemask = sprintf('target/%d/*.mat',1490 + 2*j);
            S = load_tdi_sequence(filemask);

            X = size(S, 1);
            Y = size(S, 2);

            N = size(S, 3);                     %calculate the number of images
            fX = X;                             %calculate the final image size
            fY = round(dy * (N-1)) + size(S, 2);
            I = zeros(fX, fY);                  %allocate space for the final image

            for n = 1:N                         %for each image frame
                i = round((n - 1) * dy + 1);              %calculate the start index for this frame
                I(:, i:i + Y - 1) = I(:, i:i + Y - 1) + fliplr(S(:, :, n));
            end

            if (BACKGROUND == true)
                F_b = dir(background);            %get a list of files in the input location
                D_b = F_b([F_b(:).isdir]);
                D_b = D_b(3:end);
                I0 = zeros(fX, fY);                  %allocate space for the final image
                filemask_b = sprintf('background/%d/*.mat',1490 + 2*j);
                B = load_tdi_sequence(filemask_b);
                for n = 1:N                         %for each image frame
                i = round((n - 1) * dy + 1);              %calculate the start index for this frame
                I0(:, i:i + Y - 1) = I0(:, i:i + Y - 1) + fliplr(B(:, :));
                end

                I0_l(:,1) = I0(:,round(size(I0,2)/2));

                A_0(:,:) = -log10(I ./ repmat(I0_l(:,1), [1, size(I,2)]));
                A(:,:) = A_0(:,round(0.2*fY):round(0.8*fY));

            else
                A = I;
            end
            fwrite(fid, A, 'float32');
        end
        
    end
    fclose(fid);

end
