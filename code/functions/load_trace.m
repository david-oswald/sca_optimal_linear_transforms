function [trace time_axis] = load_trace(state, index)
%LOAD_TRACE Load a trace or throw an error
%   N/A

file = sprintf('%s/%d/%s%d%s', state.path, ...
    floor(index/state.traces_per_dir), state.prefix, index, state.suffix);

if state.debug == 1
    fprintf(1, 'Loading ''%s''', file);
end

% load trace
if state.p_begin <= 0
    p_begin = -1;
else
    p_begin = state.p_begin;
end

if state.p_end <= 0
    p_length = -1;
else
    p_length = state.p_end - p_begin + 1;
end

%trace = trace(p_begin:p_end);

trace = read_binary_tracefile_part(file, p_begin, p_length, state.bits);

if state.debug == 1
    fprintf(1, ' => len = %d\n', length(trace));
end

if isempty(trace)
    error(sprintf('File ''%s'' empty\n', file));
end

time_axis = 1/state.f_s * (0:length(trace)-1);

end
