function lane_detection(img_name,warp,mask)
close all
%%% open image file
road = imread(img_name); % "/" might not work on windows due to dir strims
figure
imshow(road)
w = waitforbuttonpress;
close 
%%% transform the image to gray scale
grayRoad = im2double(rgb2gray(road));

%%% if the user selects imask then prompt for an image mask
C = []
if mask 
    C = imask(grayRoad)
    grayRoad = grayRoad.*C;
end 
imshow(grayRoad)
w = waitforbuttonpress;
close
%%% if user selects iwarp as an option then warp the image'
H = [];
Hi = [];
roadBW = grayRoad;
if warp == 1
    H = iwarp(grayRoad);
    [Iwarp,ref] = imwarp(grayRoad,H,'OutputView',imref2d(size(grayRoad)));
    roadBW = imbinarize(Iwarp,0.7);
    Hi = invert(H)
else
   roadBW = imbinarize(grayRoad,0.7);
end
imshow(roadBW)
w = waitforbuttonpress;
close


%%% Find the lanes using the hough transform 
houghPipeline(roadBW,road)
end


%%%%%%%%%%%%%%%%%%%%% Function finds and draw the lines %%%%%%%%%%%%%%%%%%%
function houghPipeline(img,og_img)
%%% find lines
    [H,theta,rho] = hough(edge(img,'canny'));
    figure
    imshow(imadjust(rescale(H)),[],...
           'XData',theta,...
           'YData',rho,...
           'InitialMagnification','fit');
    xlabel('\theta (degrees)')
    ylabel('\rho')
    axis on
    axis normal 
    hold on
    colormap(gca,hot)
    P = houghpeaks(H,30,'threshold',ceil(0.3*max(H(:))));
    x = theta(P(:,2));
    y = rho(P(:,1));
    plot(x,y,'s','color','black');
    %%% Display the lines
    lines = houghlines(img,theta,rho,P,'FillGap',20,'MinLength',5);
    figure, imshow(og_img), hold on
    max_len = 0;
    if warp 


    else
        for k = 1:length(lines)
           xy = [lines(k).point1; lines(k).point2];
           plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
        
           % Plot beginnings and ends of lines
           plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
           plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
        
           % Determine the endpoints of the longest line segment
           len = norm(lines(k).point1 - lines(k).point2);
           if ( len > max_len)
              max_len = len;
              xy_long = xy;
           end
        end
         % highlight the longest line segment
        plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');
    end
end 

%%%%%%%%%%%%%%%%%%%% function returns mask roi %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function C = imask(img)
    figure 
    imshow(img) 
    mask = drawpolygon;
    C = createMask(mask);
    close
end 




%%%%%%%%%%%%%%%%%%%% function returns H matrix for warping %%%%%%%%%%%%%%%%
function H = iwarp(img)
    figure
    imshow(img)
    sow = drawpolygon; %get orignal transform point
    dow = drawpolygon; %define the new points
    origin = sow.Position;
    mapped = dow.Position; % these are not coordinates but the attributes of a rectange
    %if using drawrectange on region of interest
%     xy = mapped(1:2);
%     mvx = [mapped(3),0];
%     mvy = [0,mapped(4)];
%     mvxy = mapped(3:4);
%     map_coor = [xy;mvx+xy;mvxy+xy;mvy+xy];
    map_coor = mapped;
    H = fitgeotrans(origin,map_coor, 'projective'); 
    close
end