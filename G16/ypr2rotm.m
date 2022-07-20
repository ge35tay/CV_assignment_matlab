function [R] = ypr2rotm(yaw, pitch, roll)
%rotation_ypr takes the euler angles yaw, pitch and roll in radius and computes the
%corresponding rotation in matrix representaion
    
    Rz = [cos(yaw) -sin(yaw)  0;
          sin(yaw)  cos(yaw)  0;
          0         0         1];
    
    Ry = [cos(pitch)  0  sin(pitch);
          0           1           0;
          -sin(pitch) 0  cos(pitch)];
    
    Rx = [1    0          0;
          0    cos(roll) -sin(roll);
          0    sin(roll)  cos(roll)];
    
    
    R = Rz * Ry * Rx;
end
