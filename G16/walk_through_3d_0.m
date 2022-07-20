function walk_through_3d_0(bim, vx, vy, ...
                        floorx, floory, backx, backy, J, rect, num_of_fg)
% This function takes 
% - the coordinates of five places [ceilx, ceily, floorx, floory, leftx, lefty, 
%   rightx, righty, backx, backy]
% - the coordinates of vanishing point [vx, vy]
% - the expanded image [bim]
% - the extracted foreground objects [J]
% - homography transformed foreground image [rect]
% - number of foreground objects [num_of_fg]
%
% and produces a 3D reconstruction in the shape of a box of the original
% image. It provides user interface to control the camera position and view
% angle as well.

    %% generate front-parallel views of each plane
    xmin =  floorx(4);
    xmax = floorx(3);
    ymin = backy(1);
    ymax = floory(3);
    
    %% destination  
    destination_point = [xmin xmax xmax xmin; ymin ymin ymax ymax];
    
    %% Calculate 3D dimension
    similarity_trigularity_ratio = sqrt((xmax-xmin)*(ymax-ymin)/ ...
        ((backx(2)-backx(1))*(backy(3)-backy(2))));
    
    focal_length = 1500;
    % Compute depth of each plane via triangular similarity
    depth_bottom = focal_length * ((ymax - vy) / (backy(3) - vy) - 1);
    depth = focal_length*(similarity_trigularity_ratio -1);

    %% transform of the image
    Rout = imref2d(size(bim, 1:2));
    
    source_floor = [floorx; floory];

    t_floor = fitgeotrans(source_floor', destination_point', 'projective');
    floor = imwarp(bim, t_floor, 'OutputView', Rout);
    
    
    source_back = [backx; backy];
    size(source_back);
    size(destination_point);
%     [h_back,t_back] = computeH(source_back, destination_point);
%     back = imtransform(bim, t_back, 'xData',[xmin xmax],'yData', ...
%         [ymin ymax]);
    t_back = fitgeotrans(source_back(:, 1:4)', destination_point', 'projective');
    back = imwarp(bim, t_back, 'OutputView', Rout);
    
    
   
    %% sample code on how to display 3D sufraces in Matlab
    % define a surface in 3D (need at least 6 points, for some reason)
    
    
    floor_planex = [0 0 0; depth_bottom depth_bottom depth_bottom];
    floor_planey = [0 (xmax+xmin)/2 (xmax-xmin); 0 (xmax+xmin)/2 (xmax-xmin)];
    floor_planez = [0 0 0; 0 0 0];

    
    back_planex = [0 0 0; 0 0 0];  % set back plane fixed at x=0
    back_planey = [0 (xmax-xmin)/2 (xmax-xmin); 0 (xmax-xmin)/2 (xmax-xmin)];
    back_planez = [(ymax-ymin) (ymax-ymin) (ymax-ymin); 0 0 0];
    
    %% create the surface and texturemap it with a given image
    % axes(view_axes);
    view = figure('name','3D Walk Through');
    set(view,'windowkeypressfcn','set(gcbf,''Userdata'',get(gcbf,''CurrentCharacter''))') ;
    set(view,'windowkeyreleasefcn','set(gcbf,''Userdata'','''')') ;
    set(view,'Color','black')
    hold on
    
    f=warp(floor_planex,floor_planey,floor_planez,floor);
    b=warp(back_planex,back_planey,back_planez,back);
    
    for i = 1:num_of_fg
        rect{i}(1, [1 3]) = rect{i}(1, [1 3]);
        rect{i}(1, [2 4]) = rect{i}(1, [2 4]);

        % x, y, z coordinates of the plane corresponding to foreground in 
        % 3D by using triangular similarity
        fg_depth = depth_bottom*(1 - (ymax-rect{i}(1, 4))/(ymax-backy(3)));
        fg_heigth = (ymax - vy) - (rect{i}(1, 2) - vy)*(ymax-vy) / (rect{i}(1, 4) - vy);
        fg_width = (rect{i}(1,3)-rect{i}(1,1)) * (ymax - vy) / (rect{i}(1, 4)-vy);
           
        % Define corresponding surfaces of the foreground in 3D 
        fg_planex = [fg_depth fg_depth fg_depth; fg_depth fg_depth fg_depth];
        l_vertex = find_line_x(backx(4), backy(4), vx, vy, rect{i}(1, 4));
        fg_x_3d = (rect{i}(1,1) - l_vertex) * (ymax - vy) / (rect{i}(1, 4) - vy);
        fg_planey = [fg_x_3d (2*fg_x_3d+fg_width)/2 (fg_x_3d+fg_width);
                     fg_x_3d (2*fg_x_3d+fg_width)/2 (fg_x_3d+fg_width)];
        fg_planez = [fg_heigth fg_heigth fg_heigth;0 0 0];

        % create surface of foreground
        warp(fg_planex, fg_planey, fg_planez, J{i});

    end
    
    % Some 3D magic...
    axis equal;  % make X,Y,Z dimentions be equal
    axis vis3d;  % freeze the scale for better rotations
    axis off;    % turn off the stupid tick marks
    axis xy;     % Default direction. For axes in a 2-D view, 
                 % the y-axis is vertical with values increasing from bottom to top.
    xlabel('x'); 
    ylabel('y');
    zlabel('z'); 

    annotation('textbox',[.02,.002,.1,.1], ...
           'String','Directions[W|S|A|D|Q|E] Rotate[←|→|↓|↑] Zoom[Z|X] Exit[ESC]', ...
           'FitBoxToText','on', ...
           'Color', 'blue');

    camproj('perspective');  % make it a perspective projection
    
    % set camera position
    camx = depth_bottom;
    camy = mean(backx);
    camz = mean(backy);

    % set camera target
    tarx = 0;
    tary = mean(backx);
    tarz = mean(backy);

   
    % Camera motion
    R = eye(3);
    T = zeros(3, 1);
    rot_matrix = eye(3);
    tran = zeros(3, 1);

    % set camera step
    stepx = mean(backx)/50;
    stepy = mean(backy)/50;
    stepz = depth/50;
    step_angle = pi/18;

    % set camera on ground
    % set camera in the middle of the last scene
    camup('manual');
    camup([0;0;1]);
    campos([camx camy camz]);

    cam_target = [tarx tary tarz]';
    camtarget(cam_target);

    
    %% Wait for user's commands
    key = 0;
    while (~key)
        try
            waitforbuttonpress;
            key = get(view, 'currentch');
            
            switch key
                case 'd'    % move left
                    tran = [0; stepx; 0];
                    camtarget(cam_target + tran);
                case 'a'    % move right
                    tran = [0; -stepx; 0];
                    camtarget(cam_target + tran);
                case 's'    % move up
                    tran = [0; 0; -stepy];
                    camtarget(cam_target + tran);
                case 'w'    % move down
                    tran = [0; 0; stepy];
                    camtarget(cam_target + tran);
                case 'q'    % move inwards
                    tran = [stepz; 0; 0];
                case 'e'    % move outwards
                    tran = [-stepz; 0; 0];
                case 'z'    % zoom in
                    camzoom(1 + 0.1);
                case 'x'    % zoom out
                    camzoom(1 - 0.1);
                case 28     % look left
                    old_campos = campos;
                    camorbit(step_angle, 0, 'data');
                    rot_matrix = ypr2rotm(step_angle, 0, 0);
                    tran = (campos - old_campos)';
                case 29     % look right
                    old_campos = campos;
                    camorbit(-step_angle, 0, 'data');
                    rot_matrix = ypr2rotm(-step_angle, 0, 0);
                    tran = (campos - old_campos)';
                case 30     % look up
                    old_campos = campos;
                    camorbit(step_angle, 0, 'data', [0; 1; 0]);
                    rot_matrix = ypr2rotm(0, step_angle, 0);
                    tran = (campos - old_campos)';
                case 31     % look down
                    old_campos = campos;
                    camorbit(-step_angle, 0, 'data', [0; 1; 0]);
                    rot_matrix = ypr2rotm(0, -step_angle, 0);
                    tran = (campos - old_campos)';
                case 27     % exit 3D walk through
                    fprintf("3D Scene Walk Through closed\n");
                    break;
                case 'p'    % exit 3D walk through
                    fprintf("3D Scene Walk Through closed\n");
                    break;
            end
        catch
            % disable error alerm when exit by closing window
            fprintf("3D Scene Walk Through closed\n");
            break;
        end
        
        key = 0;
    
        pause(.001);
    
        %campos([camx camy camz]);
        %camtarget([tarx tary tarz]);
        campos(campos' + tran);

        cam_target = camtarget' + tran;
        
        R = rot_matrix * R;
        T = T + tran;
        
    end
    delete(view);
end
