function [outputArg1,outputArg2] = take_a_photo(handles, bim, bim_alpha, ...
    ceilx, ceily, floorx, floory, leftx, lefty, rightx, righty, ...
    backx, backy)
%TAKE_A_PHOTO this function mean to take a screenshot inside the 3d box to
% produce a 2D projection in current position
    %% generate front-parallel views of each plane
    xmin = min([ceilx(1), floorx(4), leftx(1)]);
    xmax = max([ceilx(2), floorx(3), rightx(3)]);
    ymin = min([lefty(1) righty(2) ceily(1)]);
    ymax = max([lefty(4) righty(3) floory(3)]);
    
    %% destination  
    destination_point = [xmin xmax xmax xmin; ymin ymin ymax ymax];
    
    %% Calculate 3D dimension
    similarity_trigularity_ratio = sqrt((xmax-xmin)*(ymax-ymin)/ ...
        ((backx(2)-backx(1))*(backy(3)-backy(2))));
    
    focal_length = 1500;
    
    depth = focal_length*(similarity_trigularity_ratio -1);
%     destination_point_2 = [xmin xmax xmax xmin;  0 0 depth depth];
%     destination_point_3 = [0 depth depth 0; ymin ymin ymax ymax];
    
    %% transform of the image
    Rout = imref2d(size(bim, 1:2));

    source_ceil = [ceilx; ceily];    
%     [h_ceil,t_ceil] = computeH(source_ceil, destination_point_2);
%     ceil = imtransform(bim, t_ceil, 'xData',[xmin xmax],'yData', ...
%         [0 depth]);
    t_ceil = fitgeotrans(source_ceil', destination_point', 'projective');
    ceil = imwarp(bim, t_ceil, 'OutputView', Rout);
    
    
    source_floor = [floorx; floory];
%     [h_floor,t_floor] = computeH(source_floor, destination_point_2);
%     floor = imtransform(bim, t_floor, 'xData',[xmin xmax],'yData', ...
%         [0 depth]);
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
    alpha_b = ones(size(back,1),size(back,2));
    
    
    source_left = [leftx; lefty];
%     [h_left,t_left] = computeH(source_left, destination_point_3);
%     left = imtransform(bim, t_left, 'xData',[0 depth],'yData', ...
%         [ymin ymax]);
    t_left = fitgeotrans(source_left', destination_point', 'projective');
    left = imwarp(bim, t_left, 'OutputView', Rout);
    
    source_right = [rightx; righty];
%     [h_right,t_right] = computeH(source_right, destination_point_3);
%     right = imtransform(bim, t_right, 'xData',[0 depth],'yData', ...
%         [ymin ymax]);
    t_right = fitgeotrans(source_right', destination_point', 'projective');
    right = imwarp(bim, t_right, 'OutputView', Rout);
    
    %% sample code on how to display 3D sufraces in Matlab
    % define a surface in 3D (need at least 6 points, for some reason)
    
    ceil_planex = [0 0 0; depth depth depth];
    ceil_planey = [xmin (xmax+xmin)/2 xmax; xmin (xmin+xmax)/2 xmax];
    ceil_planez = [ymax ymax ymax; ymax ymax ymax];
    
    floor_planex = [depth depth depth; 0 0 0];
    floor_planey = [xmin (xmax+xmin)/2 xmax; xmin (xmin+xmax)/2 xmax];
    floor_planez = [ymin ymin ymin; ymin ymin ymin];
    
    back_planex = [depth depth depth; depth depth depth];
    back_planey = [xmin (xmax+xmin)/2 xmax; xmin (xmin+xmax)/2 xmax];
    back_planez = [ymax ymax ymax; ymin ymin ymin];
    
    left_planex = [0 depth/2 depth; 0 depth/2 depth];
    left_planey = [xmin xmin xmin; xmin xmin xmin];
    left_planez = [ymax ymax ymax; ymin ymin ymin];
    
    right_planex = [depth depth/2 0; depth depth/2 0];
    right_planey = [xmax xmax xmax; xmax xmax xmax];
    right_planez = [ymax ymax ymax; ymin ymin ymin];

    view = figure('name','3DViewer: Directions[W-S-A-D] Zoom[Q-E] Exit[ESC]');
    set(view,'windowkeypressfcn','set(gcbf,''Userdata'',get(gcbf,''CurrentCharacter''))') ;
    set(view,'windowkeyreleasefcn','set(gcbf,''Userdata'','''')') ;
    set(view,'Color','black')
    hold on
    warp(ceil_planex,ceil_planey,ceil_planez,ceil);
    warp(floor_planex,floor_planey,floor_planez,floor);
    warp(back_planex,back_planey,back_planez,back);
    warp(left_planex,left_planey,left_planez,left);
    warp(right_planex,right_planey,right_planez,right);
    
    % Beware that matlab has 2 axis modes, ij ans xy, be sure to check if you are using
    % the right one if you get flipped results.
    
    
    
    % Some 3D magic...
    axis equal;  % make X,Y,Z dimentions be equal
    axis vis3d;  % freeze the scale for better rotations
    axis off;    % turn off the stupid tick marks
    camproj('perspective');  % make it a perspective projection
    
    % set camera position
    handles.camx = 
    camx = -1719.8;
    camy = 1345;
    camz = 858.8;
    
    % set camera target
    tarx = 228.5;
    tary = 1312;
    tarz = 817.5;
    
    % set camera step
    stepx = 0.05;
    stepy = 0.05;
    stepz = 0.05;
    
    % set camera on ground
    camup([0,0,1]);
    campos([camx camy camz]);
    
    %% Wait for user's commands
    key = 0;
    while (~key)
        try
            waitforbuttonpress;
            key = get(view, 'currentch');
            
            switch key
                case 'd'
                    camdolly(-stepx,0,0,'fixtarget');
                case 'a'
                    camdolly(stepx,0,0,'fixtarget');
                case 's'
                    camdolly(0,stepy,0,'fixtarget');
                case 'w'
                    camdolly(0,-stepy,0,'fixtarget');
                case 'q'
                    camdolly(0,0,stepz,'fixtarget');
                case 'e'
                    camdolly(0,0,-stepz,'fixtarget');
                case 28
                    campan(-0.1,0);
                case 29
                    campan(0.1,0);
                case 30
                    campan(0,0.1);
                case 31
                    campan(0,-0.1);
                case 27
                    fprintf("3D Scene Walk Through closed\n");
                    break;
                case 'p'
                    fprintf("3D Scene Walk Through closed\n");
                    break;
            end
        catch
            fprintf("3D Scene Walk Through closed\n");
            break;
        end
        
        key = 0;
    
        pause(.001);
    
        %campos([camx camy camz]);
        %camtarget([tarx tary tarz]);
        pos = campos;
        target = camtarget;
        
    end
    delete(view);

end

