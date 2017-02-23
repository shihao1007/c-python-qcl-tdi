function M = qcl2mat(input_path)

    F = dir(input_path);            %get a list of files in the input location
    D = F([F(:).isdir]);
    D = D(3:end);

    M = uint32(zeros(128, 128, numel(D)));                  %create an output matrix
    for i = 1:length(D)                                     %for each directory
        if(D(i).isdir)                                      %if the file
            path = [input_path '\' D(i).name];
            F = dir(path);                                  %get all files in the dir
            fid_in = fopen([path '\' F(3).name], 'rb');       %open the input file
            M(:, :, i) = fread(fid_in, [128 128], '*uint32');         %read the input file
            fclose(fid_in);                                   %close the input file
        end
    end