function [ aes_const ] = init_aes_const()
%INIT_AES_CONST Summary of this function goes here
%   Detailed explanation goes here
    
    % Create the S-box and the inverse S-box
    [aes_const.s_box, aes_const.inv_s_box] = s_box_gen ();

    % Create the round constant array
    aes_const.rcon = rcon_gen ();

    % Create the polynomial transformation matrix and the inverse polynomial matrix
    % to be used in MIX_COLUMNS
    [aes_const.poly_mat, aes_const.inv_poly_mat] = poly_mat_gen ();


end

