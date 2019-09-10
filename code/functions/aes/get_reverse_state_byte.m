function [ out ] = get_reverse_state_byte( aes_const, ciphertext, key_byte, byte_num )
%
    byte_pos_table = [1 14 11 8 5 2 15 12 9 6 3 16 13 10 7 4];
    
    out = sub_bytes(bitxor(key_byte, ciphertext(byte_pos_table(byte_num))), aes_const.inv_s_box);
    %out = sub_bytes(bitxor(key_byte, ciphertext((byte_num))), aes_const.inv_s_box);

end

