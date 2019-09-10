function [blocks] = window_trace( trace, window_size, expand, overlap )
%WINDOW_TRACE Summary of this function goes here
%   Detailed explanation goes here

N_t = length(trace);
in_increment = (1.0 - overlap) * window_size;
final_window_size = mod(N_t, in_increment);

if final_window_size == 0
    block_count = floor(N_t/in_increment);
else
    block_count = floor(N_t/in_increment) + 1;
end

block_begin = 0;
block_counter = 0;
block_size = window_size + expand;

blocks = zeros(block_count, block_size);

while block_begin < N_t
    final_window_size = N_t - block_begin;
    
    if block_begin + window_size < N_t
       block_len = window_size; 
    else
       block_len = final_window_size; 
    end
    
    block_end = block_begin + block_len - 1;
    blocks(block_counter + 1, 1:block_len) = trace((block_begin + 1):(block_end + 1));
    
    block_counter = block_counter + 1; 
    block_begin = block_begin + in_increment;
    
   
end


end

