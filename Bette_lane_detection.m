%% open image file 
road = imread("test_image/solidWhiteCurve.jpg"); % "/" might not work on windows due to dir strims
figure
imshow(road)
w = waitforbuttonpress;
close 

%% transform the image to gray scale
figure
grayRoad = im2double(rgb2gray(road));
imshow(grayRoad)

%% using birds eye view
focalLength = [309.4362 344.2161];
principalPoint = [318.9034 257.5352];
imageSize = [480 640];

camIntrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);
height = 2.1798;
pitch = 14;
sensor = monoCamera(camIntrinsics,height,'Pitch',pitch);
distAhead = 30;
spaceToOneSide = 6;
bottomOffset = 3;

outView = [bottomOffset,distAhead,-spaceToOneSide,spaceToOneSide];
outImageSize = [NaN,250];
birdsEye = birdsEyeView(sensor,outView,outImageSize);

BEV = transformImage(birdsEye,grayRoad);
imagePoint = vehicleToImage(birdsEye,[20 0]);
annotatedBEV = insertMarker(BEV,imagePoint);
annotatedBEV = insertText(annotatedBEV,imagePoint + 5,'20 meters');


figure
imshow(annotatedBEV)
title('Bird''s-Eye-View Image: vehicleToImage')

