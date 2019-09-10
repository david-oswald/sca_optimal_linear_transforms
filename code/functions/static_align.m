function [trace shift] = static_align(state, trace)

trace = trace(:);
search_begin = max(1, state.search_begin);
search_end = min(state.search_end, length(trace)); 
pattern_start = state.pattern_start;

len = length(trace);

search_part = trace(search_begin:search_end);

[rho2] = ifft(fft(search_part).*state.pattern_fft);
rho2 = -2*rho2; 
rho2 = rho2 + state.pattern_power;

pow_sum = sum(search_part(1:length(state.pattern)).^2);

for idx = 1:length(rho2)
   rho2(idx) = rho2(idx) + pow_sum; 
    
   idx_in = idx+length(state.pattern);
   if  idx_in<= length(search_part)
       pow_sum = pow_sum + search_part(idx_in).^2;
   end
   
   idx_out = idx;
   pow_sum = pow_sum - search_part(idx_out).^2; 
end

rho2 = rho2(1:length(rho2)-length(state.pattern));

[val2 ppos2] = min(abs(rho2));

if state.align_plot == 1
    figure();
    plot(search_part/max(abs(search_part)));
    hold all;
    %plot(pattern);
    %plot(rho);%/max(abs(rho)));
    plot(rho2/max(abs(rho2)));%/max(abs(rho2)));
end

shift = (ppos2 - 1 + search_begin) - pattern_start;

if state.debug == 1
    fprintf(1, 'Least-squares %f for %d (=> shift %d)\n', val2, ppos2, shift);
end

trace = shift_trace(trace, shift);
   
end