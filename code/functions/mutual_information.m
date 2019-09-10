function [MI, H_rows, H_cols] = mutual_information(p)
%MUTUAL_INFORMATION Compute I(X, Y) from distribution p
%   N/A
p_cols = sum(p, 1);
p_rows = sum(p, 2);

p_cols_log = log2(p_cols);
p_cols_log(isinf(p_cols_log)) = 0;
H_cols = -sum(p_cols.*p_cols_log);
p_rows_log = log2(p_rows);
p_rows_log(isinf(p_rows_log)) = 0;
H_rows = -sum(p_rows.*p_rows_log);

p_log = log2(p);
p_log(isinf(p_log)) = 0;
H_p = -sum(sum(p.*p_log));

MI = H_rows + H_cols - H_p;

end

