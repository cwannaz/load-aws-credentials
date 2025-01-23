function s3Credentials = loadAWSCredentials(daacCredentialsEndpoint, login, password)
    %LOADAWSCREDENTIALS Get/load temporary AWS(R) credentials from Earthdata
    %for accessing specific DAACs on AWS.
    %
    % Using Earthdata credentials passed as inputs or defined through 
    % environment variables EARTHDATA_LOGIN and EARTHDATA_PASSWORD, get 
    % temporary AWS credentials for accessing specific DAAC (2) datasets
    % located on Amazon S3(TM).
    %
    % NOTES
    % - Temporary AWS credentials are DAAC-specific. Each DAAC has an
    %   endpoint (URL) for requesting credentials. The endpoint for 
    %   PODAAC, for example, is (1):
    %      https://archive.podaac.earthdata.nasa.gov/s3credentials
    %   When calling LOADAWSCREDENTIALS, you must pass the endpoint
    %   that is relevant for the dataset that you want to access.
    %
    % REFERENCES
    % 1. NASA Earthdata Cloud Cookbook
    %    https://nasa-openscapes.github.io/earthdata-cloud-cookbook/
    % 2. EOSDIS Distributed Active Archive Centers (DAAC)
    %    https://www.earthdata.nasa.gov/eosdis/daacs
    %
    % AWS is a registered trademark of Amazon Technologies, Inc. 
    % Amazon S3 is a trademark of Amazon Technologies, Inc. 
    %
    % Copyright 2024 - 2024 The MathWorks, Inc.
    %

    % Get Earthdata login/password from inputs or envrionment variables
    if nargin < 2 || isempty(login)
        login = getenv("EARTHDATA_LOGIN");
    end
    if nargin < 3 || isempty(password)
        password = getenv("EARTHDATA_PASSWORD");
    end

    % Get temporary S3 credentials from EarthData
    authorization = "Basic " + matlab.net.base64encode(login + ":" + password);
    opts = weboptions("ContentType", "json", "HeaderFields", ["Authorization", authorization]);
    s3Credentials = webread(daacCredentialsEndpoint, opts);

    % Set relevant environment variables with AWS credentials/region
    setenv("AWS_ACCESS_KEY_ID", s3Credentials.accessKeyId);
    setenv("AWS_SECRET_ACCESS_KEY", s3Credentials.secretAccessKey);
    setenv("AWS_SESSION_TOKEN", s3Credentials.sessionToken);
    setenv("AWS_DEFAULT_REGION", "us-west-2");
end
