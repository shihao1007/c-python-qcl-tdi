 function S = load_tdi_sequence(mask)
    F = dir(mask);

    S = zeros(128, 128, length(F));             %allocate space for the TDI sequence
    for fi = 1:length(F)
        fname = [F(fi).folder '/' F(fi).name];
        load(fname);
        S(:, :, fi) = s;
    end
 end