function [data] = read_binary_datafile(strFile, varargin)
    % open binary file for reading (wb for writing)
    fid = fopen(strFile, 'rb');
    
    if fid == -1
        data = [];
        warning('Could not read "%s"', strFile);
    else
        if isempty(varargin)
            strType = 'double';
        else
            strType = varargin{1};
        end;

        % read data
        data = fread(fid, strType);

        fclose(fid);
    end
end