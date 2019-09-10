function [state] = find_pattern_init(state, ref_trace, ...
    search_begin, search_end, pattern_start, pattern_end)

f_s = state.f_s;

search_begin = max(1, round(f_s * search_begin));
search_end = round(f_s * search_end); 
pattern_start = round(f_s * pattern_start);
pattern_end = round(f_s * pattern_end);

state.find_p_pattern = ref_trace(pattern_start:pattern_end);

state.find_p_search_begin = search_begin;
state.find_p_search_end = search_end;
state.find_p_pattern_start = pattern_start;

search_part_len =  search_end - search_begin + 1;

pattern_padded = [state.find_p_pattern; zeros(search_part_len - length(state.find_p_pattern), 1)];
state.find_p_pattern_fft = conj(fft(pattern_padded));
state.find_p_pattern_power = sum(pattern_padded.^2);

state.find_p_align_plot = 0;

% figure();
% plot(state.find_p_pattern);

end