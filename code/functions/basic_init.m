function [state] = basic_init(state, path, trace_count, f_s, p_begin, p_end, ...
    bits, traces_per_dir, debug, varargin)
%BASIC_INIT Init basic stuff
%   N/A

optargin = size(varargin, 2);

state.path = path;
state.trace_count = trace_count;
state.f_s = f_s;
state.p_begin = round(f_s * p_begin);
state.p_end = round(f_s * p_end);
state.suffix = '.dat';
state.prefix = 'trace';
state.traces_per_dir = traces_per_dir;
state.bits = bits;
state.debug = debug;
state.curr_tracefile_index = -1;

if optargin >= 1
    state.prefix = varargin{1};
end

end
