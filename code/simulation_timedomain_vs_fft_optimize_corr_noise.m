%%%% This is a simulated comparison between optimal linear transform and DFT correlation for different
%%%% band-limited noise powers (pow_band_noise)
close all;
clear all;

addpath("./functions");

project_path = './results';

for pow_band_noise = [8 10 15 20]
    close all;    

    % basic stuff
    f_s = 1e9;
    trace_count = 50000;

    state = [];
    state.trace_count = trace_count;
    state.f_s = f_s;

    % AES and shrinkage settings
    lambda1 = 0;
    lambda2 = 0;
    sbox = 1;
    c_count = 50;

    state.aes_sbox = sbox;

    % simulator settings
    pow_noise = .001;
    pow_signal = .128;
    % for snr = 0.56/0.33
    % pow_band_noise = 5;
    % for snr = 0.56/0.55

    cycle_len = 30e-9;
    leak_len = 15e-9;
    cycle_count = 4;
    rand_cycle_count = 1;

    b_noise = fir1(500, 2/f_s*[23e6 25e6]);

    % plot settings
    do_plot_traces = 1;
    cols_per_row = 3;
    plot_steps = 1000;

    % initialise RNGs
    rand('twister', 0);
    randn('state', 0);

    % initialize AES simulator
    state = simulate_aes_init(state, cycle_len, leak_len, pow_noise, pow_signal, cycle_count, rand_cycle_count);

    trace_plot = figure();
    corr_plot_global = figure();
    a_plot = figure();

    states_c = cell(c_count, 1);
    states_c{1} = multibit_corr_init(f_s, -1, -1, 1);

    for idx = 2:c_count
        states_c{idx} = multibit_corr_init(f_s, -1, -1, 0);
    end

    all_c = cell(length(states_c), 1);
    c_opts = zeros(length(states_c), 1);
    significance = zeros(length(states_c), ceil(trace_count/plot_steps));
    c_opts_normal = zeros(length(states_c), ceil(trace_count/plot_steps));
    a_opt = cell(ceil(trace_count/plot_steps), 1);

    fprintf('... Profiling step: %f...\n', pow_band_noise);

    all_c = cell(length(states_c), 1);
    c_opts = zeros(length(states_c), ceil(trace_count/plot_steps));

    state = simulate_aes_init(state, cycle_len, leak_len, pow_noise, pow_signal, cycle_count, rand_cycle_count);
    state.sim_aes_key(sbox) = 2;

    [trace V] = simulate_aes(state, 0);
    x0 = zeros(length(trace), 1);

     for idx = 0:trace_count - 1
        if mod(idx, 100) == 0
           fprintf('Profiling (%f): Trace %d\n', pow_band_noise, idx);
        end

        % generate trace
        [trace V] = simulate_aes(state, idx);

        noise = fftfilt(b_noise, randn(1, 10*length(trace)));
        noise = noise(end-length(trace)+1:end);
        trace = trace + pow_band_noise*noise;

        if do_plot_traces == 1 && idx <= 10
            figure(trace_plot);
            plot(trace);
            hold all;
        end

        for idx_wrong = 1:length(states_c)
            H_wrong = hamming_weight(aes_sbox(bitxor(uint8(idx_wrong-1), state.sim_aes_ch(idx+1, sbox))));
            [all_c{idx_wrong} states_c{idx_wrong}] = multibit_corr(states_c{idx_wrong}, trace, H_wrong);
        end 

        if mod(idx+1, plot_steps) == 0 && idx ~= 0
            yscale = 4/sqrt(states_c{1}.count);

            figure(corr_plot_global);
            subplot(2, 2, 1);
            hold off;

            for idx_p = 1:length(states_c)
               all_c_curr = all_c{idx_p};

               if idx_p ~= state.sim_aes_key(sbox)+1
                   plot(all_c_curr, 'Color', [0.7 0.7 0.7]);
                   hold on;
               end

               c_opts_normal(idx_p, ceil(idx/plot_steps)) = max(abs(all_c_curr));
            end

            all_c_curr = all_c{state.sim_aes_key(sbox)+1};
            plot(all_c_curr, 'Color', [1 0 0]);

            plot(yscale*ones(1, length(all_c{1})), 'red');
            plot(-yscale*ones(1, length(all_c{1})), 'red');
            ylim([-2*yscale 2*yscale]);

            subplot(2, 2, 2);
            hold off;

            for idx_p = 1:length(states_c) 
                if idx_p ~= state.sim_aes_key(sbox)+1
                    plot(abs(c_opts_normal(idx_p, 1:ceil(idx/plot_steps))), 'Color', [0.7 0.7 0.7]);
                    hold on;
                end 
            end

            plot(abs(c_opts_normal(state.sim_aes_key(sbox)+1, 1:ceil(idx/plot_steps))), 'Color', [1 0 0]);

            ycenter = mean(abs(c_opts_normal(1, max(1, ceil(idx/plot_steps - 30)):ceil(idx/plot_steps))));
            yupper = ycenter + ycenter/3;
            ylower = ycenter - 5/6*ycenter;
            ylim([ylower yupper]);

            % optimize filter
            cov_xx = states_c{1}.cov_t;
            cov_xx = cov_xx + lambda1 * eye(length(cov_xx));

            x0 = 0.95*x0 + 0.05*randn(length(trace), 1);
            %a_opt = fminsearch(@(x)corr_objective(x, states_c, cov_xx, state), x0, optimset('MaxIter', 100000));
            %a_opt = fmincon(@(x)corr_objective(x, states_c, cov_xx, state), x0, [], [], [], [], zeros(1, length(x0)), Inf(1, length(x0)), [], optimset('MaxIter', 50000));
            a_opt = fminunc(@(x)corr_objective_faster(x, states_c, cov_xx, state), x0, optimset('MaxFunEvals', 10000));

            subplot(2, 2, 3);
            hold off;
            plot(a_opt);

            subplot(2, 2, 4);
            hold off;

            for idx_p = 1:length(states_c)
               cov_yy_corr =  states_c{idx_p}.cov_p;
               cov_xy_corr = states_c{idx_p}.cov.'/states_c{idx_p}.count;
               b = 1;
               c_opt = a_opt'*cov_xy_corr*b/sqrt(a_opt'*cov_xx*a_opt*b'*cov_yy_corr*b);
               c_opts(idx_p, ceil(idx/plot_steps)) = c_opt;

               if idx_p ~= state.sim_aes_key(sbox)+1
                   plot(abs(c_opts(idx_p, 1:ceil(idx/plot_steps))), 'Color', [0.7 0.7 0.7]);
                   hold on; 
               end
            end

            plot(abs(c_opts(state.sim_aes_key(sbox)+1, 1:ceil(idx/plot_steps))), 'Color', [1 0 0]);

            figure(a_plot);
            freqz(a_opt, 1, 4096, f_s);
        end

        drawnow;
     end

    % save figures
    saveas(corr_plot_global, sprintf('%s/%d_profiling_noise_%f.fig', project_path, trace_count, pow_band_noise)) 
    saveas(a_plot, sprintf('%s/%d_profiling_noise_%f_freq.fig', project_path, trace_count, pow_band_noise)) 
    saveas(trace_plot, sprintf('%s/%d_profiling_noise_%f_traces.fig', project_path, trace_count, pow_band_noise)) 

    a_opt_final = a_opt;

    fprintf('... Attack step: %f ...\n', pow_band_noise);

    state_attack = simulate_aes_init(state, cycle_len, leak_len, pow_noise, pow_signal, cycle_count, rand_cycle_count);
    state_attack.sim_aes_key(sbox) = 3;

    c_count = 256;
    states_c_attack = cell(c_count, 1);
    states_c_attack{1} = multibit_corr_init(f_s, -1, -1, 1);
    for idx = 2:c_count
        states_c_attack{idx} = multibit_corr_init(f_s, -1, -1, 0);
    end

    c_count = 256;
    states_c_attack_fft = cell(c_count, 1);
    for idx = 1:c_count
        states_c_attack_fft{idx} = multibit_corr_init(f_s, -1, -1, 0);
    end

    clf(trace_plot);
    clf(corr_plot_global);

    all_c_attack = cell(length(states_c_attack), 1);
    all_c_attack_fft = cell(length(states_c_attack_fft), 1);

    c_opts_fft = zeros(length(states_c_attack_fft), 1);
    c_opts_attack = zeros(length(states_c_attack), 1);
    c_opts_normal_attack = zeros(length(states_c_attack), ceil(trace_count/plot_steps));

    idx_key_correct = double(state_attack.sim_aes_key(sbox))+1;

    for idx = 0:trace_count - 1
        if mod(idx, 100) == 0
           fprintf('Attack (%f): Trace %d\n', pow_band_noise, idx);
        end

        % generate trace
        [trace V] = simulate_aes(state_attack, idx);
        noise = fftfilt(b_noise, randn(1, 10*length(trace)));
        noise = noise(end-length(trace)+1:end);

        trace = trace + pow_band_noise*noise;
        trace_fft = abs(fft(trace));

        if do_plot_traces == 1 && idx <= 10
            figure(trace_plot);
            plot(trace);
            hold all;
        end

        for idx_wrong = 1:length(states_c_attack)
            H_wrong = hamming_weight(aes_sbox(bitxor(uint8(idx_wrong-1), state_attack.sim_aes_ch(idx+1, sbox))));
            [all_c_attack{idx_wrong} states_c_attack{idx_wrong}] = multibit_corr(states_c_attack{idx_wrong}, trace, H_wrong);
            [all_c_attack_fft{idx_wrong} states_c_attack_fft{idx_wrong}] = multibit_corr(states_c_attack_fft{idx_wrong}, trace_fft, H_wrong);
        end 

        if mod(idx+1, plot_steps) == 0 && idx ~= 0

            yscale = 4/sqrt(states_c_attack{1}.count);

            figure(corr_plot_global);
            subplot(2, 3, 1);
            hold off;

            for idx_p = 1:length(states_c_attack)
               all_c_curr = all_c_attack{idx_p};

               if idx_p ~= idx_key_correct
                   plot(all_c_curr, 'Color', [0.7 0.7 0.7]);
                   hold on;
               end

               c_opts_normal_attack(idx_p, ceil(idx/plot_steps)) = max(abs(all_c_curr));
            end

            all_c_curr = all_c_attack{idx_key_correct};
            plot(all_c_curr, 'Color', [1 0 0]);

            plot(yscale*ones(1, length(all_c_attack{1})), 'red');
            plot(-yscale*ones(1, length(all_c_attack{1})), 'red');
            ylim([-2*yscale 2*yscale]);

            subplot(2, 3, 2);
            hold off;

            for idx_p = 1:length(states_c_attack) 
                if idx_p ~= idx_key_correct
                    plot(abs(c_opts_normal_attack(idx_p, 1:ceil(idx/plot_steps))), 'Color', [0.7 0.7 0.7]);
                    hold on;
                end 
            end

            plot(abs(c_opts_normal_attack(idx_key_correct, 1:ceil(idx/plot_steps))), 'Color', [1 0 0]);

            ycenter = mean(abs(c_opts_normal_attack(1, max(1, ceil(idx/plot_steps - 30)):ceil(idx/plot_steps))));
            yupper = ycenter + ycenter/3;
            ylower = ycenter - 5/6*ycenter;
            ylim([ylower yupper]);

            % optimized filter

            subplot(2, 3, 3);
            hold off;
            plot(a_opt_final);

            subplot(2, 3, 4);
            hold off;

            for idx_p = 1:length(states_c_attack)
               cov_yy_corr =  states_c_attack{idx_p}.cov_p;
               cov_xy_corr = states_c_attack{idx_p}.cov.'/states_c_attack{idx_p}.count;
               b = 1;
               c_opt = a_opt_final'*cov_xy_corr*b/sqrt(a_opt_final'*cov_xx*a_opt_final*b'*cov_yy_corr*b);
               c_opts_attack(idx_p, ceil(idx/plot_steps)) = c_opt;

               if idx_p ~= idx_key_correct
                   plot(abs(c_opts_attack(idx_p, 1:ceil(idx/plot_steps))), 'Color', [0.7 0.7 0.7]);
                   hold on; 
               end
            end

            plot(abs(c_opts_attack(idx_key_correct, 1:ceil(idx/plot_steps))), 'Color', [1 0 0]);

            subplot(2, 3, 5);
            hold off;

            for idx_p = 1:length(states_c_attack_fft)
               all_c_curr = all_c_attack_fft{idx_p};

               if idx_p ~= idx_key_correct
                   plot(all_c_curr, 'Color', [0.7 0.7 0.7]);
                   hold on;
               end

               c_opts_fft(idx_p, ceil(idx/plot_steps)) = max(abs(all_c_curr));
            end

            all_c_curr = all_c_attack_fft{idx_key_correct};
            plot(all_c_curr, 'Color', [1 0 0]);

            plot(yscale*ones(1, length(all_c_attack_fft{1})), 'red');
            plot(-yscale*ones(1, length(all_c_attack_fft{1})), 'red');
            ylim([-2*yscale 2*yscale]);

            subplot(2, 3, 6);
            hold off;

            for idx_p = 1:length(states_c_attack_fft) 
                if idx_p ~= idx_key_correct
                    plot(abs(c_opts_fft(idx_p, 1:ceil(idx/plot_steps))), 'Color', [0.7 0.7 0.7]);
                    hold on;
                end 
            end

            plot(abs(c_opts_fft(idx_key_correct, 1:ceil(idx/plot_steps))), 'Color', [1 0 0]);

            ycenter = mean(abs(c_opts_fft(1, max(1, ceil(idx/plot_steps - 30)):ceil(idx/plot_steps))));
            yupper = ycenter + ycenter/3;
            ylower = ycenter - 5/6*ycenter;
            ylim([ylower yupper]);
        end

        drawnow;
    end

    % save figures
    saveas(corr_plot_global, sprintf('%s/%d_attack_noise_%f.fig', project_path, trace_count, pow_band_noise)) 
end
