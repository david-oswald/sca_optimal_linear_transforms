function [ aes_state ] = get_aes_round(aes_const, key, plain, round )
%GET_AES_ROUND returns the state of the aes after given round


% Create the expanded key (schedule)
w = key_expansion (key, aes_const.s_box, aes_const.rcon);

aes_state = cipher (plain, w, aes_const.s_box, aes_const. poly_mat, round);
end

