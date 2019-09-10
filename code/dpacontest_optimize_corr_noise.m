%%%% This is the method for AES contest v2 traces - you might need to adapt things
close all;
clear all;

addpath("./functions");
addpath("./functions/aes");

% params
project_path = '/path/to/dpacontest_v2/optimize';
result_filename = '/path/to/dpacontest_v2/result_k0.dat'; % Name of result file
trace_directory = '/path/to/dpacontest_v2/traces_profiling20k'; % Name of the directory containing the traces
trace_directory_attack = '/path/to/dpacontest_v2/traces_attack20k'; % Name of the directory containing the traces
attack_wrapper = '/path/to/dpacontest_v2/AttackWrapper/AttackWrapper/bin/Debug/AttackWrapper.exe'; % project_path to AttackWrapper.exe

% basic stuff
f_s = 5e9;
trace_count = 15000;
num_key = 0;
do_cov = 1;


key_profiling = hex2dec(['37'; 'd0'; 'd7'; '24'; 'd0'; '0a'; '12'; '48'; 'db'; '0f'; 'ea'; 'd3'; '49'; 'f1'; 'c0'; '9b']);
key_attack =    hex2dec(['00'; '00'; '00'; '00'; '00'; '00'; '00'; '03'; '24'; '3f'; '6a'; '88'; '85'; 'a3'; '08'; 'd3']);
% Inverse AES position LUT
aes_previous_location = [0 5 10 15 4 9 14 3 8 13 2 7 12 1 6 11];

% Create the S-box and the inverse S-box
[s_box, inv_s_box] = s_box_gen();

% Create the round constant array
rcon = rcon_gen();

% do AES key schedule
aes_round = 10;

w_profiling = key_expansion (key_profiling, s_box, rcon);
w_attack = key_expansion (key_attack, s_box, rcon);

key_profiling_round10 = (w_profiling((1:4) + 4*aes_round, :))';
key_attack_round10 = (w_attack((1:4) + 4*aes_round, :))';

key_profiling_round10 = reshape(key_profiling_round10, 16, 1);
key_attack_round10 =    reshape(key_attack_round10, 16, 1);
  
for jitter = [0] %4 2 1]
	for pow_band_noise = [0] %5 8 0 15]
		for sbox = 1:16
			close all;   

			prefix = sprintf('sbox%02d', sbox);

			% Attack parameters (TODO)

			attacked_subkey = 1; % Number of the attacked subkey (1: subkey used in
			% the first round of AES, ..., 10: subkey used in the last roune)

			% Load the Wrapper
			fprintf('Loading the assembly...\n');
			NET.addAssembly(attack_wrapper);

			state = [];


			clear wrapper;
			fprintf('Loading the wrapper...\n');
			wrapper = AttackWrapper.MatlabWrapper(num_key, trace_count, result_filename, trace_directory, attacked_subkey);

			% Init the wrapper
			fprintf('Initialization of the wrapper...\n');
			wrapper.init();

			state.trace_count = trace_count;
			state.f_s = f_s;

			% AES and shrinkage settings
			lambda1 = 0;
			lambda2 = 0;
			%sbox = 1;
			c_count = 256;

			state.aes_sbox = sbox;

			% simulator settings
			pow_noise = .001;
			pow_signal = .128;
			b_noise = fir1(500, 2/f_s*[23e6 25e6]);

			% plot settings
			do_plot_traces = 1;
			cols_per_row = 3;
			plot_steps = 1000;
			state.plot_steps = plot_steps;

			% initialise RNGs
			rand('twister', 0);
			randn('state', 0);

			trace_plot = figure('Name', 'DPAC: Traces');
			set(trace_plot, 'Units', 'normalized');
			set(trace_plot, 'OuterPosition', [0 0.5 0.5 0.5]);

			corr_plot_global = figure('Name', 'DPAC: Correlation');
			set(corr_plot_global, 'Units', 'normalized');
			set(corr_plot_global, 'OuterPosition', [0 0.5 0.5 0.5]);

			a_plot = figure('Name', 'DPAC: Coefficients');
			set(a_plot, 'Units', 'normalized');
			set(a_plot, 'OuterPosition', [0.5 0.5 0.5 0.5]);

			opt_plot = figure('Name', 'DPAC: Magnitudes');
			set(opt_plot, 'Units', 'normalized');
			set(opt_plot, 'OuterPosition', [0.5 0 0.5 0.5]);


			states_c = cell(c_count, 1);
			states_c_fft = cell(c_count, 1);
			states_c{1} = multibit_corr_init(f_s, -1, -1, do_cov);
			states_c_fft{1} = multibit_corr_init(f_s, -1, -1, do_cov);

			for idx = 2:c_count
				states_c{idx} = multibit_corr_init(f_s, -1, -1, 0);
				states_c_fft{idx} = multibit_corr_init(f_s, -1, -1, 0);
			end

			all_c = cell(length(states_c), 1);
			all_c_fft = cell(length(states_c_fft), 1);

			c_opts = zeros(length(states_c), 1);
			c_opts_fft = zeros(length(states_c_fft), 1);

			c_opts_normal = zeros(length(states_c), ceil(trace_count/plot_steps));
			c_opts_fft_normal = zeros(length(states_c), ceil(trace_count/plot_steps));

			a_opt = cell(ceil(trace_count/plot_steps), 1);
			a_opt_fft = cell(ceil(trace_count/plot_steps), 1);

			fprintf('... Profiling step: jitter = %d, noise = %f ...\n', jitter, pow_band_noise);

			state.sim_aes_key = key_profiling_round10;

			idx_correct = state.sim_aes_key(sbox)+1;

			options = optimset('Display','iter');
			options = optimset(options, 'MaxFunEvals', 10000);

			cc_count = length(states_c);

			fprintf('Profiling: Target byte %d => subkey = %02x\n', sbox, state.sim_aes_key(sbox));
			fprintf('Attack: Target byte %d => subkey = %02x\n', sbox, key_attack_round10(sbox));


			 for idx = 0:trace_count - 1
				state.idx = idx;
				
				% generate trace
				trace_all = wrapper.getTrace;
				trace = double(trace_all.samples);
				trace = trace(2000+300:2800);
				aes_ch = trace_all.plaintext;
				aes_out = trace_all.ciphertext;
				
				if mod(idx, 100) == 0
				   fprintf('Profiling (jitter = %d, noise = %f): Trace %d (%s)\n', jitter, pow_band_noise, idx, char(trace_all.filename));
				   drawnow;
				end
				
				wrapper.nextTrace();
				
				noise = fftfilt(b_noise, randn(1, 10*length(trace)));
				noise = noise(end-length(trace)+1:end);
				trace = trace + pow_band_noise*noise;
				
				trace_fft = abs(fft(trace));
				trace_fft = trace_fft(1:ceil(length(trace_fft)/2));
				
				if do_plot_traces == 1 && idx <= 10
					set(0, 'CurrentFigure', trace_plot);
					plot(trace);
					hold all;
				end
				
				for idx_wrong = 1:cc_count
					initial = aes_sbox_inv(bitxor(uint8(aes_out(sbox)), uint8(idx_wrong-1)));
					prev_loc = aes_previous_location(sbox)+1;
					final = uint8(aes_out(prev_loc));
					H_wrong = hamming_weight(bitxor(initial, final));
					
					[all_c{idx_wrong} states_c{idx_wrong}] = multibit_corr(states_c{idx_wrong}, trace, H_wrong);
					[all_c_fft{idx_wrong} states_c_fft{idx_wrong}] = multibit_corr(states_c_fft{idx_wrong}, trace_fft, H_wrong);
				end 
				
				if mod(idx+1, plot_steps) == 0 && idx ~= 0
					
					set(0, 'CurrentFigure', corr_plot_global);
					
					%%% Plot normal correlation
					subplot(1, 2, 1);
					hold off;
					[c_opts_normal] = plot_correlation_states(state, all_c, states_c, ...
						c_opts_normal, idx_correct);
					
					%%% END

					%%% Plot FFT correlation
					subplot(1, 2, 2);
					hold off;
					[c_opts_fft_normal] = plot_correlation_states(state, all_c_fft, ...
						states_c_fft, c_opts_fft_normal, idx_correct);
					%%% END

					
					%%% optimize filter (normal)
					if do_cov == 1 
						cov_xx = states_c{1}.cov_t;
						cov_xx = cov_xx + lambda1 * eye(length(cov_xx));
						cov_xx_fft = states_c_fft{1}.cov_t;
						cov_xx_fft = cov_xx_fft + lambda1 * eye(length(cov_xx_fft));
					else
						cov_xx = diag(states_c{1}.c_t);
						cov_xx_fft = diag(states_c{1}.c_t);
					end
					
					%x0 = ones(length(trace), 1);
					x0 = 0.05*randn(length(trace), 1);
					x0_fft = 0.05*randn(length(trace_fft), 1);
					a_opt = fminunc(@(x)corr_objective_faster(x, states_c, cov_xx, state), x0, options);
					a_opt_fft = fminunc(@(x)corr_objective_faster(x, states_c_fft, cov_xx_fft, state), x0_fft, options);
					%%% END
					
					%%% Plot optimized filters
					set(0, 'CurrentFigure', a_plot);
					hold off;
					plot(a_opt, 'b');
					hold on;
					plot(a_opt_fft, 'r');
					%%% END
					
					%%% Plot corr. magnitudes
					set(0, 'CurrentFigure', opt_plot);
					
					%%% Plot magnitude of max. corr. for normal
					subplot(2, 2, 1);
					hold off;
					plot_corr_magnitude(state, c_opts_normal, idx_correct)
					%%% END
				   
					%%% Plot normal, optimized
					subplot(2, 2, 2);
					hold off;
					
					for idx_p = 1:length(states_c)
					   cov_yy_corr =  states_c{idx_p}.cov_p;
					   cov_xy_corr = states_c{idx_p}.cov.'/states_c{idx_p}.count;
					   b = 1;
					   c_opt = a_opt'*cov_xy_corr*b/sqrt(a_opt'*cov_xx*a_opt*b'*cov_yy_corr*b);
					   c_opts(idx_p, ceil(idx/plot_steps)) = c_opt;
					end
					
					plot_corr_magnitude(state, c_opts, idx_correct);
					%%% END
					
					%%% Plot magnitude of max. corr. for FFT
					subplot(2, 2, 3);
					hold off;
					plot_corr_magnitude(state, c_opts_fft_normal, idx_correct)
					%%% END
					
					%%% Plot FFT, optimized
					subplot(2, 2, 4);
					hold off;
					
					for idx_p = 1:length(states_c_fft)
					   cov_yy_corr =  states_c_fft{idx_p}.cov_p;
					   cov_xy_corr = states_c_fft{idx_p}.cov.'/states_c_fft{idx_p}.count;
					   b = 1;
					   c_opt = a_opt_fft'*cov_xy_corr*b/sqrt(a_opt_fft'*cov_xx_fft*a_opt_fft*b'*cov_yy_corr*b);
					   c_opts_fft(idx_p, ceil(idx/plot_steps)) = c_opt;
					end
				   
					plot_corr_magnitude(state, c_opts_fft, idx_correct)
					%%% END
					
					%%% END
					
					drawnow;
				end
			 end
			 
			 % Close the wrapper
			wrapper.endAttack();

			% save figures
			saveas(corr_plot_global, sprintf('%s/%d_%s_profiling_jitter_%d_noise_%f.fig', project_path, trace_count, prefix, jitter, pow_band_noise)) 
			saveas(a_plot, sprintf('%s/%d_%s_profiling_jitter_%d_noise_%f_freq.fig', project_path, trace_count, prefix, jitter, pow_band_noise)) 
			saveas(trace_plot, sprintf('%s/%d_%s_profiling_jitter_%d_noise_%f_traces.fig', project_path, trace_count, prefix, jitter, pow_band_noise)) 
			saveas(opt_plot, sprintf('%s/%d_%s_profiling_jitter_%d_noise_%f_opt.fig', project_path, trace_count, prefix, jitter, pow_band_noise)) 

			a_opt_final = a_opt;
			a_opt_fft_final = a_opt_fft;

			coeff_file = sprintf('%s/%d_%s_coeffs.mat', project_path, trace_count, prefix);
			save(coeff_file, 'a_opt', 'a_opt_fft', 'state');

			fprintf('... Attack step: jitter = %d, noise = %f ...\n', jitter, pow_band_noise);
			 
			state_attack = state;

			state_attack.sim_aes_key = key_attack_round10;

			fprintf('Attack: Target byte %d => subkey = %02x\n', sbox, state_attack.sim_aes_key(sbox));

			c_count = 256;
			states_c_attack = cell(c_count, 1);
			states_c_attack{1} = multibit_corr_init(f_s, -1, -1, 1);
			for idx = 2:c_count
				states_c_attack{idx} = multibit_corr_init(f_s, -1, -1, 0);
			end

			c_count = 256;
			states_c_attack_fft = cell(c_count, 1);
			states_c_attack_fft{1} = multibit_corr_init(f_s, -1, -1, 1);
			for idx = 2:c_count
				states_c_attack_fft{idx} = multibit_corr_init(f_s, -1, -1, 0);
			end

			clf(trace_plot);
			clf(corr_plot_global);
			clf(opt_plot);

			fprintf('Attack: Loading the wrapper...\n');
			wrapper_attack = AttackWrapper.MatlabWrapper(num_key, trace_count, ...
					result_filename, trace_directory_attack, attacked_subkey);

			% Init the wrapper
			fprintf('Attack: Initialization of the wrapper...\n');
			wrapper_attack.init();

			all_c_attack = cell(length(states_c_attack), 1);
			all_c_attack_fft = cell(length(states_c_attack_fft), 1);

			c_opts = zeros(length(states_c_attack), 1);
			c_opts_fft = zeros(length(states_c_attack_fft), 1);
			c_opts_normal = zeros(length(states_c_attack), ceil(trace_count/plot_steps));
			c_opts_fft_normal = zeros(length(states_c_attack_fft), ceil(trace_count/plot_steps));

			idx_correct = double(state_attack.sim_aes_key(sbox))+1;

			cc_count = length(states_c);

			for idx = 0:trace_count - 1
				
				state_attack.idx = idx;

				% generate trace
				trace_all = wrapper_attack.getTrace;
				trace = double(trace_all.samples);
				trace = trace(2000+300:2800);
				aes_ch = trace_all.plaintext;
				aes_out = trace_all.ciphertext;
				
				if mod(idx, 100) == 0
				   fprintf('Attack (jitter = %d, noise = %f): Trace %d (%s)\n', jitter, pow_band_noise, idx, char(trace_all.filename));
				   refresh
				end
				
				wrapper_attack.nextTrace();
				
				noise = fftfilt(b_noise, randn(1, 10*length(trace)));
				noise = noise(end-length(trace)+1:end);
				trace = trace + pow_band_noise*noise;
				
				trace_fft = abs(fft(trace));
				trace_fft = trace_fft(1:ceil(length(trace_fft)/2));
				
				if do_plot_traces == 1 && idx <= 10
					set(0, 'CurrentFigure', trace_plot);
					plot(trace);
					hold all;
				end
				
				for idx_wrong = 1:cc_count
					initial = aes_sbox_inv(bitxor(uint8(aes_out(sbox)), uint8(idx_wrong-1)));
					prev_loc = aes_previous_location(sbox)+1;
					final = uint8(aes_out(prev_loc));
					H_wrong = hamming_weight(bitxor(initial, final));
					
					[all_c_attack{idx_wrong} states_c_attack{idx_wrong}] = multibit_corr(states_c_attack{idx_wrong}, trace, H_wrong);
					[all_c_attack_fft{idx_wrong} states_c_attack_fft{idx_wrong}] = multibit_corr(states_c_attack_fft{idx_wrong}, trace_fft, H_wrong);
				end 
				
				if mod(idx+1, plot_steps) == 0 && idx ~= 0
					
					set(0, 'CurrentFigure',corr_plot_global);
					
					%%% Plot normal correlation
					subplot(1, 2, 1);
					hold off;
					[c_opts_normal] = plot_correlation_states(state_attack, all_c_attack, states_c_attack, ...
						c_opts_normal, idx_correct);
					
					%%% END

					%%% Plot FFT correlation
					subplot(1, 2, 2);
					hold off;
					[c_opts_fft_normal] = plot_correlation_states(state_attack, all_c_attack_fft, ...
						states_c_attack_fft, c_opts_fft_normal, idx_correct);
					%%% END

					%%% optimize filter (normal)
					cov_xx = states_c_attack{1}.cov_t;
					cov_xx = cov_xx + lambda1 * eye(length(cov_xx));
					cov_xx_fft = states_c_attack_fft{1}.cov_t;
					cov_xx_fft = cov_xx_fft + lambda1 * eye(length(cov_xx_fft));

					%%% Plot corr. magnitudes
					set(0, 'CurrentFigure', opt_plot);
					
					%%% Plot magnitude of max. corr. for normal
					subplot(2, 2, 1);
					hold off;
					plot_corr_magnitude(state_attack, c_opts_normal, idx_correct)
					%%% END
				   
					%%% Plot normal, optimized
					subplot(2, 2, 2);
					hold off;
					
					for idx_p = 1:length(states_c_attack)
					   cov_yy_corr =  states_c_attack{idx_p}.cov_p;
					   cov_xy_corr = states_c_attack{idx_p}.cov.'/states_c_attack{idx_p}.count;
					   b = 1;
					   c_opt = a_opt_final'*cov_xy_corr*b/sqrt(a_opt_final'*cov_xx*a_opt_final*b'*cov_yy_corr*b);
					   c_opts(idx_p, ceil(idx/plot_steps)) = c_opt;
					end
					
					plot_corr_magnitude(state_attack, c_opts, idx_correct);
					%%% END
					
					%%% Plot magnitude of max. corr. for FFT
					subplot(2, 2, 3);
					hold off;
					plot_corr_magnitude(state_attack, c_opts_fft_normal, idx_correct)
					%%% END
					
					%%% Plot FFT, optimized
					subplot(2, 2, 4);
					hold off;
					
					for idx_p = 1:length(states_c_attack_fft)
					   cov_yy_corr =  states_c_attack_fft{idx_p}.cov_p;
					   cov_xy_corr = states_c_attack_fft{idx_p}.cov.'/states_c_attack_fft{idx_p}.count;
					   b = 1;
					   c_opt = a_opt_fft_final'*cov_xy_corr*b/sqrt(a_opt_fft_final'*cov_xx_fft*a_opt_fft_final*b'*cov_yy_corr*b);
					   c_opts_fft(idx_p, ceil(idx/plot_steps)) = c_opt;
					end
				   
					plot_corr_magnitude(state_attack, c_opts_fft, idx_correct)
					%%% END
					
					%%% END
					
					drawnow;
				end
			end
			
			saveas(corr_plot_global, sprintf('%s/%d_%s_attack_jitter_%d_noise_%f_corr.fig', project_path, trace_count, prefix, jitter, pow_band_noise)) 
			saveas(opt_plot, sprintf('%s/%d_%s_attack_jitter_%d_noise_%f_opt.fig', project_path, trace_count, prefix, jitter, pow_band_noise)) 

		end
	end
end