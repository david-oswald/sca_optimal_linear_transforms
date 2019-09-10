function [trace] = read_binary_tracefile_part(strTraceFile, offset, len, varargin)
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
        if len == -1
            fseek(fid, 0, 'eof');
            size = ftell(fid);
            sample_count = size*8/width;
        else
            sample_count = len*8/width;
        end
        
        % return to file beginning
        if offset == -1
            fseek(fid, 0, 'bof');
        else
            fseek(fid, offset*8/width, 'bof');   
        end

        % read data
        strType = sprintf('int%d', width);
        trace = fread(fid, sample_count, strType);

        fclose(fid);
    end
end