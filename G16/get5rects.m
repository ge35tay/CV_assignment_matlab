function [exp_im, vx, vy, ceilx, ceily, floorx, floory, leftx, lefty, ...
    rightx, righty, backx, backy, lmargin, tmargin] = get5rects(im, vx, ...
    vy, irx, iry, orx, ory)
    
    %% expand the image so that each "face" of the box is a proper rectangle
    [height, width, depth] = size(im);
    lmargin = -min(orx);
    rmargin = max(orx) - width;
    tmargin = -min(ory);
    bmargin = max(ory) - height;
    exp_im = zeros([height+tmargin+bmargin width+lmargin+rmargin depth]);
    exp_im(tmargin+1:end-bmargin,lmargin+1:end-rmargin,:) = im2double(im);
    
    
    % update all variables for the new image
    vx = vx + lmargin;
    vy = vy + tmargin;
    irx = irx + lmargin;
    iry = iry + tmargin;
    orx = orx + lmargin;
    ory = ory + tmargin;


    %% define 5 rectangls
    % ceiling
    ceilx = [orx(1), orx(2), irx(2), irx(1)];
    ceily = [ory(1), ory(2), iry(2), iry(1)];
    % choose the higher one as ceily and make both ceily the same
    if (ceily(1) < ceily(2))
        ceilx(1) = round(find_line_x(vx, vy, ceilx(1),ceily(1), ceily(2)));
        ceily(1) = ceily(2);
    else
        ceilx(2) = round(find_line_x(vx, vy, ceilx(2), ceily(2),ceily(1)));
        ceily(2) = ceily(1);
    end


    % floor
    floorx = [irx(4), irx(3), orx(3), orx(4)];
    floory = [iry(4), iry(3), ory(3), ory(4)];
    % choose the one closer to the rear wall
    if(floory(3) > floory(4))
        floorx(3) = round(find_line_x(vx, vy, floorx(3), floory(3), floory(4)));
        floory(3) = floory(4);
    else
        floorx(4) = round(find_line_x(vx, vy, floorx(4), floory(4), floory(3)));
        floory(3) = floory(4);
    end

    % left
    leftx = [orx(1), irx(1), irx(4), orx(4)];
    lefty = [ory(1), iry(1), iry(4), ory(4)];
    
    % choose the one away from rear wall
    if(leftx(1) < leftx(4))
        lefty(1) = round(find_line_y(vx, vy, leftx(1), lefty(1), leftx(4)));
        leftx(1) = leftx(4);
    else
        lefty(4) = round(find_line_y(vx, vy, leftx(4), lefty(4), leftx(1)));
        leftx(4) = leftx(1);
    end
    
    % right
    rightx = [irx(2), orx(2), orx(3), irx(3)];
    righty = [iry(2), ory(2), ory(3), iry(3)];
    if(rightx(2) > rightx(3))
        righty(2) = round(find_line_y(vx, vy, rightx(2), righty(2), rightx(3)));
        rightx(2) = rightx(3);
    else
        righty(3) = round(find_line_y(vx, vy, rightx(3), righty(3), rightx(2)));
        rightx(3) = rightx(2);
    end

    backx = irx;
    backy = iry;

end