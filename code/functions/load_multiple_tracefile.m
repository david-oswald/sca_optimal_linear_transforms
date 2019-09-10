function [traces ciphertext state] = load_multiple_tracefile(state, index)
%LOAD_MULTIPLE_TRACEFILE Load a trace or throw an error
%   N/A

file = sprintf('%s/%d/Traces_%d.dat', state.path, ...
    floor(index/state.traces_per_dir), index);

if state.debug == 1
    fprintf(1, 'Loading ''%s''\n', file);
end

if state.curr_tracefile_index ~= index && state.curr_tracefile_index >= -0
    % Open new tracefile
    fclose(state.curr_tracefile_fp);  
end

fp = fopen(file, 'rb');

if fp == -1
   state.curr_tracefile_fp = -1;
   state.curr_tracefile_index = -1;
   error(sprintf('File ''%s'' not readable\n', file));
end

state.curr_tracefile_fp = fp;
state.curr_tracefile_index = index;

% load data
traces_per_file = fread(fp, 1, 'uint32');
points_per_trace = fread(fp, 1, 'uint32');

if state.debug == 1
    fprintf(1, 'Read %d traces with %d points each\n', traces_per_file, points_per_trace);
end

state.aes_ciphertext = zeros(traces_per_file, 16);

first_trace = fread(fp, points_per_trace, 'int8');
state.aes_ciphertext(1, :) = fread(fp, 16, 'uint8');

if state.p_begin <= 0
    p_begin = 1;
else
    p_begin = state.p_begin;
end
if state.p_end <= 0
    p_end = length(first_trace);
else
    p_end = state.p_end;
end

points_per_trace_cut = p_end - p_begin + 1;

state.current_traces = zeros(traces_per_file, points_per_trace_cut);
state.current_traces(1, :) = first_trace(p_begin:p_end);
    
for idx_t = 2:traces_per_file
    points_per_trace_check = fread(fp, 1, 'uint32');
    
    if points_per_trace_check ~= points_per_trace
       error('Points per traces did not match (%d vs. %d)', points_per_trace, ...
           points_per_trace_check);
    end
    
    curr_trace = fread(fp, points_per_trace, 'int8'); 
    state.current_traces(idx_t,:) = curr_trace(p_begin:p_end);
    
    state.aes_ciphertext(idx_t,:) = fread(fp, 16, 'uint8');
end


traces = state.current_traces;
ciphertext = state.aes_ciphertext;

end
