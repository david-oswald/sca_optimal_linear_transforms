function [state] = simulate_aes_init(state, cycle_len, leak_len, ...
    pow_noise, pow_signal, cycle_count, rand_cycle_count)
%SIMULATE_AES_INIT N/A
%   N/A

f_s = state.f_s;

state.sim_aes_pow_noise = pow_noise;
state.sim_aes_pow_signal = pow_signal;
state.sim_aes_cycle_count = cycle_count;
state.sim_aes_rand_cycle_count = rand_cycle_count;

state.sim_aes_cycle_points = round(f_s * cycle_len);
state.sim_aes_leak_points = round(f_s * leak_len);


state.sim_aes_cycle_waveform = rectpuls(1:state.sim_aes_cycle_points, ...
    state.sim_aes_leak_points); %round(state.sim_aes_cycle_points/2)); 

% (static) random AES key
state.sim_aes_key = uint8(ceil(256*rand(1, 16)) - 1);

% generate challenges
state.sim_aes_ch = uint8(ceil(256*rand(state.trace_count, 16)) - 1);


end

