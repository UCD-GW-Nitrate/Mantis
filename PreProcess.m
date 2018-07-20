%% Make a unique list of land uses
LU = imread('Local/model_input_LU2005.tif');
LU_cat = unique(LU);
%% Find names for each LU category
% temp1 has all the numerical values and temp2 the text values
[temp1, temp2] = xlsread('Local/LanduseTable_2017_0515.xlsx', 'FINAL Landuse Table','A2:E208');
for ii = 1:length(LU_cat)
   id = find( temp1(:,1) == LU_cat(ii));
   LU_name{ii,1} = temp2{id,1};
end
%% Create an Raster Ascii for GIS. This is just for test purposes
% from the Local/Ngw_2005.tif.xml it appears that the 
% left lower corner of the raster is at -223300, -344600
% and that the cell size is 50 m
% The coordinate system is the EPSG: 3310
WriteAscii4Raster('Local/LU_2005_ascii',LU, -223300, -344600, 50, 0);
%% Load URF data and make sure they are in the same coordinate system
% First make one variable with all streamline points
URFS = [];
for ii = 1:4 % This is the number of processors used in the simulation
    w = load(['Local/Tule/wellURFS_000' num2str(ii-1) '.mat']);
    URFS = [URFS; w.WellURF];
end
%% Create a shapefile with the streamlines points at the land side.
% This shape file will be overlaid onto raster and convert the coordinates
% The coordinates of this shapefile are in EPSG:26911 
clear S
S = [];
S(size(URFS,1), 1).Geometry = [];
S(size(URFS,1), 1).X = [];
S(size(URFS,1), 1).Y = [];
S(size(URFS,1), 1).Eid = [];
S(size(URFS,1), 1).Sid = [];
for ii = 1:size(URFS,1)
   S(ii,1).Geometry = 'Point';
   S(ii,1).X = URFS(ii,1).p_lnd(1);
   S(ii,1).Y = URFS(ii,1).p_lnd(2);
   S(ii,1).Eid = double(URFS(ii,1).Eid);
   S(ii,1).Sid = double(URFS(ii,1).Sid);
   S(ii,1).Vland = URFS(ii,1).v_lnd;
end
shapewrite(S,'Local/Tule/TuleStrmlnPoints');
%% load the converted shapefile
% The converted shapefile has coordinates on EPSG:3310
S = shaperead('gis_data/TuleStrmlnPoints');