function [state] = static_align_init(state, ref_trace, ...
    search_begin, search_end, pattern_start, pattern_end)

ref_trace = ref_trace(:);
f_s = state.f_s;

search_begin = round(f_s * search_begin);
search_end = round(f_s * search_end); 
pattern_start = round(f_s * pattern_start);
pattern_end = round(f_s * pattern_end);

state.pattern = ref_trace(pattern_start:pattern_end);

state.search_begin = search_begin;
state.search_end = search_end;
state.pattern_start = pattern_start;

search_part_len =  search_end - search_begin + 1;

pattern_padded = [state.pattern; zeros(search_part_len - length(state.pattern), 1)];
state.pattern_fft = conj(fft(pattern_padded));
state.pattern_power = sum(pattern_padded.^2);

state.align_plot = 0;

% figure();
% plot(state.pattern);

end