function qcl2envi(input_path, outfile, background)
    BACKGROUND = false;
    if(nargin > 2)
        BACKGROUND = true;              %flag for calculating a background ratio
        B = double(qcl2mat(background));
    end

    F = dir(input_path);            %get a list of files in the input location
    D = F([F(:).isdir]);
    D = D(3:end);
    fid = fopen(outfile, 'wb');     %open an output file for binary writing
    for i = 1:length(D)
        if(D(i).isdir)              %if the file
            path = [input_path '\' D(i).name];
            F = dir(path);                                  %get all files in the dir
            fid_in = fopen([path '\' F(3).name], 'rb');       %open the input file
            I = fread(fid_in, [128 128], 'uint32');         %read the input file
            fclose(fid_in);
            I = I / 1600;
            if(BACKGROUND == true)
                A = -log10(I ./ B(:, :, i));
            else
                A = I;
            end
            fwrite(fid, A, 'float32');
        end
    end
    fclose(fid);
