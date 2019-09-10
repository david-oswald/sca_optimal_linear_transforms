function [ bitvec ] = bytevec_to_bitvec( bytevec )
%BYTEVEC_TO_BITVEC Summary of this function goes here
%   Detailed explanation goes here
bitvec = zeros(1, length(bytevec )*8);
for idx_byte = 0:length(bytevec )-1
    tmp = dec2bin(bytevec (idx_byte+1), 8);
    bitvec(idx_byte*8+1:(idx_byte+1)*8) = bin2dec(tmp(:));
end

end

