function [trace] = read_binary_tracefile(strTraceFile, varargin)
    % open binary file for reading (wb for writing)
    fid = fopen(strTraceFile, 'rb');
    
    if fid == -1
        trace = [];
    else
        if isempty(varargin)
            width = 16;
        else
            width = varargin{1};
        end;
        
        % get file size
        fseek(fid, 0, 'eof');
        size = ftell(fid);
        sample_count = size*8/width;

        % return to file beginning
        fseek(fid, 0, 'bof');

        % read data
        strType = sprintf('int%d', width);
        trace = fread(fid, sample_count, strType);

        fclose(fid);
    end
end