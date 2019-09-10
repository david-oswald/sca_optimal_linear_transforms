function [ aes_state ] = get_inv_aes_round(aes_const, key, cipher, rounds )
%GET_AES_ROUND returns the state of the aes after given round


% Create the expanded key (schedule)
w = key_expansion (key, aes_const.s_box, aes_const.rcon);

aes_state = inv_cipher (cipher, w, aes_const.inv_s_box, aes_const.inv_poly_mat, rounds);
end

