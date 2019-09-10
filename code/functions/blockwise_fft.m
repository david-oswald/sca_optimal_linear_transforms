function [ t ] = blockwise_fft(w, f_s, f_max)
%BLOCKWISE_FFT Summary of this function goes here
%   Detailed explanation goes here
[win_cnt win_size] = size(w);

if f_max <= 0 || f_max > f_s
	out_bin_cnt = floor(win_size/2) + 1;
else 
	d_f = f_s/win_cnt;
	out_bin_cnt = floor(f_max/d_f);
end

t = zeros(out_bin_cnt * win_cnt, 1);
for idx = 0:win_cnt-1
   % to FFT domain
   t_fft = abs(fft(w(idx+1,:)));
   
   % Limit frequency
   t_fft = t_fft(1:out_bin_cnt);
   
   % Copy to output
   t(idx*out_bin_cnt + 1:(idx+1)*out_bin_cnt) = t_fft;
end

	

end

