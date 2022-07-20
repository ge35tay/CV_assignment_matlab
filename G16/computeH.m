function [H, t] = computeH(s, d)
    % This function computes the homography which relate two plane. It's
    % sometimes numerical unstable, therefore we use a function of matlab,
    % namely the fitgeotrans() instead.
    % 
    % Required variables:
    % s       source points [2xN matrix, N >= 4] 
    % d       destination points [2xN matrix, N>= 4]
    %
    % Output variables:
    % H       homography matrix, whose last entry is 1 [3x3 matrix]
          
    %% Check if input variables are valid
    s = [s(:,1:4)];
    d = [d(:,1:4)];
    if size(s, 1) ~= 2 || size(d, 1) ~= 2
        error('Points matrices must have 2 rows');
    end
    N = size(s, 2);
    if N < 4
        error('Computation of homography needs at least 4 correspondences');
    end

    %% Compute the homography using SVD
    x = d(1, :)';
    y = d(2, :)';
    X = s(1, :)';
    Y = s(2, :)';
    
    % construct the a matrix A such that
    % A_i = [x_i y_i 0 0   0   0 -x_i*X_i -y_i*X_i - X_i;
    %        0   0   0 x_i y_i 0 -x_i*Y_i -y_i*Y_i - Y_i]
    submatrixXY = -[X Y ones(N, 1)];
    submatrixZeros = zeros(N, 3);
    A_x = [submatrixXY, submatrixZeros, x.*X, x.*Y, x];
    A_y = [submatrixZeros, submatrixXY, y.*X, y.*Y, y];
    A = [A_x; A_y];

    if N == 4
        [~, ~, V] = svd(A);
    else
        [~, ~, V] = svd(A, 'econ');
    end
    H = (reshape(V(:, end), 3, 3));

    t = maketform('projective', H);
end
