function [exp_im, vx, vy,  floorx, floory,  ...
   backx, backy] = get2rects(im, vx, ...
    vy, irx, iry, orx, ory)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    % expand the image so that each "face" of the box is a proper rectangle
    [height, width, depth] = size(im);
    lmargin = 0;
    rmargin = 0;
    tmargin = 0;
    % bmargin = max(ory) - height;
    bmargin = 0;
    exp_im = zeros([height+bmargin width+rmargin depth]);
    
    exp_im(tmargin+1:end-bmargin,lmargin+1:end-rmargin,:) = im2double(im);
    
    
    % update all variables for the new image
    vx = vx + lmargin;
    vy = vy + tmargin;
    irx = irx + lmargin;
    iry = iry + tmargin;
    orx = orx + lmargin;
    ory = ory + tmargin;


    %% define 2 rectangls
    
    % floor
    floorx = [irx(4), irx(3), orx(1), orx(2)];
    floory = [iry(4), iry(3), ory(1), ory(2)];
    % choose the one closer to the rear wall
    if(floory(3) > floory(4))
        floorx(3) = round(find_line_x(vx, vy, floorx(3), floory(3), floory(4)));
        floory(3) = floory(4);
    else
        floorx(4) = round(find_line_x(vx, vy, floorx(4), floory(4), floory(3)));
        floory(3) = floory(4);
    end

    backx = irx;
    backy = iry;
end