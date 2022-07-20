function [ Hm] = metricRectification(pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8, Ha)
    %% This function is for the metric rectification of image 
    %% with 2 vanished point using perpendicular lines.
    %% and the calculated Ha (affine rectification from last step)
    %% pt1, pt2 belongs to parallel line1
    %% pt3, pt4 belongs to parallel line2   1 perpendicular to 2
    %% pt5, pt6 belongs to parallel line3
    %% pt7, pt8 belongs to parallel line4   3 perpendicular to 4

    % homogeneous coordinate
    pt1 = [pt1(1, 1), pt1(1, 2), 1]; 
    pt2 = [pt2(1, 1), pt2(1, 2), 1];
    pt3 = [pt3(1, 1), pt3(1, 2), 1];
    pt4 = [pt4(1, 1), pt4(1, 2), 1];
    pt5 = [pt5(1, 1), pt5(1, 2), 1];
    pt6 = [pt6(1, 1), pt6(1, 2), 1];
    pt7 = [pt7(1, 1), pt7(1, 2), 1];
    pt8 = [pt8(1, 1), pt8(1, 2), 1];
    
    % calculate the joint in homogeneous coordinate using cross
    l1 = cross(pt1, pt2);
    l2 = cross(pt3, pt4);
    l3 = cross(pt5, pt6);
    l4 = cross(pt7, pt8);
    
    % to calculate the angle between lines for checking results
    l1_unrect = inv(Ha)' * l1';
    l2_unrect = inv(Ha)' * l2';
    l3_unrect = inv(Ha)' * l3';
    l4_unrect = inv(Ha)' * l4';
    
    % for checking results
    cosine1 = dot([l1_unrect(1) l1_unrect(2)],[l2_unrect(1) l2_unrect(2)])/(norm([l1_unrect(1) l1_unrect(2)]) * norm([l2_unrect(1) l2_unrect(2)]));
    cosine2 = dot([l3_unrect(1) l3_unrect(2)],[l4_unrect(1) l4_unrect(2)])/(norm([l3_unrect(1) l3_unrect(2)]) * norm([l4_unrect(1) l4_unrect(2)]));
    
    % normalized
    l1_normalized = [l1(1)/l1(3) l1(2)/l1(3)];
    l2_normalized = [l2(1)/l2(3) l2(2)/l2(3)];
    l3_normalized = [l3(1)/l3(3) l3(2)/l3(3)];
    l4_normalized = [l4(1)/l4(3) l4(2)/l4(3)];
    
    % calculate the homography matrix
    t1 = [l1_normalized(1)*l2_normalized(1),l1_normalized(1)*l2_normalized(2)+l1_normalized(2)*l2_normalized(1); l3_normalized(1)*l4_normalized(1),l3_normalized(1)*l4_normalized(2)+l3_normalized(2)*l4_normalized(1)];
    t2 = [-l1_normalized(2)*l2_normalized(2);-l3_normalized(2)*l4_normalized(2)];
    t3 = t1 \ t2;
    S = [t3(1) t3(2); t3(2) 1];

    % use SDV to approximate S with A
    [U,D,V] = svd(S);
    A = U * sqrt(D) * V';
    H = [A(1,1),A(1,2),0; A(2,1),A(2,2),0; 0,0,1];

    l1_rect = H' * l1';
    l2_rect = H' * l2';
    l3_rect = H' * l3';
    l4_rect = H' * l4';

    % for checking results
    cosine1_rectified = dot([l1_rect(1) l1_rect(2)],[l2_rect(1) l2_rect(2)])/(norm([l1_rect(1) l1_rect(2)]) * norm([l2_rect(1) l2_rect(2)]));
    cosine2_rectified = dot([l3_rect(1) l3_rect(2)],[l4_rect(1) l4_rect(2)])/(norm([l3_rect(1) l3_rect(2)]) * norm([l4_rect(1) l4_rect(2)]));

    Hm = inv(H);
    
    cosine1, cosine2, cosine1_rectified, cosine2_rectified
end