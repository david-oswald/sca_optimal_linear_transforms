%%%% This is the basic objective function
function [v] = corr_objective(a, states_c, cov_xx, state)

c_opt = zeros(length(states_c), 1);
b = 1;

for idx_c = 1:length(states_c)
    % to normalise
    cov_yy_corr =  states_c{idx_c}.cov_p;

    % to normalise
    cov_xy_corr = states_c{idx_c}.cov.'/states_c{idx_c}.count;

    c_opt(idx_c) = a'*cov_xy_corr*b/sqrt(a'*cov_xx*a*b'*cov_yy_corr*b);
end

key_correct = state.sim_aes_key(state.aes_sbox);
c_correct = abs(c_opt(key_correct+1));
c_mean = mean(abs([c_opt(1:key_correct)' c_opt(key_correct+2:end)']));
v = - c_correct/c_mean;

end

