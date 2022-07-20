% This file mean to move the 3D Box and get the new 2D projection in real
% time, method: move the vanished point according to users' keyboard
% input


function move(im, handles)
% This function takes the coordinates of five places and the expanded image
% and produces a 3D reconstruction in the shape of a box of the original
% image. It provides user interface to control the camera position and view
% angle as well.
    
    [height, width, ~] = size(im);
    % step size of changed vp and rectangle 
    stepx = 0.05;
    stepy = 0.05;
    stepz = 0.05;

    %% generate new inner and outter wall according to user keyboard input
    key = 0;

    
    while (~key)
        try
            waitforbuttonpress;
            key = get(view, 'currentch');
            
            switch key
                case 'd'
                    handles.vx = handles.vx + stepx;
                    handles.irx = handles.irx + stepx;
                    [ox, oy] = find_corner(handles.vx, handles.vy, ...
                        handles.irx(1), handles.iry(1), 0 , 0);
                    handles.orx(1) = ox;
                    handles.ory(1) = oy;

                    [ox,oy] = find_corner(handles.vx,handles.vy, ...
                        handles.irx(2),handles.iry(2),width,0);
                    handles.orx(2) = ox;  handles.ory(2) = oy;
                    [ox,oy] = find_corner(handles.vx,handles.vy, ...
                        handles.irx(3),handles.iry(3),width,height);
                    handles.orx(3) = ox;  handles.ory(3) = oy;
                    [ox,oy] = find_corner(handles.vx,hadnles.vy, ...
                        handles.irx(4),handles.iry(4),0,height);    
                    handles.orx(4) = ox;  handles.ory(4) = oy;
                    handles.orx = round(orx);
                    handles.ory = round(ory);
                    [bim, bim_alpha, ceilx, ceily, floorx, floory, ...
                        leftx, lefty, rightx, righty, backx, ...
                        backy] = get5rects(im, handles.vx, ...
                        handles.vy, handles.irx, handles.iry, ...
                        handles.orx, handles.ory);
                    % todo: just prototype, should correct the
                    % walk_throught function here
                    walk_through_3d(bim, bim_alpha, vx, vy, ceilx, ceily, ...
                        floorx, floory, leftx, lefty, rightx, ...
                        righty, backx, backy,J, rect);
                case 'a'
                    handles.vx = handles.vx - stepx;
                    handles.irx = handles.irx - stepx;
                    [ox, oy] = find_corner(handles.vx, handles.vy, ...
                        handles.irx(1), handles.iry(1), 0 , 0);
                    handles.orx(1) = ox;
                    handles.ory(1) = oy;

                    [ox,oy] = find_corner(handles.vx,handles.vy, ...
                        handles.irx(2),handles.iry(2),width,0);
                    handles.orx(2) = ox;  handles.ory(2) = oy;
                    [ox,oy] = find_corner(handles.vx,handles.vy, ...
                        handles.irx(3),handles.iry(3),width,height);
                    handles.orx(3) = ox;  handles.ory(3) = oy;
                    [ox,oy] = find_corner(handles.vx,hadnles.vy, ...
                        handles.irx(4),handles.iry(4),0,height);    
                    handles.orx(4) = ox;  handles.ory(4) = oy;
                    handles.orx = round(orx);
                    handles.ory = round(ory);
                    [bim, bim_alpha, ceilx, ceily, floorx, floory, ...
                        leftx, lefty, rightx, righty, backx, ...
                        backy] = get5rects(im, handles.vx, ...
                        handles.vy, handles.irx, handles.iry, ...
                        handles.orx, handles.ory);
                    % todo: just prototype, should correct the
                    % walk_throught function here
                    walk_through_3d(bim, bim_alpha, vx, vy, ceilx, ceily, ...
                        floorx, floory, leftx, lefty, rightx, ...
                        righty, backx, backy,J, rect);

                case 's'
                    handles.vy = handles.vx - stepy;
                    handles.iry = handles.iry - stepy;
                    [ox, oy] = find_corner(handles.vx, handles.vy, ...
                        handles.irx(1), handles.iry(1), 0 , 0);
                    handles.orx(1) = ox;
                    handles.ory(1) = oy;

                    [ox,oy] = find_corner(handles.vx,handles.vy, ...
                        handles.irx(2),handles.iry(2),width,0);
                    handles.orx(2) = ox;  handles.ory(2) = oy;
                    [ox,oy] = find_corner(handles.vx,handles.vy, ...
                        handles.irx(3),handles.iry(3),width,height);
                    handles.orx(3) = ox;  handles.ory(3) = oy;
                    [ox,oy] = find_corner(handles.vx,hadnles.vy, ...
                        handles.irx(4),handles.iry(4),0,height);    
                    handles.orx(4) = ox;  handles.ory(4) = oy;
                    handles.orx = round(orx);
                    handles.ory = round(ory);
                    [bim, bim_alpha, ceilx, ceily, floorx, floory, ...
                        leftx, lefty, rightx, righty, backx, ...
                        backy] = get5rects(im, handles.vx, ...
                        handles.vy, handles.irx, handles.iry, ...
                        handles.orx, handles.ory);
                    % todo: just prototype, should correct the
                    % walk_throught function here
                    walk_through_3d(bim, bim_alpha, vx, vy, ceilx, ceily, ...
                        floorx, floory, leftx, lefty, rightx, ...
                        righty, backx, backy,J, rect);

                    
                case 'w'
                    handles.vy = handles.vx + stepy;
                    handles.iry = handles.iry + stepy;
                    [ox, oy] = find_corner(handles.vx, handles.vy, ...
                        handles.irx(1), handles.iry(1), 0 , 0);
                    handles.orx(1) = ox;
                    handles.ory(1) = oy;

                    [ox,oy] = find_corner(handles.vx,handles.vy, ...
                        handles.irx(2),handles.iry(2),width,0);
                    handles.orx(2) = ox;  handles.ory(2) = oy;
                    [ox,oy] = find_corner(handles.vx,handles.vy, ...
                        handles.irx(3),handles.iry(3),width,height);
                    handles.orx(3) = ox;  handles.ory(3) = oy;
                    [ox,oy] = find_corner(handles.vx,hadnles.vy, ...
                        handles.irx(4),handles.iry(4),0,height);    
                    handles.orx(4) = ox;  handles.ory(4) = oy;
                    handles.orx = round(orx);
                    handles.ory = round(ory);
                    [bim, bim_alpha, ceilx, ceily, floorx, floory, ...
                        leftx, lefty, rightx, righty, backx, ...
                        backy] = get5rects(im, handles.vx, ...
                        handles.vy, handles.irx, handles.iry, ...
                        handles.orx, handles.ory);
                    % todo: just prototype, should correct the
                    % walk_throught function here
                    walk_through_3d(bim, bim_alpha, vx, vy, ceilx, ceily, ...
                        floorx, floory, leftx, lefty, rightx, ...
                        righty, backx, backy,J, rect);
                    
            end

        
        catch
            fprintf("3D Scene Walk Through closed\n");
            break;
        end
    end

    
end
