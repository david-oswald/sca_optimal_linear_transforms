function [v state] = rec_var(state, val, sample_idx)
%REC_VAR Summary of this function goes here
%   state Previous state (var, mean)
%   val New value
%   sample_idx Index of sample, zero-based counting

    % init if required
    if sample_idx == 0 || ~isfield(state, 'var')
        state.var = zeros(2, length(val));
    end  
    
    % ensure val is a row vector
    val = val(:).';
    
    alpha = 1/(sample_idx + 1);
    
    % updated mean
    m_new = (1 - alpha).*state.var(1, :) + alpha*val;
    
    % update sum of square differences
    state.var(2, :) = state.var(2, :) + (val - m_new).*(val - state.var(1, :));
    
    % update state
    state.var(1, :) = m_new;
    
    v = state.var(2, :)/sample_idx;

end
