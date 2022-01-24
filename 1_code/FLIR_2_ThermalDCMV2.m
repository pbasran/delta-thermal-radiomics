%% FILENAME :         FLIR_2_ThermalDCM.m
%
% DESCRIPTION : Matlab script to open a thermal image, display it, get some
% manual input on the ranges of temperatures as displayed on the image
% itself such that a grey scale DICOM image can be generated. We multiply
% the temperature data by 10 to allow for uint precision of 0.1 degrees
% celcius in the output image. The script also allows the opportunity to
% segment the LEFT and RIGHT teats and export a label map image for it.
% Note that this code borrows 
%        
%
% NOTES :
%
% AUTHOR :    Parminder S. Basran       START DATE :    6-Oct-2021
%
% CHANGES :
%
% REF NO  VERSION DATE    WHO     DETAIL
%         

%% Set some paths 

clearvars;

% Modify as needed
readimgpath  = '../0_data/TestData'; % Test images are here
writetmppath = '../0_data/TestData';
writelblpath = '../0_data/TestData';

%% Open image and read/display it

[flnm, pthnm] = uigetfile('*.jpg', 'Select file');
rgbImg = imread(fullfile(pthnm, flnm));

figure(1);clf;
imshow(rgbImg);

[nx, ny, mp] = size(rgbImg);

%% Find the colorbar in the image and convert to a colormap

% you need to play around with the indicies based on where your colorbar is
% in the image. In our data, it tends to be in 1 of 2 locations,
% comment/uncomment the appropriate one

% If its on LEFT
%XMIN=627 YMIN=51 WIDTH=634-627 HEIGHT=429-51
clrbar = imcrop(rgbImg, [627, 51, 7, 378]);

% If its on RIGHT
%XMIN=92 YMIN=100 WIDTH=123-90 HEIGHT=380-100;
%colorBarImage = imcrop(originalRGBImage, [93, 101, 32, 280]); 

% convert colorbar into a colormap by sampling middle row of the clrbar img
[~, wdth, ~] = size(clrbar);
cmap(:,:) = clrbar(:,round(size(clrbar,2)/2),:);

% flip it around
cmap = flipud(cmap);

% scale it (should be unit8, max of 255, but convert to double)
cmap = double(cmap) / 255;


%% Manually enter in the temperature ranges

highT = input('Enter the High Temp in the colorized image : ');
lowT = input( 'Enter the Low Temp in the colorized image  : ');

%% Scale the image 

% First convert the rgbimg to new colormap cmap as greyscale image
gsImg = rgb2ind(rgbImg, cmap);

figure(2);clf
imagesc(gsImg);

thermalImg = mat2gray(gsImg) * (highT - lowT) + lowT;

figure(2); clf
imagesc(thermalImg); colorbar

%% Create Label maps (optional)

img = [];tmproi = [];

% Contour left using ROIPOLY tool
figure(1); imshow(rgbImg, []);
title('Contour the LEFT teat');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0.3 0.8 0.7]);
colorbar;
axis image;
tmpLeft = roipoly;

% Contour right using ROIPOLY tool
figure(1); imshow(rgbImg, []);
title('Contour the RIGHT teat');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0.3 0.8 0.7]);
colorbar;
axis image;
tmpRight = roipoly;

labelImg = tmpLeft + tmpRight;

%% Write images, dicom images and such to file. 
% Note, we scale the DICOM images by a factor of 10 to retain precision 
% when converting temperatures to unsigned integers


% Labelmaps... uncomment if needed
lblname = strcat(flnm(1:length(flnm)-4),'_l.bmp');
fullwritefilename = fullfile(writelblpath,lblname);
imwrite(labelImg,fullwritefilename);

% New DICOM image data
filename = strcat(flnm(1:length(flnm)-4),'.dcm');
fullwritefilename = fullfile(writetmppath,filename);
dicomwrite(uint16(thermalImg*10),fullwritefilename)

disp('Done Writing labels and DCM image.');

close(figure(1));
close(figure(2));


