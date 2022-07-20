function [img_affine, Ha] = affineRectification(img_before, pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8)
    %% This function is for the affine rectification of image 
    %% with 2 vanished point using parallel lines.
    %% pt1, pt2 belongs to parallel line1
    %% pt3, pt4 belongs to parallel line2   1 // 2
    %% pt5, pt6 belongs to parallel line3
    %% pt7, pt8 belongs to parallel line4   3 // 4

    % transform into homography
    pt1 = [pt1(1, 1), pt1(1, 2), 1]; 
    pt2 = [pt2(1, 1), pt2(1, 2), 1];
    pt3 = [pt3(1, 1), pt3(1, 2), 1];
    pt4 = [pt4(1, 1), pt4(1, 2), 1];
    pt5 = [pt5(1, 1), pt5(1, 2), 1];
    pt6 = [pt6(1, 1), pt6(1, 2), 1];
    pt7 = [pt7(1, 1), pt7(1, 2), 1];
    pt8 = [pt8(1, 1), pt8(1, 2), 1];

    % cross represent the joint of lines
    l1 = cross(pt1, pt2);
    l2 = cross(pt3, pt4);
    l3 = cross(pt5, pt6);
    l4 = cross(pt7, pt8);
    pinf1 = cross(l1, l2);
    pinf1 = pinf1 / pinf1(3);
    pinf2 = cross(l3, l4);
    pinf2 = pinf2 / pinf2(3);
    linf = cross(pinf1, pinf2);
    Ha = eye(3);
    Ha(end, :) = linf;

    tform = maketform('projective', Ha');
    [boxx, boxy]=tformfwd(tform, [1 1 size(img_before,2) ...
        size(img_before,2)], [1 size(img_before,1) 1 ...
        size(img_before,1)]);
    minx=min(boxx); maxx=max(boxx);
    miny=min(boxy); maxy=max(boxy);
    img_affine =imtransform(img_before,tform,'XData', ...
        [minx maxx], 'YData',[miny maxy],'Size', ...
        [size(img_before,1), ...
        round(size(img_before,1)*(maxx-minx)/(maxy-miny))]);
    
    figure;
    imshow(img_before);
    hold on;
    axis auto;
    
    line([pinf1(1) pinf2(1)], [pinf1(2) pinf2(2)], 'Marker', 'x', 'Color', 'k', 'LineWidth', 2)   

end