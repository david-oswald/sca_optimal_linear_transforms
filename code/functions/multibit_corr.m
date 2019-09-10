function [c state_c] = multibit_corr(state_c, trace, p, varargin)
%REC_CORR Recursive correlation
%   state_c Previous state
%   trace New trace
%   p New prediction vector

    % ensure trace is a row vector
    trace = trace(:).';
	% ensure prediction is a row vector
	p = p(:).';
    
    % cut
    if state_c.p_begin >= 1 && state_c.p_end >= 1
        trace = trace(state_c.p_begin:state_c.p_end);
    end
    
    % init if required
    if ~isfield(state_c, 'count') || state_c.count(1) == 0
        state_c.m_t = zeros(1, length(trace));
        state_c.c_t = zeros(1, length(trace));
        state_c.cov = zeros(length(p), length(trace));

		state_c.count = 0;
		state_c.m_p = zeros(1, length(p));
		state_c.c_p = zeros(1, length(p));
		state_c.cov_p = zeros(length(p), length(p));
			
        if state_c.do_cov_t == 1 
            state_c.cov_t = zeros(length(trace), length(trace));
        end
    end  
    
	alpha = ones(1, length(state_c.count))./(state_c.count + 1);

	% updated trace mean
	m_trace_new = (1 - alpha).*state_c.m_t + alpha.*trace;
	m_p_new = (1 - alpha).*state_c.m_p + alpha.*p;

	% update sum of square differences
	state_c.c_t = state_c.c_t + (trace - m_trace_new).*(trace - state_c.m_t);
	state_c.c_p = state_c.c_p + (p - m_p_new).*(p - state_c.m_p);

	% update covariance
	state_c.cov = state_c.cov + (p - state_c.m_p).'*(trace - m_trace_new);

	% update cov within trace
	state_c.cov_p = rec_cov(state_c.cov_p, state_c.m_p, p, alpha);
	
	if state_c.do_cov_t == 1
		state_c.cov_t = rec_cov(state_c.cov_t, state_c.m_t, trace, alpha);
	end

	% update means in state
	state_c.m_t = m_trace_new;
	state_c.m_p = m_p_new;

	% update count
	state_c.count = state_c.count + 1;

	c = state_c.cov./sqrt(state_c.c_p.' * state_c.c_t);
end
