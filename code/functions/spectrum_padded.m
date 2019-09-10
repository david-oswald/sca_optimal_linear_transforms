function [S, df] = spectrum_padded( s, f_s, pad )
%SPECTRUM_PADDED Summary of this function goes here
%   Detailed explanation goes here

T_s = 1/f_s;

pad_pt = round(f_s * pad);

s_pad = s(:);
s_pad = [s_pad; zeros(pad_pt, 1)];
S = fft(s_pad);

df = f_s/length(S);

end

