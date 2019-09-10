function [ t_out] = windowed_fft( trace, window_size, expand, overlap )
%WINDOWED_FFT Summary of this function goes here
%   Detailed explanation goes here
wnd_mult = hann(window_size+1);
partial_window_size = round(window_size-(window_size*overlap));
    
the_size = (round((window_size/2)+1)*(round(length(trace)/partial_window_size)-1));
t_out = zeros(the_size,1);
%window = zeros(expand, 1);

for idx_w = 0:(round(length(trace)/partial_window_size)-3)
    wnd_index = idx_w*partial_window_size;
    %length(raw_trace(wnd_index+1:(wnd_index+window_size+1)))
    %length(window(1:window_size+1))
    window = trace(wnd_index+1:(wnd_index+window_size+1));
    window = window .* wnd_mult;
    window_fft = abs(fft(window, expand));
    %length(window_fft)
    trace_idx_start = (round(expand/2)*idx_w)+1;
    trace_idx_end = (round(expand/2)*(idx_w+1));

    t_out(trace_idx_start:trace_idx_end) = window_fft(1:round(length(window_fft)/2));
end

end

