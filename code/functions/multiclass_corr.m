function [state_c] = multiclass_corr(state_c, trace, c)
% MULTICLASS_CORR n/a

    % ensure trace is a row vector
    trace = trace(:).';
    
    % cut
    if state_c.p_begin >= 1 && state_c.p_end >= 1
        trace = trace(state_c.p_begin:state_c.p_end);
    end
    
    % init if required
    if ~isfield(state_c, 'count')
        state_c.m_t = zeros(state_c.class_count, length(trace));
        state_c.c_t = zeros(state_c.class_count, length(trace));

        state_c.count = zeros(state_c.class_count, 1);
        
        if state_c.do_cov_t == 1 
            state_c.cov_t = cell(state_c.class_count, 1);
            
            for idx_cov = 1:state_c.class_count
                state_c.cov_t{idx_cov} = zeros(length(trace), length(trace));
            end
        end
    end  
    
   
    alpha = ones(1, length(state_c.count(c)))./(state_c.count(c) + 1);

    % updated trace mean
    m_trace_new = (1 - alpha).*state_c.m_t(c,:) + alpha.*trace;

    % update sum of square differences
    state_c.c_t(c,:) = state_c.c_t(c,:) + (trace - m_trace_new).*(trace - state_c.m_t(c,:));

    % update cov within trace
    if state_c.do_cov_t == 1
        state_c.cov_t{c} = rec_cov(state_c.cov_t{c}, state_c.m_t(c,:), trace, alpha);
    end

    % update means in state
    state_c.m_t(c,:) = m_trace_new;

    % update count
    state_c.count(c) = state_c.count(c) + 1;
end
