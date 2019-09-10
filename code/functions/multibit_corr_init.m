function [state_c] = multibit_corr_init(f_s, p_begin, p_end, do_cov)
%REC_CORR_INIT Init correlation state
%   N/A

state_c.f_s = f_s;
if p_begin >= 0
    state_c.p_begin = round(f_s * p_begin);
else
    state_c.p_begin = -1;
end

if p_end >= 0
    state_c.p_end = round(f_s * p_end);
else
    state_c.p_end = -1;
end

state_c.do_cov_t = do_cov;

end
