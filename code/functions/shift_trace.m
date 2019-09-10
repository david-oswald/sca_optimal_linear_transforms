function [trace] = shift_trace(trace, pos_left_neg_right)

trace = trace(:);
len = length(trace);

% shift left (cut)
if pos_left_neg_right > 0
    trace = [trace((pos_left_neg_right+1):len); zeros(pos_left_neg_right, 1)]; 
% shift right (zero pad)
elseif pos_left_neg_right  < 0
    trace = [zeros(1, -pos_left_neg_right)'; trace(1:len+pos_left_neg_right)];
% nothing to do
else
    
end

end