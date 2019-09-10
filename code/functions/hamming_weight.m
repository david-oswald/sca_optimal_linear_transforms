function [w] = hamming_weight(in)
%HAMMING_WEIGHT (Inefficient) Hamming Weight
%   N/A
in = in(:);
w = 0;

for idx = 1:length(in)
    w = w + sum(dec2bin(in(idx)) == '1');
end 

end
