function [state_c] = rec_corr_init(f_s, p_begin, p_end, do_cov, varargin)
%REC_CORR_INIT Init correlation state
%   N/A

optargin = size(varargin, 2);

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

if optargin == 1
    state_c.rec_corr_use_mask = varargin{1};
else
    state_c.rec_corr_use_mask = 0;
end

state_c.do_cov_t = do_cov;

end
