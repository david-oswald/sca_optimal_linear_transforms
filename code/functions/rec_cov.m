function [C] = rec_cov(C_prev, m_prev, val, alpha)
%REC_COV Summary of this function goes here
%   Detailed explanation goes here
    C = (1 - alpha)*( C_prev + alpha*(val - m_prev)'*(val - m_prev));
end
