function view_point_out_of_box(ceil, floor, left, right, xmax, ymax, cam_y, cam_z)
% This functiont checks whether the camera center is located outside the
% reconstructed 3D box, if so it makes the plane transparent to provide a
% better viewing experience.
% 
    if cam_y < 0
        left.FaceAlpha = 0;
    elseif cam_y > xmax
        right.FaceAlpha = 0;
    else
        left.FaceAlpha = 1;
        right.FaceAlpha = 1;
    end
    
    if cam_z < 0
        floor.FaceAlpha = 0;
    elseif cam_z > ymax
        ceil.FaceAlpha = 0;
    else
        floor.FaceAlpha = 1;
        ceil.FaceAlpha = 1;
    end

end

