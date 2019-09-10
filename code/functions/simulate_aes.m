function [trace V] = simulate_aes(state, idx)
%SIMULATE_AES Generate simulated aes trace
%   N/A

V = zeros(1, 16);
for byte = 1:16
    V(byte) = aes_sbox(bitxor(state.sim_aes_key(byte), state.sim_aes_ch(idx+1, byte)));
end

% generate dummy cycles
%H_cycles = ceil(16*8*rand(1, state.sim_aes_cycle_count)) - 1; 
H_cycles = zeros(state.sim_aes_cycle_count, 1);
for idx = 1:state.sim_aes_cycle_count
   H_cycles(idx) = sum(hamming_weight(round(rand(128,1)))); 
end

% actual leakage
cycle_pos = uint8(ceil(state.sim_aes_rand_cycle_count*rand(1, 1)));
H_all = sum(hamming_weight(V));
H_cycles(cycle_pos) = H_all;

for cycle = 0:state.sim_aes_cycle_count-1
    trace(cycle*state.sim_aes_cycle_points+1:(cycle+1)*state.sim_aes_cycle_points) = ...
        (1 + sqrt(state.sim_aes_pow_signal)) .* state.sim_aes_cycle_waveform + sqrt(state.sim_aes_pow_noise) * randn(1, state.sim_aes_cycle_points); 

     trace(cycle*state.sim_aes_cycle_points+1:cycle*state.sim_aes_cycle_points+state.sim_aes_leak_points) = ...
        (1 + sqrt(state.sim_aes_pow_signal) * H_cycles(cycle+1)/16/8) .* state.sim_aes_cycle_waveform(1:state.sim_aes_leak_points) + sqrt(state.sim_aes_pow_noise) * randn(1, state.sim_aes_leak_points);  
end

end

