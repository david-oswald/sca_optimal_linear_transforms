function [pos rho] = find_pattern(state, trace)

search_part = trace(state.find_p_search_begin:state.find_p_search_end);

[rho] = ifft(fft(search_part).*state.find_p_pattern_fft);
rho = -2*rho; 
rho = rho + state.find_p_pattern_power;

pow_sum = sum(search_part(1:length(state.find_p_pattern)).^2);

for idx = 1:length(rho)
   rho(idx) = rho(idx) + pow_sum; 
    
   idx_in = idx+length(state.find_p_pattern);
   if  idx_in<= length(search_part)
       pow_sum = pow_sum + search_part(idx_in).^2;
   end
   
   idx_out = idx;
   pow_sum = pow_sum - search_part(idx_out).^2; 
end

rho = rho(1:length(rho)-length(state.find_p_pattern));

[val ppos] = min(abs(rho));

pos = (ppos - 1 + state.find_p_search_begin);

if state.debug == 1
    fprintf(1, 'Least-squares %f for %d (=> shift %d)\n', val, pos);
end

end