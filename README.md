# Load AWS Credentials for Accessing EOSDIS Datasets on S3 with MATLAB

[![View <File Exchange Title> on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/####-file-exchange-title)  
<!-- Add this icon to the README if this repo also appears on File Exchange via the "Connect to GitHub" feature --> 

NASA EOSDIS' DAACs (1) are progressively made available on the cloud, 
in Amazon S3&trade; region `us-west-2`. 

Direct S3 access is achieved by passing NASA supplied temporary credentials to AWS&reg;, 
so we can interact with S3 objects from applicable EarthData Cloud buckets. 
For now, each NASA DAAC has different endpoints (URL) for requesting AWS credentials (2).

This MATLAB&reg; function, `loadAWSCredentials`, uses Earthdata credentials passed 
as inputs or defined through environment variables `EARTHDATA_LOGIN` and 
`EARTHDATA_PASSWORD`, to get and load temporary DAAC-specific AWS credentials 
for accessing datasets located in AWS/S3.

Currently, DAACs are located in AWS region `us-west-2` and they can only be 
accessed from this region. `loadAWSCredentials` hence targets a workflow where 
both the __data__ and the __compute__ (e.g., from a MATLAB instance running 
in Amazon EC2&reg;) are located on AWS in this region.

Amazon Web Services, AWS, are trademarks of Amazon.com, Inc. or its affiliates.  
Amazon EC2 is a registered service mark of Amazon Technologies, Inc.  
Amazon S3 is a trademark of Amazon Technologies, Inc.  
HDF is a registered trademark of The HDF Group

This work is derived from work that is Copyright &copy; Openscapes ([link](https://github.com/openscapes/approach-guide))
under a [license adapted from The Turing Way](https://nasa-openscapes.github.io/earthdata-cloud-cookbook/#license). 
It uses the same dataset but focuses more on retrieving information about
the data set. This material will ultimately be leveraged to improve the
NASA Earthdata Cloud Cookbook directly.

## Setup 
Define environment variables `EARTHDATA_LOGIN` and `EARTHDATA_PASSWORD` using your Earthdata credentials.
``` bash
setenv("EARTHDATA_LOGIN","your_earthdata_login");
setenv("EARTHDATA_PASSWORD","your_earthdata_password");
```
We recommend to perform these calls outside of your project, so you do not share your credentials while sharing your project. A generallly suitable place to to it is
in MATLAB [`startup.m`](https://www.mathworks.com/help/matlab/ref/startup.html) script.


## Example

Read and plot Sea Surface Temperature (SST).

### 1. Find the relevant DAAC/endpoint for the dataset that you want to access

For the following dataset:

`s3://podaac-ops-cumulus-protected/MODIS_A-JPL-L2P-v2019.0/20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc`

the relevant DAAC is PODAAC and the relevant endpoint is:

`https://archive.podaac.earthdata.nasa.gov/s3credentials`

### 2. Load AWS credentials using the `loadAWSCredentials` function, passing the relevant endpoint

``` bash
daacCredentialsEndpoint = "https://archive.podaac.earthdata.nasa.gov/s3credentials";
loadAWSCredentials(daacCredentialsEndpoint);
```

These credentials are temporary; they expire every 30 minutes or so and must be refreshed periodically.

### 3. Read relevant data/attributes

We use [MATLAB HDF5&reg; interfaces](https://www.mathworks.com/help/matlab/hdf5-files.html) for interacting 
with netCDF files on the cloud, because the HDF5 infrastructure is able to interact with netCDF4 files and 
is cloud-enabled, while netCDF interfaces are not.

``` bash
locator = "s3://podaac-ops-cumulus-protected/MODIS_A-JPL-L2P-v2019.0/20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc";
datasetPath = "/sea_surface_temperature_4um";
```

Display information about the dataset:

``` bash
h5disp(locator, datasetPath);
```

Output:

```
HDF5 20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc 
Dataset 'sea_surface_temperature_4um' 
    Size:  1354x2030x1
    MaxSize:  1354x2030x1
    Datatype:   H5T_STD_I16LE (int16)
    ChunkSize:  677x1015x1
    Filters:  deflate(5)
    FillValue:  -32767
    Attributes:
        'long_name':  'sea surface temperature'
        'units':  'kelvin'
        '_FillValue':  -32767 
        'valid_min':  -1000 
        'valid_max':  10000 
        'comment':  'sea surface temperature from mid-IR (4 um) channels; non L2P core field'
        'scale_factor':  0.005000 
        'add_offset':  273.149994 
        'coordinates':  'lon lat'
        'coverage_content_type':  'physicalMeasurement'
        'DIMENSION_LIST':  H5T_VLEN
```

We see that the unit is Kelvin and that the offset corresponds exactly to
the difference between the Celsius and Kelvin scales. We can then omit to
read/add the offset and, after scaling, get SST directly in Celsius.

Read SST and attributes:
``` bash
data = h5read(locator, datasetPath);
name = h5readatt(locator, datasetPath, "long_name");
scaleFactor = h5readatt(locator, datasetPath, "scale_factor");
fillValue = h5readatt(locator, datasetPath, "_FillValue");
```

Clean and scale the data:
``` bash
data(data==fillValue) = NaN;
data = double(data) * double(scaleFactor);
```

Read coordinates:
``` bash
lat = h5read(locator, "/lat");
lon = h5read(locator, "/lon");
```

### 4. Plot the data

Build filled contour plot with 15 levels and set color limits to the 4&deg;C-30&deg;C range:

``` bash
contourf(lon, lat, data, 15, EdgeColor="none");
clim([4,30]);
colorbar();
```

Build title based on the dataset (long) name:
``` bash
title(sprintf("%s [C]", name));
```

## References

1. [EOSDIS Distributed Active Archive Centers (DAAC)](https://www.earthdata.nasa.gov/eosdis/daacs)
2. [NASA Earthdata Cloud Cookbook](https://nasa-openscapes.github.io/earthdata-cloud-cookbook/)


## License

The license is available in the License.txt file in this GitHub repository.

## Community Support
[MATLAB Central](https://www.mathworks.com/matlabcentral)

Copyright 2024 The MathWorks, Inc.
