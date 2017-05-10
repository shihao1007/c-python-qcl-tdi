function M = tdi (A, grabs, X, Y, c)
    T = grabs;

    M(:,:) = zeros(Y, (T - 1) * c + X);                                              % initialize a big array of TDI

    for t = 1:T
        ti = (t - 1) * c + 1;
        M(:, ti:ti + X - 1) = M(:, ti:ti+X-1) + (A(:,:,t));  % for each grab, add them up with interval of c
    end