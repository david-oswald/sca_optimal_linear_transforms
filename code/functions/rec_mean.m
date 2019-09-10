function [m] = rec_mean(m_prev, val, alpha)
%REC_MEAN Summary of this function goes here
%   Detailed explanation goes here
    m = (1 - alpha).*m_prev + alpha*val;
end
