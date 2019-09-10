function [v] = fit_to_length(v, len)
%FIT_TO_LENGTH Pad/cut vector to given length
%   N/A

v = v(:);

if length(v) <= len
    v = [v; zeros(len - length(v), 1)];
else
    v = v(1:len);
end