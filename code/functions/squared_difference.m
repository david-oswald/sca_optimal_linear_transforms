function [rho] = squared_difference(trace, pattern)

search_part = trace;
search_part_len = length(search_part);

pattern_padded = [pattern; zeros(search_part_len - length(pattern), 1)];
pattern_fft = conj(fft(pattern_padded));
pattern_power = sum(pattern_padded.^2);

[rho] = ifft(fft(search_part).*pattern_fft);
rho = -2*rho; 
rho = rho + pattern_power;

pow_sum = sum(search_part(1:length(pattern)).^2);

for idx = 1:length(rho)
   rho(idx) = rho(idx) + pow_sum; 
    
   idx_in = idx+length(pattern);
   if  idx_in<= length(search_part)
       pow_sum = pow_sum + search_part(idx_in).^2;
   end
   
   idx_out = idx;
   pow_sum = pow_sum - search_part(idx_out).^2; 
end

rho = rho(1:length(rho)-length(pattern));

end