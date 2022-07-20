% %% test the 1st solution of foreground selection
% [imgsrc] = imread('oil-painting.png');
% [out,rectout,mask] = foregroundsele1(imgsrc);
% 
% figure, imshow(out)

%% main function
function [out,rectout,mask] = foregroundsele_app(img, k, p)
% Preparation
[M,N,D] = size(img);
%figure, imshow(img)
mask = zeros(M, N);
% Manual point selection
for i = 1:k
    if i<k
        mask = pixelcontect(mask,p(i,:),p(i+1,:));
    else
        mask = pixelcontect(mask,p(i,:),p(1,:));
    end
end
mask = imfill(mask,'hole');

if D>1
   mask = cat(3,mask,mask,mask); 
end

% Extract target foreground
out = mask.*double(img);
out = uint8(out);

% Crop a minimum rectangle around the foreground object
[x1,x2,y1,y2,out] = cutblackborders(out);
rectout = [x1,y1,x2,y2];

% Blur the background around foreground objects within the rectangle
blur = imcrop(img,[x1 y1 x2 y2]);
blur = imcrop(blur,[0 0 (x2-x1) (y2-y1)]);
[m,n,d] = size(blur);
blur_mask = im2gray(out);
blur_mask = logical(blur_mask);
blur_H = fspecial('disk',10);
blurred = imfilter(blur,blur_H,'replicate');
for i=1:m
    for j=1:n
        if blur_mask(i,j)==0
            out(i,j,:) = blurred(i,j,:);
        end
    end
end

end

%% Subfunction

function a = pixelcontect(a,p0,p1)

a(p0(1),p0(2)) = 1;
a(p1(1),p1(2)) = 1;
dis = p1 - p0;
gap = ((-1).^double(dis<0));
absdis = abs(dis);
more = max(absdis);
less = min(absdis);

if absdis(1)>=absdis(2)
    dir1 = [gap(1),0];
    dir2 = [0,gap(2)];
else
    dir2 = [gap(1),0];
    dir1 = [0,gap(2)];
end

lmp = less/more;
i = 0;
j = 0;

while i<more
    p0 = p0+dir1;
    a(p0(1),p0(2)) = 1;
    i = i+1;
    if i<more
           p1 = p1-dir1;
           a(p1(1),p1(2)) = 1;
           i = i + 1;
    end
    if j/i<lmp
        if j<less
            p0 = p0 + dir2;
            a(p0(1),p0(2)) = 1;
            j = j+1;
        end
        if j<less
           p1 = p1-dir2;
            a(p1(1),p1(2)) = 1;
            j = j+1;
        end
    end
end

end

function [x1,x2,y1,y2,out] = cutblackborders(img)

[M,N,D] = size(img);
bw = im2gray(img);

X = sum(bw,2);
Y = sum(bw,1);

% Delete all rows and columns with all elements equal to 0
% Find the coordinates of the four vertices of the rectangle
for i=1:M
    if X(i)~=0
        y1 = i;
        break
    end
end

for i=y1:M
    if X(i)==0
        y2 = i;
        break
    end
end

for i=1:N
    if Y(i)~=0
        x1 = i;
        break
    end
end

for i=x1:N
    if Y(i)==0
        x2 = i;
        break
    end
end

% Crop rectangle based on vertex coordinates
out = imcrop(img,[x1 y1 x2 y2]);
out = imcrop(out,[0 0 (x2-x1) (y2-y1)]);

end








