function I = qcltdi(filemask, dy)

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
