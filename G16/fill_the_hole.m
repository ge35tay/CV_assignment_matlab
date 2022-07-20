% close all; % closes all figures
% clear;
% imgsrc = imread('oil-painting.png');
% 
% % im = im2single(imgsrc);
% % patch_size = 21;
% % figure(3), hold off, imagesc(im)
% % [x, y] = ginput;                                                              
% % target_mask = poly2mask(x, y, size(im, 1), size(im, 2)); 

function [im,out,rectout,mask] = fill_the_hole(imgsrc,imout,imrectout,immask)

    im = im2single(imgsrc);
    %[out,rectout,mask] = foregroundsele(imgsrc);
    out = imout;
    rectout = zeros(1,4);
    rectout = imrectout;
    mask = im2gray(immask);
    target_mask = logical(mask);
    patch_size = 21;
    hole_filling_crimnisi(im, target_mask, patch_size, 0.01, 'sjerome_new');
    im = imread('sjerome_new_hole.jpg');
    delete('sjerome_new_hole.jpg');
    delete('sjerome_new_hole_mask.png');
end

%% Sub function
function [ syn_im ] = hole_filling_crimnisi( I, target_mask, patch_size, tol, out_file_name )
    %figure(5), imshow(I);
    I = repmat((~target_mask), 1, 1, 3) .* I;
    %figure(11), imshow(I);
    
    out_file_name_mask = strcat('../G16/', out_file_name, '_hole_mask.png');
    imwrite(I, out_file_name_mask);
    syn_im = I;
    syn_im(syn_im == 0) = -1;
    hp_size = floor(patch_size / 2);
    confidence_map = double(~target_mask);
    i = 1;
    while any(target_mask(:) == 1)
        [t_candi_x, t_candi_y] = fill_front(target_mask);
        [template, y, x, confidence] = choose_template_criminisi(syn_im, t_candi_y, t_candi_x, target_mask, confidence_map, patch_size);
        ssd_map = ssd_patch(syn_im, template);
        ssd_map = set_forbid_region( ssd_map, target_mask, patch_size );
        patch = choose_sample(ssd_map, tol, syn_im, patch_size, 0.0001); 
        %figure(6), imshow(patch); 
        tplt_mask = template >= 0;
        %cut_mask = imdilate((~t_mask), ones(overlap * 2 + 1, overlap * 2 + 1));
        patch = tplt_mask .* template + ~tplt_mask .* patch;
        %figure(7), imshow(patch);
        syn_im(y - hp_size : y + hp_size, x - hp_size : x + hp_size, :) = patch;
        %figure(8), imshow(syn_im); 
        target_mask(y - hp_size : y + hp_size, x - hp_size : x + hp_size) = 0;
        %figure(9), imshow(target_mask);
        confidence_map(y - hp_size : y + hp_size, x - hp_size : x + hp_size) =...
            confidence_map(y - hp_size : y + hp_size, x - hp_size : x + hp_size)...
            + ((~tplt_mask(:, :, 1)) * confidence);
        i = i + 1;
    end
%figure(10), imshow(syn_im);
out_file_name = strcat('../G16/', out_file_name, '_hole.jpg');
imwrite(syn_im, out_file_name);
end

function [ ssd_map ] = ssd_patch_2d( I, T )
    mask = T >= 0; % -1 represents empty
    ssd_map = filter2(mask, I .* I, 'valid') + sum(sum(T .* T)) - 2 * filter2(mask .* T, I, 'valid');
end

function [ ssd_map ] = ssd_patch(I, T)
    ssd_map_r = ssd_patch_2d(I(:, :, 1), T(:, :, 1));
    ssd_map_g = ssd_patch_2d(I(:, :, 2), T(:, :, 2));
    ssd_map_b = ssd_patch_2d(I(:, :, 3), T(:, :, 3));
    ssd_map = ssd_map_r + ssd_map_g + ssd_map_b;
    ssd_map = normalize_2d_matrix(ssd_map);
end

function [ ssd_map ] = set_forbid_region( ssd_map, target_mask, patch_size )
    LARGE_CONST = 100;
    hp_size = floor(patch_size / 2);
    forbid_area = imdilate(target_mask, ones(patch_size, patch_size));
    ssd_map = ssd_map + (forbid_area(hp_size + 1 : size(target_mask, 1) - hp_size,...
          hp_size + 1 : size(target_mask, 2) - hp_size) * LARGE_CONST);
end

function [ value ] = point_fil( I, h, patch_size, y, x )
hp_size = floor(patch_size / 2);
value = sum(sum(I(y - hp_size : y + hp_size, x - hp_size : x + hp_size) .*  h));
end

function [ norm_m ] = normalize_2d_matrix( m )
    norm_m = (m - min(min(m))) / (max(max((m)) - min(min(m))));
end

function [ norm_vec ] = norm_v( target_mask, y, x )
    window = target_mask(y - 1 : y + 1, x - 1 : x + 1);
    center_value = window(2, 2);
    window(window == 0) = center_value;
    fx = window(2, 3) - window(2, 1);
    fy = window(3, 2) - window(1, 2);
    if fx == 0 && fy == 0
        norm_vec = [1; 1] / norm([1; 1]); 
    else
        norm_vec = [fx; fy] / norm([fx; fy]);
    end
end

function [ isoV ] = isophote(im, y, x)
    window = im(y - 1 : y + 1, x - 1 : x + 1);
    center_value = window(2, 2);
    window(window == -1) = center_value;
    fx = window(2, 3) - window(2, 1);
    fy = window(3, 2) - window(1, 2);
    if fx == 0 && fy == 0
       isoV = [0; 0]; 
    else
        I = sqrt(fx^2 + fy^2);
        theta = acot(fy / fx);
        [isoV_x, isoV_y] = pol2cart(theta, I); 
        isoV = [isoV_x; isoV_y];
    end
end

function [ err_patch ] = find_err_patch_2D( T, patch, overlap)
    diff = T(1 : overlap, :) - patch(1 : overlap, :);
    err_patch = diff .* diff;
end

function [ err_patch ] = find_err_patch( T, patch, overlap)
    err_patch_r = find_err_patch_2D( T(:, :, 1), patch(:, :, 1), overlap);
    err_patch_g = find_err_patch_2D( T(:, :, 2), patch(:, :, 2), overlap);
    err_patch_b = find_err_patch_2D( T(:, :, 3), patch(:, :, 3), overlap);
    err_patch = err_patch_r + err_patch_g + err_patch_b;
end

function [ mask ] = find_cut_mask(template, patch, overlap)
    t_size = size(template, 1);
    mask = zeros(t_size);
    mask_up = zeros(overlap, t_size);
    mask_left = zeros(t_size, overlap);
    is_up = nnz(template(1 : overlap, ceil(t_size / 2), 1) >= 0);
    is_left = nnz(template(ceil(t_size / 2), 1 : overlap, 1) >= 0);
    if is_up > 0
        err_patch = find_err_patch(template, patch, overlap);
        mask_up = cut_dp(err_patch);
    end
    if is_left > 0
        err_patch = find_err_patch(permute(template, [2 1 3]), permute(patch, [2 1 3]), overlap);
        mask_left = cut_dp(err_patch)';
    end
    mask(1 : overlap, :) = mask(1 : overlap, :) | mask_up;
    mask(:, 1 : overlap) = mask(:, 1 : overlap) | mask_left;
    mask;
end

function [ front_x, front_y ] = fill_front( target_mask )
    front = imdilate(target_mask, ones(3,3)) & ~target_mask;
    [front_y, front_x] = find(front);
end

function [ template, y, x, conf] = choose_template_criminisi(I, t_candi_y, t_candi_x, target_mask, confidence_map,  patch_size)
   
    data = zeros(size(t_candi_y));
    confidence = zeros(size(t_candi_y));
    hp_size = floor(patch_size / 2);
    
    for i = 1 : size(t_candi_y, 1)
        yy = t_candi_y(i); xx = t_candi_x(i);
        if xx == 121 && yy == 253
            xx;
        end
        norm_vec = norm_v(target_mask, yy, xx);
        iso_v = isophote(I(:, :, 1), yy, xx);
        confidence(i) = point_fil(confidence_map, ones(size(patch_size)), patch_size, yy, xx) / (patch_size^2);
        data(i) = abs(dot(iso_v, norm_vec(:, 1)));
    end
    priority = confidence + data;
    [priority, sorted_id] = sort(priority, 'descend');
    t_candi_y = t_candi_y(sorted_id);
    t_candi_x = t_candi_x(sorted_id);
    confidence = confidence(sorted_id);
    data = data(sorted_id);
    y = t_candi_y(1); x = t_candi_x(1);
    conf = confidence(1);
    template = I(y - hp_size : y + hp_size, x - hp_size : x + hp_size, : );
end

function [patch] = choose_sample( ssd_map, tol, I, patch_size, small_cost_value)
    min_c = min(min(ssd_map));
    min_c = max(min_c,small_cost_value);
    [y, x] = find(ssd_map <= min_c * (1 + tol));
    index = randi(size(y, 1));
    hp_size = floor(patch_size / 2);
    y = y(index) + hp_size; % transfrom to I coordinate
    x = x(index) + hp_size;
    patch = I((y - hp_size) : (y + hp_size), (x - hp_size) : (x + hp_size), :);
end
