% EXAMPLE
% 
%   Read and plot Sea Surface Temperature (SST) dataset from Amazon S3(TM).
%
% AWS is a registered trademark of Amazon Technologies, Inc. 
% Amazon S3 is a trademark of Amazon Technologies, Inc. 
%
% Copyright 2024 - 2024 The MathWorks, Inc.
%

% 1. Find the relevant DAAC/endpoint for the dataset that you want to access
%    For the following dataset:
%       s3://podaac-ops-cumulus-protected/MODIS_A-JPL-L2P-v2019.0/
%            20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc
%    the relevant DAAC is PODAAC and the relevant endpoint is:
%       https://archive.podaac.earthdata.nasa.gov/s3credentials

% 2. Set AWS(R) credentials using the loadAWSCredentials function, passing the relevant endpoint
daacCredentialsEndpoint = "https://archive.podaac.earthdata.nasa.gov/s3credentials";
loadAWSCredentials(daacCredentialsEndpoint);

% 3. Read relevant data/attributes
% We use MATLAB HDF5(R) for interacting with netCDF files on the cloud, 
% because the HDF5 infrastructure is able to interact with netCDF4 files
% and is cloud-enabled, while netCDF interfaces are not.
locator = "s3://podaac-ops-cumulus-protected/MODIS_A-JPL-L2P-v2019.0/20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc";
datasetPath = "/sea_surface_temperature_4um";

% Display information about the dataset
h5disp(locator, datasetPath);
  % We see that the unit is Kelvin and that the offset corresponds exactly to
  % the difference between the Celsius and Kelvin scales. We can then omit to
  % read/add the offset and, after scaling, get SST directly in Celsius.

% Read SST and attributes
data = h5read(locator, datasetPath);
name = h5readatt(locator, datasetPath, "long_name");
scaleFactor = h5readatt(locator, datasetPath, "scale_factor");
fillValue = h5readatt(locator, datasetPath, "_FillValue");

% Clean and scale the data
data(data==fillValue) = NaN;
data = double(data) * double(scaleFactor);

% Read coordinates
lat = h5read(locator, "/lat");
lon = h5read(locator, "/lon");

% 4. Plot the data using a filled contour plot with 15 levels
contourf(lon, lat, data, 15, EdgeColor="none");
clim([4,30]);
colorbar();

% Build title based on the dataset (long) name
title(sprintf("%s [C]", name));
